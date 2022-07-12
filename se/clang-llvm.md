---
title: Clang/LLVM
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

LLVM is an extensive compiler platform and toolchain. It's typically used as the compiler backend, with Clang as the frontend.

### Related Pages
{:.no_toc}

- [GCC](../gcc/)

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
- Specify target OpenMP GPU platform/arch: `-fopenmp -fopenmp-targets=<platform> -Xopenmp-targets=<platform> -march <arch>`
    - Requires an LLVM-based compiler with proper OpenMP offloading support, like AMD ROCm's LLVM.
    - E.g. `-fopenmp -target x86_64-pc-linux-gnu -fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx1030` (AMD RX 6800 XT).
    - E.g. `-fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target=nvptx64-nvidia-cuda -march=sm_60` (NVIDIA V100)

## Hardware Offloading

### NVIDIA GPUs (CUDA/NVPTX)

- See: [LLVM: User Guide for NVPTX Back-end](https://llvm.org/docs/NVPTXUsage.html)
- Target triple: `nvptx64-nvidia-cuda` (64-bit)

{% include footer.md %}
