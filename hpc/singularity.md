---
title: Singularity
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

A container technology for HPC.

## Information

- For more general imformation and comparison to other HPC container technologies, see [Containers](/hpc/containers/).

## Configuration

**TODO**

## Usage

### Running

- Run command: `singularity exec <opts> <img> <cmd>`
- Run interactive shell: `singularity shell <opts> <img>`
- Mounts:
    - The current directory is mounted and used as the working directory by default.
- Env vars:
    - Env vars are copied from the host, but `--cleanenv` may be used to avoid that.
    - Extra can be specified using `--env <var>=<val>`.
- GPUs:
    - See extra notes.
    - Specify `--nv` (NVIDIA) or `--rocm` (AMD) to expose GPUs.

### Images

- Pull image from Docker repo: `singularity pull docker://<img>:<tag>`
    - Will place the image as a SIF file (`<image>_<tag>.sif`) in the current directory. It seems like this file can be safely deleted without affecting the "cached" version actually used.
    - If it gives a "'nodev' mount option set on /tmp" warning and then a "No space left on device" error, try this instead: `mkdir yolo && SINGULARITY_TMPDIR="$PWD/yolo" singularity pull docker://<img>:<tag> && rm -rf yolo`

### GPUs

- The GPU driver library must be exposed in the container and `LD_LIBRARY_PATH` must be updated.
- Specify `--nv` (NVIDIA) or `--rocm` (AMD) when running a container.

### MPI

- Using the "bind approach", where MPI and the interconnect is bind mounted into the container.
- MPI is installed in the container in order to build the application with dynamic linking.
- MPI is installed on the host such that the application can dynamically load it at run time.
- The MPI implementations must be of the same family and preferably the same version (for ABI compatibility). While MPICH, IntelMPI, MVAPICH and CrayMPICH use the same ABI, Open MPI does not comply with that ABI.
- When running the application, both the MPI implementation and the interconnect must be bind mounted into the container and and appropriate `LD_LIBRARY_PATH` must be provided for the MPI libraries. This may be statically configured by the system admin.

{% include footer.md %}
