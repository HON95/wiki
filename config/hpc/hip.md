---
title: HIP
breadcrumbs:
- title: Configuration
- title: High-Performance Computing (HPC)
---
{% include header.md %}

HIP (**TODO** abbreviation) is AMD ROCm's runtime API and kernel language, which is compilable for both AMD (through ROCm) and NVIDIA (through CUDA) GPUs.
Compared to OpenCL (which is also supported by both NVIDIA and AMD), it's much more similar to CUDA (making it _very_ easy to port CUDA code) and allows using existing profiling tools and similar for CUDA and ROCm.

### Related Pages
{:.no_toc}

- [ROCm](/config/hpc/rocm/)
- [CUDA](/config/hpc/cuda/)

## Resources

- [HIP Installation (AMD ROCm Docs)](https://rocmdocs.amd.com/en/latest/Installation_Guide/HIP-Installation.html)

## Info

- HIP code can be compiled for AMD ROCm using the HIP-Clang compiler or for CUDA using the NVCC compiler.
- If using both CUDA with an NVIDIA GPU and ROCm with an AMD GPU in the same system, HIP seems to prefer ROCm with the AMD GPU when building application. I found not way of changing the target platform (**TODO**).

## Setup

### Linux Installation (Debian)

#### Common Steps Before

1. Add the ROCm package repo (overlaps with ROCm installation):
    1. Install requirements: `sudo apt install libnuma-dev wget gnupg2`
    1. Add public key: `wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -`
    1. Add repo: `echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list`
    1. Update cache: `sudo apt update`

#### Steps for NVIDIA Paltforms

1. Install the CUDA toolkit and the NVIDIA driver: See [CUDA](/config/hpc/cuda/).
1. Install: `sudo apt install hip-nvcc`

#### Steps for AMD Paltforms

1. Install stuff: `sudo apt install mesa-common-dev clang comgr`
1. Install ROCm: See [ROCm](/config/hpc/rocm/).

#### Common Steps After

1. Fix symlinks and PATH:
    - (NVIDIA platforms only) CUDA symlink (`/usr/local/cuda`): Should already point to the right thing.
    - (AMD platforms only) ROCm symlink (`/opt/rocm`): `sudo ln -s /opt/rocm-4.2.0 /opt/rocm` (example)
    - Add to PATH: `echo 'export PATH=$PATH:/opt/rocm/bin:/opt/rocm/rocprofiler/bin:/opt/rocm/opencl/bin' | sudo tee -a /etc/profile.d/rocm.sh`
1. Verify installation: `/opt/rocm/bin/hipconfig --full`
1. (Optional) Try to build the square example program: [square (ROCm HIP samples)](https://github.com/ROCm-Developer-Tools/HIP/tree/master/samples/0_Intro/square)

## Usage and Tools

- Show system info:
    - Show lots of HIP stuff: `hipconfig --config`
    - Show platform (`amd` or `nvidia`): `hipconfig --platform`
- Convert CUDA program to HIP: `hipify-perl input.cu > output.cpp`

{% include footer.md %}
