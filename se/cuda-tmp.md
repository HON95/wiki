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
- **TODO** Warps and switches.

## Programming

### General

- Branching:
    - **TODO** How branching works and why it's bad.

### Thread Hierarchy

- Grids consist of a number of blocks and blocks concist of a number of threads.
- Threads and blocks are indexed in 1D, 2D or 3D space (separately), which threads may access through the 3-compoent vectors `blockDim`, `blockIdx` and `threadIdx`.
- The programmer decides the number of grids, blocks and threads to use, as well as the number of dimensions to use, for each kernel invocation.
- The number of threads per block is typically limited to 1024.
- See the section about mapping it to the execution model for a better understanding of why it's organized this way.

### Memory Hierarchy

- **TODO**
- Memories (local to global):
    1. **TODO** Fix, these names are wrong.
    1. Registers.
    1. Shared memory (block cache).
    1. Read-only memories.
    1. SM cache.
    1. Global memory.

### Synchronization

- **TODO**
- `__syncthreads` (device) provides block level barrier synchronization.
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

- Causes CUDA to use a single address space for allocations for both the host and devices (if the host supports it).
- Allows using `cudaMemcpy` without having to spacify in which device (or host) and memory the pointer exists in.
- Allows _zero-copy_ memory where the GPU can access pinned/managed host memory over the PCIe interconnect (including the high latency for accessing off-device memory).

### Unified Memory

- Depends on the older UVA, which provides a single address space for both the host and devices, as well as zero-copy memory.
- Virtually combines the pinned CPU/host memory and the GPU/device memory such that explicit memory copying between the two is no longer needed. Both the host and device may access the memory through a single pointer and data is automatically migrated (prefetched) between the two instead of demand-fetching it each time it's used (as for UVA).
- Data migration happens automatically at page-level granularuity and follows pointers in order to support deep copies. As it automatically migrates data to/from the devices instead of accessing it over the PCIe interconnect on demand, it yields much better performance than UVA.
- As Unified Memory uses paging, it implicitly allows oversubscribing GPU memory.
- Keep in mind that GPU page faulting will affect kernel performance.
- Unified Memory also provides support for system-wide atomic memory operations, for multi-GPU cooperative programs.
- Explicit memory management may still be used for optimization purposes, although use of streams and async copying is typically needed to actually increase the performance.
- `cudaMallocManaged` and `cudaFree` are used to allocate and deallocate managed memory.
- Since unified memory removes the need for `cudaMemcpy` when copying data back to the host after the kernel is finished, you may use e.g. `cudaDeviceSynchronize` to wait for the kernel to finish before accessing the managed data.
- While the Kepler and Maxwell architectures support a limited version of Unified Memory, the Pascal architecture is the first with hardware support for page faulting and migration via its Page Migration Engine. For the pre-Pascal architectures, _all_ managed data is automatically copied to the GPU right before lanuching a kernel on it, since they don't support page faulting for managed data currently present on the host or another device. This also means that Pascal and later includes memory copy delays in the kernel run time while pre-Pascal does not as everything is migrated before it begins executing (increasing the overall application runtime). This also prevents pre-Pascal GPUs from accessing managed data from both CPU and GPU concurrently (without causing segfaults) as it can't assure data coherence (although care must still be taken to avoid race conditions and data in invalid states for Pascal and later GPUs).
- Explicit prefetching may be used to assist the data migration through the `cudaMemPrefetchAsync` call.

### Streams

- **TODO**
- If no stream is specified, it defaults to stream 0, aka the "null stream".

## Tools

**TODO** Add stuff from other document.

### Nsight

- For debugging and profiling applications.
- Comes as multiple variants:
    - Nsight Systems: For general applications. Should also be used for CUDA and graphics applications.
    - Nsight Compute: For CUDA applications.
    - Nsight Graphics: For graphical applications.
    - IDE integration.
- Replaces nvprof.
