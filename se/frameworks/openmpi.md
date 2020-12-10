---
title: OpenMPI
breadcrumbs:
- title: Software Engineering
- title: Frameworks
---
{% include header.md %}

A Message Passing Interface (MPI) implementation for C, Fortran, Java, etc.

## Resources

- [Frequently Asked Questions (OpenMPI)](https://www.open-mpi.org/faq/)

## Installation

### Linux

**Ubuntu (APT):**

1. (Prerequisite) Install buid tools: `apt install build-essetial`
1. Install OpenMPI binaries, docs and libs: `apt install openmpi-bin openmpi-doc libopenmpi-dev`

## Build

- Compile and link with `mpicc` (C) or `mpic++` (C++), which will include OpenMPI options and libs.
- (Optional) Setup IDE to include MPI libs:
    - VS Code: Set `{"C_Cpp.default.includePath": ["${myDefaultIncludePath}","/usr/lib/x86_64-linux-gnu/openmpi/include/"]}` in your project settings (`.vscode/settings.json` or `~/.config/Code/User/settings.json`).

## Run

- Command: `mpirun [opts] <app> [app_opts]`
- Number of processes to use: `-n <n>`
- Allow more processes than physical cores: `--oversubscribe`
- Allow running as root (discouraged): `--allow-run-as-root`
- Run on a specific TCP/IP subnet: `-mca btl_tcp_if_include <subnet>`

{% include footer.md %}
