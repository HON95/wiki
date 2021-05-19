---
title: CUDA
breadcrumbs:
- title: Software Engineering
- title: HPC
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [CUDA (configuration)](/config/config/hpc/cuda.md)

## General

- Introduced by NVIDIA in 2006. While GPU compute was possible before through hackish methods, CUDA provided a programming model for compute which included e.g. thread blocks, shared memory and synchronization barriers.
- Modern NVIDIA GPUs contain _CUDA cores_, _tensor cores_ and _RT cores_ (ray tracing cores). Tensor cores may be accessed in CUDA through special CUDA calls, but RT cores are (as of writing) only accessible from Optix and not CUDA.
- The _compute capability_ describes the generation and supported features of a GPU.

### Mapping the Programming Model to the Execution Model

- The programmer decides the grid size (number of blocks and threads therein) when launching a kernel.
- The device has a constant number of streaming multiprocessors (SMs) and CUDA cores (not to be confused with tensor cores or RT cores).
- Each kernel launch (or rather its grid) is executed by a single GPU. To use multiple GPUs, multiple kernel launches are required by the CUDA application.
- Each thread block is executed by a single SM and is bound to it for the entire execution. Each SM may execute multiple thread blocks.
- Each CUDA core within an SM executes a thread from a block assigned to the SM.
- **TODO** Warps and switches. 32 threads per warp for all current GPUs.

## Programming

### General

- Branch divergence: Each SM has only a single control unit for all cores within it, so for all branches any thread takes (in total), the SM and all of its cores will need to go through all of the branches but mask the output for all threads which did not locally take the branch. If no threads take a specific branch, it will not be executed by the SM.
- Host code and device code: Specifying the `__host__` keyword for a function means that it will be accessible by the host (the default if nothing is specified). Specifying the `__device__` keyword for a function means that it will be accessible by devices. Specifying both means it will be accessible by both.
- Kernels are specified as functions with the `__global__` keyword.

### Thread Hierarchy

- Grids consist of a number of blocks and blocks concist of a number of threads.
- Threads and blocks are indexed in 1D, 2D or 3D space (separately), which threads may access through the 3-compoent vectors `blockDim`, `blockIdx` and `threadIdx`.
- The programmer decides the number of grids, blocks and threads to use, as well as the number of dimensions to use, for each kernel invocation.
- The number of threads per block is typically limited to 1024.
- See the section about mapping it to the execution model for a better understanding of why it's organized this way.

### Memory

#### Memory Hierarchy Overview

- Memories:
    - Register.
    - Local.
    - Shared.
    - Global.
    - Constant.
    - Texture.
- Accessibility and lifetimes:
    - The global, constant and texture memories are accessible from the host and persist between kernel executions.
    - The register and local memories are thread-local (where the latter is automatically spilled into when the register memory is full).
    - The shared memories are block-local.
- Read-write access:
    - The constant and texture memories are read-only (wrt. the device).
- Caching:
    - The constant and texture memories are cached.
    - The global and local memories are cached in L1 and L2 on newer devices.
    - The register and shared memories are on-chip and fast, so they don't need to be cached.

#### Global Memory

- The largest and slowest memory on the device.
- Resides in the GPU DRAM.
- Variables may persist for the lifetime of the application.
- One of the memories the host can access (outside of kernels).
- The only memory threads from different blocks can share data in.
- Statically declared in global scope using the `__device__` declaration or dynamically allocated using `cudaMalloc`.
- Global memory coalescing:
    - When multiple threads in a warp access global memory in an aligned and sequential fashion (e.g. when all threads in the warp access sequential parts of an array), the device will try to _coalesce_ the access into as few 32-byte transactions as possible in order to reduce the number of transaction and  increase the ratio of useful to fetched data.
    - This description overlaps a bit with data alignment, which is described elsewhere on this page.
    - Since the global memory will be accessed using 32-byte transactions, the data should be aligned to 32 bytes and preferably not too fragmented, to request as few 32-byte segments as possible. Note that memory allocated through the CUDA API is guaranteed to be aligned to 256 bytes.
    - Special care should be taken to ensure that this is always done right.
    - Caching will typically mitigate the impact of unaligned memory accesses.
    - Thread block sizes that are multiple of the warp size (32) will give the most optimal alignments.
    - Older hardware coalesce accesses within half warps instead of the whole warp.
    - **TODO** More info.

