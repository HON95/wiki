---
title: OpenMP
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## General

- Use `default(firstprivate)`. The "default default" is `shared`, which may be inefficient, whereas `firstprivate` copies the initial value and then uses a local variable instead.

## Target Offloading

- **TODO** `target/device/teams/distribute/etc`
- Declare/define target function: Add `#pragma omp begin declare target` before and `#pragma omp end declare target` after. It can now be used by both host and target.
- Try to avoid using library math functions as they may contain a lot of CPU-specific code like AVX-instructions which won't work in offloaded regions.
- The host waits for target regions to finish. To run it asynchronously instead (as a task), specify `nowait`.
- `depend(in/out: <var>)` may be used to declare variable dependencies for regions, mainly for use with tasks and `nowait` target regions.
- Run region with a set number of teams (aka blocks in CUDA) and threads:
    ```c
    // CUDA-equivalent: compute_stucc<<<1, 4>>>(args)
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
- Use `#pragma omp target update ...` to update variables to/from device.
- `#pragma omp barrier` works inside target blocks too.

{% include footer.md %}
