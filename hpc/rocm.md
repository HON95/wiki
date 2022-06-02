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

## Setup

### Installation (Debian)

#### Notes

- Official installation instructions: [ROCm Installation (AMD ROCm Docs)](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html)
- **TODO** `video` and `render` groups required to use it? Using `sudo` as a temporary solution works.

#### Steps

1. If the `amdgpu-pro` driver is installed then uninstall it to avoid conflicts. **TODO**
1. If using Mellanox ConnectX NICs then Mellanox OFED must be installed before ROCm.
1. Add the ROCm package repo:
    1. Install requirements: `sudo apt install curl libnuma-dev wget gnupg2`
    1. Add repo key: `curl -sSf https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor > /usr/share/keyrings/rocm.gpg`
    1. Add repo: `echo 'deb [signed-by=/usr/share/keyrings/rocm.gpg arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list`
    1. Update cache: `apt update`
1. Install: `sudo apt install rocm-dkms`
1. Fix symlinks and PATH:
    - ROCm symlink (`/opt/rocm`): `sudo ln -s /opt/rocm-4.2.0 /opt/rocm` (example) (**TODO** Will this automatically point to the right thing?)
    - Add to PATH: `echo 'export PATH=$PATH:/opt/rocm/bin:/opt/rocm/rocprofiler/bin:/opt/rocm/opencl/bin' | sudo tee -a /etc/profile.d/rocm.sh`
1. Reboot.
1. Verify:
    - `sudo /opt/rocm/bin/rocminfo` (should show e.g. one agent for the CPU and one for the GPU)
    - `sudo /opt/rocm/opencl/bin/clinfo`

## Usage and Tools

- Show GPU info: `rocm-smi`

{% include footer.md %}