#### Local Memory

- Memory local to each thread.
- Resides in (or next to) the global memory.
- Used when using more local data than what can fit in registers such that is spills over into local memory.
- Consecutive 4-byte words are accessed by consecutive thread IDs such that accesses are fully coalesced if all threads in the warp access the same relative address.

#### Shared Memory

- Resides in fast, high-bandwidth on-chip memory.
- Organized into banks which can be accessed concurrently. Each bank is accessed serially and multiple concurrent accesses to the same bank will result in a bank conflict.
- Declared using the `__shared__` variable qualifier. The size may be specified during kernel invocation.
- The scope is the lifetime of the block.
- **TODO** Shared between?

#### Constant Memory

- Read-only memory. **TODO** And?
- Resides in the special constant memory.
- Declared using the `__constant__` variable qualifier.

#### Managed Memory

- Data that may be accessed from both the host and the device (related to UVA).
- Shared by all GPUs.
- Declared using the `__managed__` variable qualifier.

#### Data Alignment

- Memory is accessed in 4, 8 or 16 byte transactions. (**TODO** 32 byte?)
- Accessing data with unaligned pointers generally incurs a performance hit, since it may fetch more segments than for aligned data or since it may prevent coalesced access.
- Related to e.g. global memory coalescing (described somewhere else on this page).
- Caching will typically mitigate somewhat the impact of unaligned memory accesses.
- Memory allocated through the CUDA API is guaranteed to be aligned to 256 bytes.
- Elements _within_ allocated arrays are generally not aligned unless special care is taken.
- To make sure array elements are aligned, use structs/classes with the `__align__(n)` qualifier and `n` as some multiple of the transaction sizes.

### Synchronization

- **TODO**
- `__syncthreads` provides block level barrier synchronization.
- Grid level barrier synchronization is currently not possible through any native API call.
- `cudaDeviceSynchronize`/`cudaStreamSynchronize` (host) blocks until the device or stream has finished all tasks (kernels/copies/etc.).

### Measurements

#### Time

- To measure the total duration of a kernel invocation or memory copy on the CPU side, measure the duration from before the call to after it, including a `cudaDeviceSynchronize()` if the call is asynchronous.
- To measure durations inside a kernel, use the CUDA event API (as used in this section hereafter).
- Events are created and destroyed using `cudaEventCreate(cudaEvent_t *)` and `cudaEventDestroy(cudaEvent_t *)`.
- Events are recorded (captured) using `cudaEventRecord`. This will capture the state of the stream it's applied to. The "time" of the event is when all previous tasks have completed and not the time it was called.
- Elapsed time between two events is calculated using `cudaEventElapsedTime`.
- Wait for an event to complete (or happen) using `cudaEventSynchronize`. For an event to "complete" means that the previous tasks (like a kernel) is finished executing. If the `cudaEventBlockingSync` flag is set for the event, the CPU will block while waiting (which yields the CPU), otherwise it will busy-wait.

#### Bandwidth

- To calculate the theoretical bandwidth, check the hardware specifications for the device, wrt. the memory clock rate and bus width and DDR.
- To measure the effective bandwidth, divide the sum of the read and written data by the measured total duration of the transfers.

#### Computational Throughput

- Measured in FLOPS (or "FLOP/s" or "flops"), separately for the type of precision (half, single, double).
- Measured by manually analyzing how many FLOPS a compoind operation is and then multiplied by how many times it was performed, divided by the total duration.
- Make sure it's not memory bound (or label it as so).

### Unified Virtual Addressing (UVA)

