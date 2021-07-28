---
title: CUDA
breadcrumbs:
- title: Software Engineering
- title: HPC
---
{% include header.md %}

Introduced by NVIDIA in 2006. While GPU compute was hackishly possible before CUDA through the fixed graphics pipeline, CUDA and CUDA-capable GPUs provided more somewhat more generalized GPU architecture and a programming model for GPU compute.

### Related Pages
{:.no_toc}

- [CUDA (configuration)](/config/config/hpc/cuda.md)

## TODO

- The _compute capability_ describes the generation and supported features of a GPU. **TODO** More info about `-code`, `-arch` etc.
- SM processing blocks/partitions same as warp schedulers?
- SM processing block datapaths.
- PTX.

## Hardware Architecture

- Modern CUDA-capable GPUs contain multiple types of cores:
    - CUDA cores: Aka programmable shading cores.
    - Tensor cores: Mostly for AI. **TODO** and _RT cores_ (for ray tracing). Tensor cores may be accessed in CUDA through special CUDA calls, but RT cores are (as of writing) only accessible from Optix.
- **TODO** SMs, GPCs, TPCs, warp schedulers, etc.

**TODO** Move "Mapping the Programming Model to the Execution Model" and "Thread Hierarchy" here?

### SMs and Blocks

- During kernel execution, each block gets assigned to a single SM. Multiple blocks may be assigned to the same SM.
- The maximum number of active blocks per SM is limited by one of the following:
    - Blocks and warps per SM: Both numbers are defined by the SM. For maximum theoretical occupancy, the blocks must together contain enough threads to fill the maximum number of warps per SM, without exceeding the maximum number of blocks per SM.
    - Registers per SM: The set of registers in an SM are shared by all active threads (from all active blocks on the SM), meaning that the amount of registers used by a threads may limit the occupancy. Since less registers per thread may considerably degrade performance, this is the main reason why too high occupancy is generally bad. The register count per thread is by default determined heuristically by the compiler to minimize register spilling to local memory, but `__launch_bounds__` may be used to assist the compiler with the allocation.
    - Shared memory per SM: Shared memory is shared between all threads of a single block (running on a single SM). Allocating a large amount of shared memory per block will limit the number of active blocks on the SM and therefore may implicitly limit occupancy if the blocks have few threads each. Allocating more memory away from shared memory and towards the L1 cache may also contribute to reduced occupancy.
- Blocks are considered _active_ from the time its warps have started executing until all warps have finished executing.

### Warp Schedulers and Warps

- Each SM consists of one or more warp schedulers.
- Warps consist of up to 32 threads from a block (for all current compute capabilities), i.e. the threads of a block are grouped into warps in order to get executed.
- A warp is considered active from the point its threads start executing until all threads have finished. SMs have a limit on the number of active warps, meaning the remaining inactive warps will need to wait until the current active ones are finished execuring. The ratio of active warps on an SM to the maximum number of active warps on the SM is called _occupancy_.
- Each warp scheduler has multiple warp slots which may be active (containing an _active_ warp) or _unused_.
- At most one warp is _selected_ (see states below) per clock per warp scheduler, which then executes a single instruction.
- Active warp states:
    - Stalled: It's waiting for instructions or data to load, or some other dependency.
    - Eligible: It's ready to get scheduled for execution.
    - Selected: It's eligible and has been selected for execution during the current clock.
- Branch divergence: Each warp scheduler (which an SM has one or more of) has only a single control unit for all cores within it, so for each branches any of the threads in the warp takes (added together), the warp scheduler and all of its cores will need to go through all of the branches but mask the output for all threads which were not meant to follow the branch. If no threads take a specific branch, it will not be executed by the warp scheduler.
- **TODO** scheduling policy?

## Programming

### General

- Host code and device code: Specifying the `__host__` keyword for a function means that it will be accessible by the host (the default if nothing is specified). Specifying the `__device__` keyword for a function means that it will be accessible by devices. Specifying both means it will be accessible by both.
- Kernels are specified as functions with the `__global__` keyword.
- Always check API call error codes and stop if not `cudaSuccess`. A macro may be defined and used to wrap the API call in to keep the code clean.

### Mapping the Programming Model to the Execution Model

- The programmer decides the grid size (number of blocks and threads therein) when launching a kernel.
- The device has a constant number of streaming multiprocessors (SMs) and CUDA cores (not to be confused with tensor cores or RT cores).
- Each kernel launch (or rather its grid) is executed by a single GPU. To use multiple GPUs, multiple kernel launches are required by the CUDA application.
- Each thread block is executed by a single SM and is bound to it for the entire execution. Each SM may execute multiple thread blocks.
- Each CUDA core within an SM executes a thread from a block assigned to the SM.
- **TODO** Warps and switches. 32 threads per warp for all current GPUs.

##### Thread Hierarchy

