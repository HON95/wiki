---
title: Clang/LLVM
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

LLVM is an extensive compiler platform and toolchain. It's typically used as the compiler backend, with Clang as the frontend.

### Related Pages
{:.no_toc}

- [GCC](/swd/gcc/)

## Usage

- **TODO** Compilation (C++): `g++ ${CPPFLAGS} ${CXXFLAGS} -c -o file1.o file1.cpp`
- **TODO** Linking (C++): `g++ ${LDFLAGS} ${LDLIBS} -o app file1.o file2.o`
- Show supported targets

## Options

### Platform

- Specify target CPU platform: `-target <platform>`
    - E.g. `-target x86_64-unknown-linux-gnu`.
    - This is generally needed only if cross-compiling, the default will be a target fitting the local computer.
    - Use `llc --version` to show supported platforms.

## Hardware Offloading

### OpenMP Offloading

- Specify target OpenMP GPU platform/arch: `-fopenmp -fopenmp-targets=<platform> -Xopenmp-targets=<platform> -march <arch>`
    - Requires an LLVM-based compiler with proper OpenMP offloading support, like AMD ROCm's LLVM.
    - E.g. `-fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx1030` (AMD RX 6800 XT).
    - E.g. `-fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target=nvptx64-nvidia-cuda -march=sm_70` (NVIDIA V100)
- Emit optimization diagnostics during compilation:
    - `-Rpass=...`: When a pass makes a transformation.
    - `-Rpass-missed=...`: When a pass fails a transformation.
    - `-Rpass-analysis=...`: More info about whether or not to make a transformation.
    - The options take a regex to match which optimization pass to show (use `'.*'` to match all).
- Show runtime debug info: `LIBOMPTARGET_INFO=1`

### NVIDIA GPUs (CUDA/NVPTX)

- See: [LLVM: User Guide for NVPTX Back-end](https://llvm.org/docs/NVPTXUsage.html)
- Target triple: `nvptx64-nvidia-cuda` (64-bit)

{% include footer.md %}
