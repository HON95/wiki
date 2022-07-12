---
title: CUDA
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

Introduced by NVIDIA in 2006. While GPU compute was hackishly possible before CUDA through the fixed graphics pipeline, CUDA and CUDA-capable GPUs provided more somewhat more generalized GPU architecture and a programming model for GPU compute.

### Related Pages
{:.no_toc}

- [HIP](../hip/)

## TODO

- The _compute capability_ describes the generation and supported features of a GPU. **TODO** More info about `-code`, `-arch` etc.
- SM processing blocks/partitions same as warp schedulers?
- SM processing block datapaths.
- PTX.

## Resources

- [NVIDIA: CUDA GPUs](https://developer.nvidia.com/cuda-gpus)
- [NVIDIA: CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)

## Setup

### Resources

- [NVIDIA: CUDA Installation Guide for Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [NVIDIA: CUDA Installation Guide for Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)
- [NVIDIA: CUDA Toolkit Download](https://developer.nvidia.com/cuda-downloads)

### Linux Installation

The toolkit on Linux can be installed in different ways:

- Through an an existing package in your distro's repos (simplest and most compatible with other packages, but may be outdated).
- Through a downloaded package manager package (up to date but may be incompatible with your installed NVIDIA driver).
- Through a runfile (same as previous but more cross-distro and harder to manage).

If an NVIDIA driver is already installed, it must match the CUDA version.

Downloads: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)

#### Ubuntu w/ NVIDIA's CUDA Repo

1. Follow the steps to add the NVIDIA CUDA repo: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
    - Use the "deb (network)" method, which will show instructions for adding the repo.
    - But don't install `cuda` yet.
1. (Optional) Remove anything NVIDIA or CUDA from the system to avoid conflicts: `apt purge --autoremove 'cuda' 'cuda-' 'nvidia-*' 'libnvidia-*'`
    - Warning: May break your PC. There may be better ways to do this.
    - This is sometimes required to fix broken CUDA updates etc.
1. Install CUDA from the new repo (includes the NVIDIA driver): `apt install cuda`
1. Setup PATH: `echo 'export PATH=$PATH:/usr/local/cuda/bin' | sudo tee -a /etc/profile.d/cuda.sh`

### Docker Containers

Docker containers may run NVIDIA applications using the NVIDIA runtime for Docker.

See [Docker](/config/virt-cont/docker/).

### DCGM

- Official NVIDIA solution for monitoring GPU hardware and performance.
- The DCGM exporter for Prometheus may be used for monitoring NVIDIA GPUs. It's standalone and doesn't require any other DCGM software to be installed.

## Usage

- Gathering system/GPU information with `nvidia-smi`:
    - Show overview: `nvidia-smi`
    - Show topology info: `nvidia-smi topo <option>` (e.g. `--matrix`)
    - Show NVLink info: `nvidia-smi  nvlink --status -i 0` (for GPU #0)
    - Monitor device stats: `nvidia-smi dmon`
- To specify which devices are available to the CUDA application and in which order, set the `CUDA_VISIBLE_DEVICES` env var to a comma-separated list of device IDs.

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
    - Enable access for all users: Add `options nvidia "NVreg_RestrictProfilingToAdminUsers=0"` to e.g. `/etc/modprobe.d/nvidia.conf` and reboot. You may need to run `update-initramfs -u` after editing the file and before rebooting (**TODO** verify).

#### Usage

- May be run from command line (`ncu`) or using the graphical application (`ncu-ui`).
- Running it may require sudo, `CAP_SYS_ADMIN` or disabling performance counter protection for the driver module. See the installation note above. If interactive Nsight ends without results or non-interactive or CLI Nsight shows some `ERR_NVGPUCTRPERM` error, this is typically the cause.
- May be run either in (non-interactive) profile mode or in interactive profile mode (with stepping for CUDA API calls).
- For each mode, the "sections" (profiling types) to run must be specified. More sections means it takes longer to profile as it may require running the kernel invocations multiple times (aka kernel replaying).
- Kernel replays: In order to run all profiling methods for a kernel execution, Nsight might have to run the kernel multiple times by storing the state before the first kernel execution and restoring it for every replay. It does not restore any host state, so in case of host-device communication during the execution, this is likely to put the application in an inconsistent state and cause it to crash or give incorrect results. To rerun the whole application (aka "application mode") instead of transparently replaying individual kernels (aka "kernel mode"), specify `--replay-mode=application` (or the equivalent option in the GUI).
- Supports NVTX (NVIDIA Tools Extension) for instrumenting the application in order to provide context/information around events and certain code.

## Troubleshooting

**"Driver/library version mismatch" and similar**:

Other related error messages from various tools:

- "Failed to initialize NVML: Driver/library version mismatch"
- "forward compatibility was attempted on non supported HW"

Caused by the NVIDIA driver being updated without the kernel module being reloaded.

Solution: Reboot.

## Hardware Architecture (Info)

- Modern CUDA-capable GPUs contain multiple types of cores:
    - CUDA cores: Aka programmable shading cores.
    - Tensor cores: Mostly for AI. **TODO** and _RT cores_ (for ray tracing). Tensor cores may be accessed in CUDA through special CUDA calls, but RT cores are (as of writing) only accessible from Optix.
- **TODO** SMs, GPCs, TPCs, warp schedulers, etc.

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

### Memories

- Hardware memories:
    - Register (on-chip, thread-level).
    - Local (off-chip, thread-level).
    - Shared (on-chip, block-level).
    - Global (off-chip, device-level).
    - Constant (**TODO**).
    - Texture (**TODO**).
    - **TODO** Caches.
See the programming section for more info about them.

### GPUDirect

- A family of technologies to facilitate direct GPU memory access to/from other devices (other GPUs, NICs/HBAs, etc.), bypassing the host/CPU.

#### GPUDirect Peer to Peer (P2P)

- Provides direct memory access between devices/GPUs in the same system.
- See the P2P communication section.

#### GPUDirect RDMA

- Provides direct memory access between devices/GPUs in separate systems.
- Requires a supported RDMA interconnect, e.g. using InfiniBand HCAs like NVIDIA ConnectX®-3 VPI or newer.
- In CUDA 11, the `nvidia-peermem` Linux kernel module is used to facilitate communication between NVIDIA Infiniband HCAs and NVIDIA GPUs.
- The PCIe devices (GPU and NIC/HCA) must share the same upstream PCI Express root complex for maximum performance. Going through CPU interconnects will limit the performance. Use a tool like `lstopo` to check the hardware topology.

#### GPUDirect Async

- Provides inter-node GPU control communication, to avoid having the CPU poll the GPU and HCA and schedule the next action when ready (i.e. removing the CPU from the critical path).
- The CPU still _prepares_ the network communication, but the GPU now _triggers_/_schedules_ it when ready.
- Meant to be used together with GPUDirect RDMA, such that the GPU tells the HCA directly to "do RDMA" to/from GPU memory.
- As an example, a ping-pong test over InfiniBand would previously require e.g. MPI send/receive in CPU code. With GPUDirect Async, all the send/receive may be moved into the GPU kernel, replacing MPI with e.g. LibGDSync/LibMP.
- [LibGDSync](https://github.com/gpudirect/libgdsync) implements GPUDirect Async support on InfiniBand verbs. [LibMP](https://github.com/gpudirect/libmp) is a technology demonstrator based on LibGDSync.

#### GPUDirect Storage

- Provides direct access to local storage (e.g. NVMe disks) or remote storage (e.g. NVMeOF).

### NVLink & NVSwitch

- Interconnect for connecting NVIDIA GPUs and NICs/HCAs as a mesh within a node, because PCIe was too limited.
- NVLink alone is limited to only eight GPUs, but NVSwitches allows connecting more.
- A bidirectional "link" consists of two unidirectional "sub-links", which each contain eight differential pairs (i.e. lanes). Each device may support multiple links.
- NVLink transfer rate per differential pair:
    - NVLink 1.0 (Pascal): 20Gb/s
    - NVLink 2.0 (Volta): 25Gb/s
    - NVLink 3.0 (Ampere): 50Gb/s
- Some CPUs like IBM POWER9 have build-in NVLink in addition to PCIe.
- **TODO** Hopper updates.

## Programming (Info)

### General

- Host code and device code: Specifying the `__host__` keyword for a function means that it will be accessible by the host (the default if nothing is specified). Specifying the `__device__` keyword for a function means that it will be accessible by devices. Specifying both means it will be accessible by both.
- Kernels are specified as functions with the `__global__` keyword.
- Always check API call error codes and stop if not `cudaSuccess`. A macro may be defined and used to wrap the API call in to keep the code clean.

### Thread Hierarchy

- Grids consist of a number of blocks and blocks concist of a number of threads.
- Threads and blocks are indexed in 1D, 2D or 3D space (separately), which threads may access through the 3-compoent vectors `blockDim`, `blockIdx` and `threadIdx`.
- The programmer decides the number of grids, blocks and threads to use, as well as the number of dimensions to use, for each kernel invocation.
- The number of threads per block is typically limited to 1024.
- The programmer decides the grid size (number of blocks and threads therein) when launching a kernel.
- The device has a constant number of streaming multiprocessors (SMs) and CUDA cores (not to be confused with tensor cores or RT cores).
- Each kernel launch (or rather its grid) is executed by a single GPU. To use multiple GPUs, multiple kernel launches are required by the CUDA application.
- Each thread block is executed by a single SM and is bound to it for the entire execution. Each SM may execute multiple thread blocks.
- Each CUDA core within an SM executes a thread from a block assigned to the SM.
- **TODO** Warps and switches. 32 threads per warp for all current GPUs.

### Synchronization

- **TODO**
- `__syncthreads` provides block level barrier synchronization. Is must never be used in divergent code.
- Grid level barrier synchronization is currently not possible through any native API call.
- `cudaDeviceSynchronize`/`cudaStreamSynchronize` (host) blocks until the device or stream has finished all tasks (kernels/copies/etc.).
- **TODO** Streams, cooperative groups, etc.

### Contexts

- CUDA contexts contains the CUDA state and generally maps one-to-one with the devices in the system.
- Contexts are created and switched on-demand, e.g. using `cudaSetDevice()`.
- Contexts contain state like memory allocations, streams, events etc. Destroying a context automatically destroys the state kept within it.

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

### Memories

#### Memory Hierarchy

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
- Spills over into local memory (off-chip), which should be avoided to prevent potentially severe performance degregation.

#### Local Memory

- Memory local to each thread.
- Resides in (or next to) the global memory.
- Used when using more local data than what can fit in registers such that is spills over into local memory.
- Consecutive 4-byte words are accessed by consecutive thread IDs such that accesses are fully coalesced if all threads in the warp access the same relative address.

#### Shared Memory

- Shared between all threads of a block (block-local).
- The scope is the lifetime of the block.
- Resides in fast, high-bandwidth, on-chip memory.
- Organized into interleaved banks (originally 32 bits wide), such that large accesses hit multiple banks. Bank size (width) on newer compute capabilities may be set using `cudaDeviceSetSharedMemConfig()` to either 32 or 64 bits.
- Separate banks can be accessed concurrently, yielding higher total bandwidth. Multiple concurrent accesses to different addresses within a bank will result in a bank conflict and serial access to it, but multiple (read) accesses to the _same_ address within the bank will result in a broadcase (effectively concurrent access).
- On modern devices, shared memory and the L1 cache resides on the same physical memory and the amount of memory allocated to each may be specified by the program.
- Variable allocation:
    - The variable size may be specified at compile-time (static) or during kernel invocation (dynamic).
    - Both static and dynamic use the `__shared__` variable qualifier.
    - Static allocation: Variables are specified as a constant-sized array (e.g. `__shared__ int data[64]`)
    - Dynamic allocation: A single variable is specified as extern array without an explicit size (e.g. `extern __shared__ int data[]`). The size is provided during kernel invocation in the angle brackets. Only one such variable can exist, if you need more then you must partition that variable in some way.

#### Global Memory

- The largest and slowest memory on the device.
- Resides in the GPU DRAM (off-chip).
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
- Variables are declared using the `__constant__` variable qualifier.
- Multiple/all threads in a warps can access the same memory address simultaneously, but accesses to different addresses are serialized.

#### Texture Memory

**TODO**

### Data Alignment

- Aligning data to the memory or data types it's stored in generally gives better data access performance.
- Unaligned data may lead to wasted space and effectlively more data that needs to be transfered, and it may prevent memory access coalescing (se explanation below).
- Caching will typically mitigate somewhat the impact of unaligned memory accesses.
- Memory allocated through the CUDA API is guaranteed to be aligned to 256 bytes.
- Elements _within_ allocated arrays are generally not aligned unless done explicitly by the programmer.
- To make sure array elements are aligned, use structs/classes with the `__align__(n)` qualifier and `n` as some multiple of the transaction sizes.
- Memory access granularity is 32 bytes, called a sector. Global memory is accessed by the device using 32-, 64-, or 128-byte transactions that are aligned to their size.
- Cache lines are 128 bytes, i.e. 4 sectors.
- When multiple threads in a warp access global memory in an _aligned_ and _sequential_ fashion (e.g. when all threads in the warp access sequential parts of an array), the device will try to _coalesce_ the access into as few transactions as possible in order to reduce the number of transactions and increase the ratio of useful to fetched data.
- Thread block sizes that are multiple of the warp size (32) will give the most optimal alignments.
- Older hardware coalesces accesses within half warps instead of the whole warp.
- To access strided data (like components from multidimensional arrays) in global memory, it may be better to first copy the data into shared memory.

### Managed Data

- Managed data may be accessed from the host and all devices.
- Data/cache coherence is handled by hardware and the driver.
- Uses the Unified Virtual Addressing (UVA) and Unified Memory technologies, see below for more info.

#### Unified Virtual Addressing (UVA)

- Introduced in CUDA 4 and compute capability 2.0.
- Causes CUDA to use a single virtual address space for allocations for both the host and all devices.
- For UVA to apply, managed memory (i.e. pinned/page-locked memory) is used.
- Managed memory (for UVA) is allocated on the host with `cudaHostAlloc()` and deallocated with `cudaFreeHost()`. Host memory allocated through other non-CUDA means may become managed using `cudaHostRegister()`. (Note that Unified Memory uses `cudaMallocManaged` and `cudaFree` instead.)
- By default, memory allocations are usable within the active CUDA context only (i.e. the current device only). To make it portable (usable by all contexts), use the `cudaHostAllocPortable` flag with `cudaHostAlloc()` or the `cudaHostRegisterPortable` flag with `cudaHostRegister()`.
- Allows using `cudaMemcpy` for managed data without having to specify in which device (or host) the data is located in. The `cudaMemcpy{Host,Device}To{Host,Device}` memory copy directions may be replaced by `cudaMemcpyDefault`. It also eliminates the need for e.g. `cudaHostGetDevicePointer`.
- `cudaPointerGetAttributes` may be used with managed data to get info about which host/device the data is allocated on and if it's managed.
- `cudaMemcpy` automatically becomes zero-copy for managed memory. This is because managed memory is pinned so no extra, pinned buffer must be allocated on the host during the transfer.
- The device can directly access managed host memory (aka zero-copy access), but with a significant performance penalty. However, for certain cases where small amounts of data from the host are used only once, this direct access may give better performance than copying the data to the device before accessing it.
- Managed memory may result in improved data migration, but using too much of it might reduce overall system performance as it might fill up the physical memory on the host with pinned pages and leave little room for pageable memory.

#### Unified Memory

- Introduced in CUDA 6 and compute capability 6.0 (limited support in lower compute capabilities).
- Based on UVA, which provides a single virtual address space for both the host and devices, as well as zero-copy memory when using managed/pinned memory.
- Extends UVA with automatic, on-demand page migration, removing the need for explicit memory copying.
- Data migration happens automatically at page-level granularuity and follows pointers in order to support deep copies.
- As unified memory uses paging on the device, it implicitly allows oversubscribing GPU memory, where device pages are evicted to host memory and host pages are fetched to device memory.
- Unified memory also provides support for system-wide atomic memory operations, for multi-GPU cooperative programs.
- Explicit memory management may still be used for optimization purposes. Use of streams and async copying is typically needed to actually increase the performance. But keep in mind that explicit memory management is error-prone and tracking down bugs may significantly reduce productivity, despite the slightly better performance in the end.
- The litterature may be a little unclear when talking about "managed memory" here. In this context, "managed memory" may specifically mean memory allocations supporting Unified Memory.
- `cudaMallocManaged` and `cudaFree` are used to allocate and deallocate managed memory for Unified Memory.
- To assist automatic migration, `cudaMemPrefetchAsync` may be used to trigger a prefetch and `cudaMemAdvise` may be used to provide hints for data locality wrt. a specific managed memory allocation. `cudaMemPrefetchAsync` may be run concurrently in a separate stream, although it may exhibit sequential or blocking behaviour sometimes (unlike e.g. the explicit `cudaMemcpyAsync`). The `cudaMemAdviseSetReadMostly` hint automatically duplicates data that is used by multiple devices.
- Since unified memory removes the need for `cudaMemcpy` when copying data back to the host after the kernel is finished, you may have to use e.g. `cudaDeviceSynchronize` to wait for the kernel to finish before accessing the managed data.
- While the Kepler and Maxwell architectures support a limited version of Unified Memory, the Pascal architecture (compute capability 6.0) is the first with hardware support for page faulting and on-demand page migration via its page migration engine. Volta introduces better access counters to migrate less naively and reduce thrashing. For the pre-Pascal architectures, _all_ allocated space is allocated in physical GPU memory (no oversubscription). All data accesses by the CPU is page faulted and fetched from GPU memory to system memory and all managed data present in system memory is automatically migrated to the GPU right before lanuching a kernel on it (never during execution, since the GPUs don't have a page fualt engine). This also means that Pascal and later includes memory copy delays in the kernel run time while pre-Pascal does not as everything is migrated before it begins executing (increasing the overall application runtime). This also prevents pre-Pascal GPUs from accessing managed data from both host and device concurrently, as it can't assure data coherence (although care must still be taken to avoid race conditions and data in invalid states for Pascal and later GPUs).

### Peer-to-Peer (P2P) Communication

- Allows devices to directly access and transfer data to/from neighboring devices/peers over PCIe or NVLink, without going through the host. This significantly reduces latency since the host/CPU doesn't need to be involved and it typically saturates PCIe bandwidth.
- Uses UVA and GPUDirect P2P internally.
- To check if peers can access eachother, use `cudaDeviceCanAccessPeer` (for each direction).
- To enable access between peers, use `cudaDeviceEnablePerAccess` (for the other device within the context of the first device).
- With UVA, `cudaMemcpy()` with `cudaMemcpyDefault` may be used instead of the older `cudaMemcpyPeer` variants. It supports Unified Memory with implicit copying too.

### CUDA-Aware MPI

- Provides memory transfers directly to/from device/GPU memory instead of copying it through the host/CPU.
- Based on UVA plus GPUDirect P2P (intra-node) and GPUDirect RDMA (inter-node).
- Requirements:
    - Requires CUDA 5 and a Kepler-class GPU or newer. May require a Tesla or Quadro GPU (at least for Kepler).
    - Requires a supported MPI implementation. e.g. Open MPI 1.7 or later.
    - See the GPUDirect P2P and RDMA sections for info and requirements. (GPUDirect RDMA/P2P is optimal but not required.)
- Implicitly allows using any UVA pointers directly in MPI calls, regardless of where the allocation resides.
- If GPUDirect P2P or RDMA is _not_ available, the buffer will be copied through host memory, typically through both a CUDA (pinned) and a fabric buffer.
- If the MPI implementation is _not_ CUDA-aware, the buffer will be copied through host memory, typically through a CUDA buffer, a host buffer and a fabric buffer. An explicit `cudaMemcpy` is required. CUDA streams and async copying should be used.

### Miscellanea

- When transferring lots of small data arrays, try to combine them. For strided data, try to use `cudaMemcpy2D` or `cudaMemcpy3D`. Otherwise, try to copy the small arrays into a single, temporary, pinned array.
- For getting device attributes/properties, `cudaDeviceGetAttribute` is significantly faster than `cudaGetDeviceProperties`.
- Use `cudaDeviceReset` to reset all state for the device by destroying the CUDA context.

## Performance Measurements (Info)

### Time Measurements

- To measure the total duration of a kernel invocation or memory copy on the CPU side, measure the duration from before the call to after it, including a `cudaDeviceSynchronize()` if the call is asynchronous.
- To measure durations inside a kernel, use the CUDA event API (as used in this section hereafter).
- Events are created and destroyed using `cudaEventCreate(cudaEvent_t *)` and `cudaEventDestroy(cudaEvent_t *)`.
- Events are recorded (captured) using `cudaEventRecord`. This will capture the state of the stream it's applied to. The "time" of the event is when all previous tasks have completed and not the time it was called.
- Elapsed time between two events is calculated using `cudaEventElapsedTime`.
- Wait for an event to complete (or happen) using `cudaEventSynchronize`. For an event to "complete" means that the previous tasks (like a kernel) is finished executing. If the `cudaEventBlockingSync` flag is set for the event, the CPU will block while waiting (which yields the CPU), otherwise it will busy-wait.

### Memory Throughput Measurements

- To calculate the theoretical bandwidth, check the hardware specifications for the device, wrt. the memory clock rate, bus width and if using DDR.
- To measure the effective bandwidth, divide the sum of the read and written data by the measured total duration of the transfers.
- Remember bit-byte-conversion.

### Computational Throughput Measurements

- Measured in FLOPS (or "FLOP/s" or "flops"), separately for the type of precision (half, single, double).
- Measured by manually analyzing how many FLOPS a compoind operation is (e.g. a multiply-add could count as two) and then multiplied by how many times it was performed, divided by the total duration.
- Make sure it's not memory bound (or label it as so).

### Metrics

- **Occupancy** (group of metrics): The ratio of active warps on an SM to the maximum number of active warps on the SM. Low occupancy generally leads to poor instruction issue efficiency since there may not be enough eligible warps per clock to saturate the warp schedulers. Too high occupancy may also degrade performance as resources may be contend by threads. The occupancy should be high enough to hide memory latencies without causing considerable resource contention, which depends on both the device and application.
- **Theoretical occupancy** (theoretical metric): Maximum possible occupancy, limited by factors such as warps per SM, blocks per SM, registers per SM and shared memory per SM. This is computed statically without running the kernel.
- **Achieved occupancy** (`achieved_occupancy`): I.e. actual occupancy. Average occupancy of an SM for the whole duration it's active. Measured as the sum of active warps all warp schedulers for an SM for each clock cycle the SM is active, divided by number of clock cycles and then again divided by the maximum active warps for the SM. In addition to the reasons mentioned for theoretical occupancy, it may be limited due to unbalanced workload within blocks, unbalanced workload across blocks, too few blocks launched, and partial last wave (meaning that the last "wave" of blocks aren't enough to activate all warp schedulers of all SMs).
- **Issue slot utilization** (`issue_slot_utilization` or `issue_active`): The fraction of issued warps divided by the total number of cycles (e.g. 100% if one warp was issued per each clock for each warp scheduler).

{% include footer.md %}
