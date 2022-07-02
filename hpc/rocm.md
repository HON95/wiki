---
title: ROCm
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

AMD ROCm (Radeon Open Compute), for programming AMD GPUs. AMD's alternative to NVIDIA's CUDA toolkit.
It uses the runtime API and kernel language HIP, which is compilable for both AMD and NVIDIA GPUs.

### Related Pages
{:.no_toc}

- [HIP](/config/hpc/hip/)

## Resources

- [ROCm Documentation (AMD ROCm Docs)](https://rocmdocs.amd.com/)
- [ROCm Installation (AMD ROCm Docs)](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html)
- [ROCm_Installation_Guidev5.0: How To Install ROCm](https://docs.amd.com/bundle/ROCm_Installation_Guidev5.0/page/How_To_Install_ROCm.html)

## Setup

Updated for ROCm 5.0.

### Installation (Debian/Ubuntu)

#### Steps

1. If the `amdgpu-pro` driver is installed then uninstall it to avoid conflicts. **TODO**
1. If using Mellanox ConnectX NICs then Mellanox OFED must be installed before ROCm.
1. Add the ROCm package repo:
    1. Install requirements: `sudo apt install curl libnuma-dev wget gnupg2`
    1. Add repo key: `curl -sSf https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor --output /usr/share/keyrings/rocm.gpg`
    1. Add AMDGPU repo: `echo 'deb [signed-by=/usr/share/keyrings/rocm.gpg arch=amd64] https://repo.radeon.com/amdgpu/latest/ubuntu focal main' | sudo tee /etc/apt/sources.list.d/amdgpu.list`
    1. Add ROCm repo: `echo 'deb [signed-by=/usr/share/keyrings/rocm.gpg arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list`
    1. Update cache: `sudo apt update`
1. Install extras: `sudo apt install mesa-common-dev clang comgr`
1. Install kernel-mode GPU driver: `sudo apt install amdgpu-dkms`
1. Install desired ROCm meta-packages: `sudo apt install <meta-packages>`
    - For basics: `rocm-language-runtime rocm-developer-tools rocm-llvm`
    - For HIP: `rocm-hip-runtime rocm-hip-libraries rocm-hip-sdk`
    - For OpenCL: `rocm-opencl-runtime rocm-opencl-sdk`
    - For OpenMP: `rocm-openmp-sdk`
    - For ML: `rocm-ml-sdk rocm-ml-libraries`
    - Note: ROCm depends on `python`, which in Ubuntu installs `python-is-python2`.
1. Add ROCm to PATH: `echo "export PATH=$PATH:/opt/rocm/bin:/opt/rocm/opencl/bin" | sudo tee -a /etc/profile.d/rocm.sh`
1. Add yourself to the relevant groups to use ROCm: `sudo usermod -aG video,render <username>`
1. Reboot.
1. Verify AMDGPU DKMS install: `sudo dkms status`
1. Verify ROCm install: `rocminfo`
    - This should show you AMD GPU as an agent (and also you AMD CPU if you have one).
1. (Optional) Verify HIP: See [HIP](../HIP/).

## Usage and Tools

- Show GPU info: `rocm-smi`

{% include footer.md %}
