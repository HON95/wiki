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

## Tools

### CUDA-GDP

**TODO**

### Nsight Compute

- **TODO** Description
- When it reruns kernels for different tests, it restores the GPU state but not the host state. If this causes incorrect behavior, set `--replay-mode=application` to rerun the entire application instead.

### CUDA-MEMCHECK

- For checking correctness and discovering memory bugs.
- Example usage: `cuda-memcheck --leak-check full <application>`

### nvprof

- For profiling CUDA applications.
- No longer supported for devices with compute capability 7.5 and higher. Use Nsight Compute instead.
- Example usage to show which CUDA calls and kernels tak the longest to run: `sudo nvprof <application>`
- Example usage to show interesting metrics: `sudo nvprof --metrics "eligible_warps_per_cycle,achieved_occupancy,sm_efficiency,alu_fu_utilization,dram_utilization,inst_replay_overhead,gst_transactions_per_request,l2_utilization,gst_requested_throughput,flop_count_dp,gld_transactions_per_request,global_cache_replay_overhead,flop_dp_efficiency,gld_efficiency,gld_throughput,l2_write_throughput,l2_read_throughput,branch_efficiency,local_memory_overhead" <application>`

{% include footer.md %}