**TODO** Move into section below.

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
    - **TODO** Which memories have dedicated caches, which caches are write-through/read-only, which caches are shared by which units?
    - The register and shared memories are on-chip and fast, so they don't need to be cached.
- Resource contention:
    - The pool of registers and shared memory are shared by all active threads in an SM, such that the number of registers required per thread affects the number of active threads and the shared memory size allocated to a block affects the number of active blocks.

#### Register Memory

- The fastest thread-scope memory.
- Spills over into local memory.

#### Local Memory

- Memory local to each thread.
- Resides in (or next to) the global memory.
- Used when using more local data than what can fit in registers such that is spills over into local memory.
- Consecutive 4-byte words are accessed by consecutive thread IDs such that accesses are fully coalesced if all threads in the warp access the same relative address.

#### Shared Memory

- Shared between all threads of a block (block-local).
- The scope is the lifetime of the block.
- Resides in fast, high-bandwidth on-chip memory.
- Organized into banks which can be accessed concurrently. Each bank is accessed serially and multiple concurrent accesses to the same bank will result in a bank conflict.
- Declared using the `__shared__` variable qualifier. The size may be specified during kernel invocation.
- On modern devices, shared memory and the L1 cache resides on the same physical memory and the amount of memory allocated to each may be specified by the program.
- **TODO** Static (`__shared__`) and dynamic (specified during kernel invocation).

#### Global Memory

- The largest and slowest memory on the device.
- Resides in the GPU DRAM.
- Per-grid, accessible outside of kernels.
- Accessible by the host.
- The only memory threads from different blocks can share stored data in.
- Statically declared in global scope using the `__device__` declaration or dynamically allocated using `cudaMalloc`.
- Global memory coalescing: See the section about data alignment.

#### Constant Memory

- Read-only memory.
- Resides in the special constant memory.
- Per-grid, accessible outside of kernels.
- Accessible by the host.
- Declared using the `__constant__` variable qualifier.
- Multiple/all threads in a warps can access the same memory address simultaneously, but accesses to different addresses are serialized.

#### Texture Memory

**TODO**

#### Managed Memory

- Data that may be accessed from both the host and the device (related to UVA).
- Shared by all GPUs.
- Declared using the `__managed__` variable qualifier.

#### Data Alignment and Coalescing

- Accessing data with unaligned pointers generally incurs a performance hit, since it may fetch more segments than for aligned data or since it may prevent coalesced access.
- Caching will typically mitigate somewhat the impact of unaligned memory accesses.
- Memory allocated through the CUDA API is guaranteed to be aligned to 256 bytes.
- Elements _within_ allocated arrays are generally not aligned unless special care is taken.
- To make sure array elements are aligned, use structs/classes with the `__align__(n)` qualifier and `n` as some multiple of the transaction sizes.
- Memory access granularity is 32 bytes, called a sector. Global memory is accessed by the device using 32-, 64-, or 128-byte transactions, that are aligned to their size.
- When multiple threads in a warp access global memory in an _aligned_ and _sequential_ fashion (e.g. when all threads in the warp access sequential parts of an array), the device will try to _coalesce_ the access into as few 32-byte transactions as possible in order to reduce the number of transaction and  increase the ratio of useful to fetched data.
- Caching will typically mitigate the impact of unaligned memory accesses.
- Thread block sizes that are multiple of the warp size (32) will give the most optimal alignments.
- Older hardware coalesce accesses within half warps instead of the whole warp.
- To access strided data (like multidimensional arrays) in global memory, it may be better to first copy the data into shared memory (which is fast for all access patterns).
- Cache lines are 128 bytes, i.e. 4 sectors.

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

## Metrics

- **Occupancy** (group of metrics): The ratio of active warps on an SM to the maximum number of active warps on the SM. Low occupancy generally leads to poor instruction issue efficiency since there may not be enough eligible warps per clock to saturate the warp schedulers. Too high occupancy may also degrade performance as resources may be contend by threads. The occupancy should be high enough to hide memory latencies without causing considerable resource contention, which depends on both the device and application.
- **Theoretical occupancy** (theoretical metric): Maximum possible occupancy, limited by factors such as warps per SM, blocks per SM, registers per SM and shared memory per SM. This is computed statically without running the kernel.
- **Achieved occupancy** (`achieved_occupancy`): I.e. actual occupancy. Average occupancy of an SM for the whole duration it's active. Measured as the sum of active warps all warp schedulers for an SM for each clock cycle the SM is active, divided by number of clock cycles and then again divided by the maximum active warps for the SM. In addition to the reasons mentioned for theoretical occupancy, it may be limited due to unbalanced workload within blocks, unbalanced workload across blocks, too few blocks launched, and partial last wave (meaning that the last "wave" of blocks aren't enough to activate all warp schedulers of all SMs).
- **Issue slot utilization** (`issue_slot_utilization` or `issue_active`): The fraction of issued warps divided by the total number of cycles (e.g. 100% if one warp was issued per each clock for each warp scheduler).