- Causes CUDA to use a single address space for allocations for both the host and all devices (as long as the host supports it).
- Requires a 64-bit application, Fermi-class or newer GPU and CUDA 4.0 or newer.
- Allows using `cudaMemcpy` without having to specify in which device (or host) and memory the pointer exists in. `cudaMemcpyDefault` replaces `cudaMemcpyHostToHost`, `cudaMemcpyHostToDevice`, `cudaMemcpyDeviceToHost`, and `cudaMemcpyDeviceToDevice`. Eliminates the need for e.g. `cudaHostGetDevicePointer`.
- Allows _zero-copy_ memory for managed/pinned memory. For unpinned host pages, CUDA must first copy the data to a temporary pinned set of pages before copying the data to the device. For pinned data, no such temporary buffer is needed (i.e. zero copies on the host side). The programmer must explicitly allocate data (or mark allocated data) as managed using `cudaMallocHost`/`cudaHostAlloc` and `cudaFreeHost`. `cudaMemcpy` works the same and automatically becomes zero-copy if using managed memory.
- The GPU can access pinned/managed host memory over the PCIe interconnect, but including the high latency and low bandwidth due to accessing off-device memory.
- While pinning memory results in improved transfers, pinning too much memory reduces overall system performance as the in-memory space for pageable memory becomes smaller. Finding a good balance may in some cases require some tuning.

### Unified Memory

- Depends on UVA, which provides a single address space for both the host and devices, as well as zero-copy memory.
- Virtually combines the pinned CPU/host memory and the GPU/device memory such that explicit memory copying between the two is no longer needed. Both the host and device may access the memory through a single pointer and data is automatically migrated (prefetched) between the two instead of demand-fetching it each time it's used (as for UVA).
- Data migration happens automatically at page-level granularuity and follows pointers in order to support deep copies. As it automatically migrates data to/from the devices instead of accessing it over the PCIe interconnect on demand, it yields much better performance than UVA.
- As Unified Memory uses paging, it implicitly allows oversubscribing GPU memory.
- Keep in mind that GPU page faulting will affect kernel performance.
- Unified Memory also provides support for system-wide atomic memory operations, for multi-GPU cooperative programs.
- Explicit memory management may still be used for optimization purposes, although use of streams and async copying is typically needed to actually increase the performance. `cudaMemPrefetchAsync` may be used to trigger a prefetch.
- `cudaMallocManaged` and `cudaFree` are used to allocate and deallocate managed memory.
- Since unified memory removes the need for `cudaMemcpy` when copying data back to the host after the kernel is finished, you may have to use e.g. `cudaDeviceSynchronize` to wait for the kernel to finish before accessing the managed data (instead of waiting for a `cudaMemcpy` to finish).
- While the Kepler and Maxwell architectures support a limited version of Unified Memory, the Pascal architecture is the first with hardware support for page faulting and migration via its Page Migration Engine. For the pre-Pascal architectures, _all_ managed data is automatically copied to the GPU right before lanuching a kernel on it, since they don't support page faulting for managed data currently present on the host or another device. This also means that Pascal and later includes memory copy delays in the kernel run time while pre-Pascal does not as everything is migrated before it begins executing (increasing the overall application runtime). This also prevents pre-Pascal GPUs from accessing managed data from both CPU and GPU concurrently (without causing segfaults) as it can't assure data coherence (although care must still be taken to avoid race conditions and data in invalid states for Pascal and later GPUs).

### Peer-to-Peer (P2P) Communication

- Based on UVA.
- Allows devices to directly access and transfer data to/from neighboring devices/peers, without any unnecessary copies.
- Significantly reduces latency since the host/CPU doesn't need to be involved and typically saturates PCIe bandwidth.
- Optionally, using NVLink or NVSwitch allows for significantly higher throughput for accesses/transfers than for PCIe.
- To check if peers can access eachother, use `cudaDeviceCanAccessPeer` (for each direction).
- To enable access between peers, use `cudaDeviceEnablePerAccess` (for the other device, within the context of the first device).

### Streams

