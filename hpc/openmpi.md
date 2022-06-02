---
title: Open MPI
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

A Message Passing Interface (MPI) implementation for C, Fortran, Java, etc.

## Resources

- [Frequently Asked Questions (OpenMPI)](https://www.open-mpi.org/faq/)

## Setup

### Linux

**Ubuntu (APT):**

1. (Prerequisite) Install buid tools: `apt install build-essetial`
1. Install OpenMPI binaries, docs and libs: `apt install openmpi-bin openmpi-doc libopenmpi-dev`

### Notes

- For optimal interconnect performance, use an RDMA interconnect like InfiniBand.

## Build

- Compile and link with `mpicc` (C) or `mpic++` (C++), which will include OpenMPI options and libs.
- (Optional) Setup IDE to include MPI libs:
    - VS Code: Set `{"C_Cpp.default.includePath": ["${myDefaultIncludePath}","/usr/lib/x86_64-linux-gnu/openmpi/include/"]}` in your project settings (`.vscode/settings.json` or `~/.config/Code/User/settings.json`).

## Run

- Run: `mpirun [opts] <app> [app_opts]`
- Set number of processes to use: `-n <n>`
- Allow more processes than physical cores: `--oversubscribe`
- Allow running as root (discouraged): `--allow-run-as-root`
- Specify which network type or subnet to use:
    - Specify/include IP subnet (TCP): `--mca btl_tcp_if_<include|exclude> <subnet|device>,...`
    - Disable TCP: `--mca btl ^tcp`
    - Specify BTLs exactly: `--mca btl self,vader,tcp`
    - *Something* (**TODO**): `--mca pml ob1`

### Slurm

This applies to cluster using the Slurm workload manager.

- `srun` may be used instead of `mpirun` to let Slurm run the tasks directly through the PMI2/PMIx APIs.
    - Unlike `mpirun`, this defaults to 1 process per node.
    - Specify `--mpi={pmi2|pmix}` to explicitly use PMI2 or PMIx.

## Miscellanea

- `PMI_SIZE` and `PMI_RANK` for PMI2, or `PMIX_RANK` for PMIx (no `PMIX_SIZE`), may be used to get the MPI works size and rank.

{% include footer.md %}