## NVLink & NVSwitch

- Interconnect for connecting NVIDIA GPUs and NICs/HCAs as a mesh within a node, because PCIe was too limited.
- NVLink alone is limited to only eight GPUs, but NVSwitches allows connecting more.
- A bidirectional "link" consists of two unidirectional "sub-links", which each contain eight differential pairs (i.e. lanes). Each device may support multiple links.
- NVLink transfer rate per differential pair:
    - NVLink 1.0 (Pascal): 20Gb/s
    - NVLink 2.0 (Volta): 25Gb/s
    - NVLink 3.0 (Ampere): 50Gb/s

## Tools

### CUDA-GDB

**TODO**

### CUDA-MEMCHECK

- Part of the CUDA-MEMCHECK suite (consisting of Memcheck, Racecheck, Initcheck and Synccheck), now called the Compute Sanitizer suite.
- For checking correctness and discovering memory bugs.
- Example usage: `cuda-memcheck --leak-check full <application>`

### nvprof

- For profiling CUDA applications.
- Not supported for Ampere GPUs or later. Use Nsight Compute instead.
- Basic usage: `sudo nvprof [--metrics <comma-list>] <application>`
- Show available metrics for the available devices: `nvprof --query-metrics`

### NVIDIA Visual Profiler (nvvp)

- **TODO** Seems like an older version of Nsight.

### Nsight (Suite)

- For debugging and profiling applications.
- Requires a Turing/Volta or newer GPU.
- Comes as multiple variants:
    - Nsight Systems: For general profiling. Provides profiling information along a single timeline. Has less overhead, making it more appropriate for long-running instances with large datasets. May provide clues as to what to look into with Nsight Compute or Graphics.
    - Nsight Compute: For compute-specific profiling (CUDA). Isolates and profiles individual kernels (**TODO** for a single or all invocations?).
    - Nsight Graphics: For graphics-specific profiling (OpenGL etc.).
    - IDE integrations.
- The tools may be run either interactively/graphically through the GUIs, or through the command line versions to generate a report which can be loaded into the GUIs.

### Nsight Compute

#### Info

- [Nsight Compute: Kernel Profiling Guide (NVIDIA)](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html).
- Requires Turing/Volta or later.
- Replaces the much simpler nvprof tool.
- Supports stepping through CUDA calls.

#### Installation (Ubuntu)

- Nsight Systems and Compute comes with CUDA if installed through NVIDIA's repos.
- If it complains about something Qt, install `libqt5xdg3`.
- Access to performance counters:
    - Since access to GPU performance counters are limited to protect against side channel attacks (see [Security Notice: NVIDIA Response to “Rendered Insecure: GPU Side Channel Attacks are Practical” - November 2018 (NVIDIA)](https://nvidia.custhelp.com/app/answers/detail/a_id/4738)), it must be run either with sudo (or a user with `CAP_SYS_ADMIN`), or by setting a module option which disables the protection. For non-sensitive applications (e.g. for teaching), this protection is not required. See [NVIDIA Development Tools Solutions - ERR_NVGPUCTRPERM: Permission issue with Performance Counters (NVIDIA)](https://developer.nvidia.com/nvidia-development-tools-solutions-err_nvgpuctrperm-permission-issue-performance-counters) for more info.
    - Enable access for all users: Add `options nvidia "NVreg_RestrictProfilingToAdminUsers=0"` to e.g. `/etc/modprobe.d/nvidia.conf` and reboot.

#### Usage

- May be run from command line (`ncu`) or using the graphical application (`ncu-ui`).
- Running it may require sudo, `CAP_SYS_ADMIN` or disabling performance counter protection for the driver module. See the installation note above. If interactive Nsight ends without results or non-interactive or CLI Nsight shows some `ERR_NVGPUCTRPERM` error, this is typically the cause.
- May be run either in (non-interactive) profile mode or in interactive profile mode (with stepping for CUDA API calls).
- For each mode, the "sections" (profiling types) to run must be specified. More sections means it takes longer to profile as it may require running the kernel invocations multiple times (aka kernel replaying).
- Kernel replays: In order to run all profiling methods for a kernel execution, Nsight might have to run the kernel multiple times by storing the state before the first kernel execution and restoring it for every replay. It does not restore any host state, so in case of host-device communication during the execution, this is likely to put the application in an inconsistent state and cause it to crash or give incorrect results. To rerun the whole application (aka "application mode") instead of transparently replaying individual kernels (aka "kernel mode"), specify `--replay-mode=application` (or the equivalent option in the GUI).
- Supports NVTX (NVIDIA Tools Extension) for instrumenting the application in order to provide context/information around events and certain code.

{% include footer.md %}