- All device operations (kernels and memory operations) run sequentially in a single stream, which defaults to the "null stream" (stream 0) if none is specified.
- The null stream is synchronous with all other streams. The `cudaStreamNonBlocking` flag may be specified to other streams to avoid synchronizing with the null stream. CUDA 7 allows setting an option ("per-thread default stream") for changing the default behavior to (1) each host thread having a separate default stream and (2) default streams acting like regular streams (no longer synchronized with every other stream). To enable this, set `--default-stream per-thread` for `nvcc`. When enable, `cudaStreamLegacy` may be used if you need the old null stream for some reason.
- If using streams and the application is running less asynchronously than it should, make sure you're not (accidentally) using the null stream for anything.
- While streams are useful for decoupling and overlapping independent execution streams, the operations are still _somewhat_ performed in order (but potentially overlapping) on the device (on the different engines). Keep this in mind, e.g. when issuing multiple memory transfers for multiple streams.
- Streams allow for running asynchronous memory transfers and kernel execution at the same time, by running them in _different_, _non-default_ streams. For memory transfers, the memory must be managed/pinned. Take care _not_ to use the default stream as this will synchronize with everything.
- Streams are created with `cudaStreamCreate` and destroyed with `cudaStreamDestroy`.
- Memory transfers using streams requires using `cudaMemcpyAsync` (with the stream specified) instead of `cudaMemcpy`. The variants `cudaMemcpyAsync2D` and `cudaMemcpyAsync3D` may also be used for strided access.
- Kernels are issued within a stream by specifying teh stream as the fourth parameter (the third parameter may be set to `0` to ignore it).
- To wait for all operations for a stream and device to finish, use `cudaStreamSynchronize`. `cudaStreamQuery` may be used to query pending/unfinished operations without blocking. Events may also be used for synchronization. To wait for _all_ streams on a device, use the normal `cudaDeviceSynchronize` instead.

### Miscellanea

- When transferring lots of small data arrays, try to combine them. For strided data, try to use `cudaMemcpy2D` or `cudaMemcpy3D`. Otherwise, try to copy the small arrays into a single, temporary, pinned array.
- For getting device attributes/properties, `cudaDeviceGetAttribute` is significantly faster than `cudaGetDeviceProperties`.
- Use `cudaDeviceReset` to reset all state for the device by destroying the CUDA context.

## Tools

### CUDA-GDB

**TODO**

### CUDA-MEMCHECK

- For checking correctness and discovering memory bugs.
- Example usage: `cuda-memcheck --leak-check full <application>`

### nvprof

- For profiling CUDA applications.
- No longer supported for devices with compute capability 7.5 and higher. Use Nsight Compute instead.
- Example usage to show which CUDA calls and kernels tak the longest to run: `sudo nvprof <application>`
- Example usage to show interesting metrics: `sudo nvprof --metrics "eligible_warps_per_cycle,achieved_occupancy,sm_efficiency,alu_fu_utilization,dram_utilization,inst_replay_overhead,gst_transactions_per_request,l2_utilization,gst_requested_throughput,flop_count_dp,gld_transactions_per_request,global_cache_replay_overhead,flop_dp_efficiency,gld_efficiency,gld_throughput,l2_write_throughput,l2_read_throughput,branch_efficiency,local_memory_overhead" <application>`

### NVIDIA Visual Profiler (nvvp)

- **TODO** Seems like an older version of Nsight.

### Nsight

- For debugging and profiling applications.
- Comes as multiple variants:
    - Nsight Systems: For general applications. Should also be used for CUDA and graphics applications.
    - Nsight Compute: For CUDA applications.
    - Nsight Graphics: For graphical applications.
    - IDE integration.
- Replaces nvprof.

#### Installation

1. Download the run-files from the website for each variant (System, Compute, Graphics) you want.
1. Run the run-files with sudo.
1. **TODO** Fix path or something.

#### Usage

- When it reruns kernels for different tests, it restores the GPU state but not the host state. If this causes incorrect behavior, set `--replay-mode=application` to rerun the entire application instead.

{% include footer.md %}
