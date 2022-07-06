---
title: HIP
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

HIP (**TODO** abbreviation) is AMD ROCm's runtime API and kernel language, which is compilable for both AMD (through ROCm) and NVIDIA (through CUDA) GPUs.
Compared to OpenCL (which is also supported by both NVIDIA and AMD), it's much more similar to CUDA (making it _very_ easy to port CUDA code) and allows using existing profiling tools and similar for CUDA and ROCm.

### Related Pages
{:.no_toc}

- [ROCm](../rocm/)
- [CUDA](../cuda/)

## Resources

- [HIP Installation (AMD ROCm Docs)](https://rocmdocs.amd.com/en/latest/Installation_Guide/HIP-Installation.html)

## Info

- HIP code can be compiled for AMD ROCm using the HIP-Clang compiler or for CUDA using the NVCC compiler.
- If using both CUDA with an NVIDIA GPU and ROCm with an AMD GPU in the same system, HIP seems to prefer ROCm with the AMD GPU when building application. I found not way of changing the target platform (**TODO**).

## Setup (Debian)

### Install for AMD GPUs

1. Install the ROCm suite (contains HIP and other useful stuff): See [ROCm](../rocm/).

### Install for NVIDIA GPUs

Updated for ROCm 5.0.

1. Install the CUDA toolkit and the NVIDIA driver: See [CUDA](../cuda/).
1. Add the ROCm package repo:
    1. Install requirements: `sudo apt install curl libnuma-dev wget gnupg2`
    1. Add repo key: `curl -sSf https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor --output /usr/share/keyrings/rocm.gpg`
    1. Add ROCm repo: `echo 'deb [signed-by=/usr/share/keyrings/rocm.gpg arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list`
    1. Update cache: `sudo apt update`
1. Install: `sudo apt install hip-dev hip-doc hip-runtime-nvidia`
1. Add ROCm to PATH: `echo 'export PATH=$PATH:/opt/rocm/bin' | sudo tee /etc/profile.d/rocm.sh` (relog to reload)

### Post-Install Verification

1. Verify installation: `hipconfig --full`
1. (Optional) Try to build a HIP sample program:
    1. `git clone https://github.com/ROCm-Developer-Tools/HIP`
    1. `cd HIP/samples/0_Intro/square`
    1. `make`
    1. `./square.out`

## Usage and Tools

- Show system info:
    - Show HIP details: `hipconfig --full`
    - Show platform (`amd` or `nvidia`): `hipconfig --platform`
- Convert CUDA program to HIP: `hipify-perl input.cu > output.cpp`

{% include footer.md %}
