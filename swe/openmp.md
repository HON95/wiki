---
title: OpenMP
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## General

- Use `default(firstprivate)`. The "default default" is `shared`, which may be inefficient, whereas `firstprivate` copies the initial value and then uses a local variable instead.

## Target Offloading

### Programming

**TODO** Cleanup.

- **TODO** `distribute`, `target data`
- For NVIDIA GPUs, OpenMP _teams_ are similar to _blocks_ and map to _SMs_, while OpenMP _threads_ (within teams) map to _CUDA cores_ (within SMs).
- `target`: Run the region on a device (GPU etc.). Only a single thread will be run if nothing more is specified. Often combined directly with `teams parallel`.
- `teams`: Spawn a league of teams (like CUDA blocks).
    - Each team will have an _initial_ thread which will execute the region.
    - Must be combined with or nested directly within a target region.
    - **TODO** Does this actually run the region with one thread in all teams?
- `parallel` (with `target`): Spawn threads withing the teams (like CUDA threads within the blocks).
    - Makes all threads within the teams execute the region.
    - May e.g. be specified for certain regions within a `target teams` region to control which parts should run with all threads and which should only be run by initial threads.
- Use `barrier` within parallel regions to synchronize.
- Use `target update ...` to update variables to/from device while inside a target region.
- Declare/define target function: Add `begin declare target` before and `#pragma omp end declare target` after. It can now be used by both host and target.
- Try to avoid using library math functions as they may contain a lot of CPU-specific code like AVX-instructions which won't work in offloaded regions.
- The host waits for target regions to finish. To run it asynchronously instead (as a task), specify `nowait`.
- `depend(in/out: <var>)` may be used to declare variable dependencies for regions, mainly for use with tasks (like `nowait` target regions).

#### Examples

- Run region with a set number of teams and threads:
    ```c
    // CUDA-equivalent: compute_stuff<<<1, 4>>>(args)
    #pragma omp target teams num_teams(1)
    {
        before_stuff();
        #pragma omp parallel num_threads(4) default(firstprivate)
        {
            compute_stuff(args);
        }
        after_stuff();
    }
    ```

### Building

- For GPU-offloaded OpenMP support, compile with e.g. `-fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target=nvptx64-nvidia-cuda -march=sm_86` (NVIDIA RTX 3090) or `-fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx1030` (AMD RX 6900 XT).
- For useful OpenMP-aware optimization debug info, compile with `-Rpass=openmp-opt -Rpass-missed=openmp-opt`. Use `-Rpass-analysis=openmp-opt` too for even more info.

### Miscellanea

- Run with `LIBOMPTARGET_INFO=1` to show runtime info like when kernels are executed on the devices.

{% include footer.md %}
