---
title: CUDA
breadcrumbs:
- title: Configuration
- title: High-Performance Computing (HPC)
---
{% include header.md %}

NVIDIA CUDA (Compute Unified Device Architecture) Toolkit, for programming CUDA-capable GPUs.

### Related Pages
{:.no_toc}

- [HIP](/config/hpc/hip/)
- [CUDA (software engineering)](/se/general/cuda/)

## Resources

- [NVIDIA CUDA Installation Guide for Linux (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [NVIDIA CUDA Installation Guide for Windows (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)
- [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
- [CUDA GPUs (NVIDIA)](https://developer.nvidia.com/cuda-gpus)

## Setup

### Linux Installation

The toolkit on Linux can be installed in different ways:

- Through an an existing package in your distro's repos (simplest and most compatible with other packages, but may be outdated).
- Through a downloaded package manager package (up to date but may be incompatible with your installed NVIDIA driver).
- Through a runfile (same as previous but more cross-distro and harder to manage).

If an NVIDIA driver is already installed, it must match the CUDA version.

Downloads: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)

#### Ubuntu w/ NVIDIA's CUDA Repo

1. Follow the steps to add the NVIDIA CUDA repo: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
    - Use the "deb (network)" method, which will show instructions for adding the repo.
    - But don't install `cuda` yet.
1. Remove anything NVIDIA or CUDA from the system to avoid conflicts: `apt purge --autoremove 'cuda' 'cuda-' 'nvidia-*' 'libnvidia-*'`
    - Warning: May break your PC. There may be better ways to do this.
1. Install CUDA from the new repo (includes the NVIDIA driver): `apt install cuda`
1. Setup PATH: `echo 'export PATH=$PATH:/usr/local/cuda/bin' | sudo tee -a /etc/profile.d/cuda.sh`

### Docker Containers

Docker containers may run NVIDIA applications using the NVIDIA runtime for Docker.

See [Docker](/config/virt-cont/docker/).

### DCGM

- For monitoring GPU hardware and performance.
- See the DCGM exporter for Prometheus for monitoring NVIDIA GPUs from Prometheus.

## Programming

See [CUDA (software engineering)](/config/se/general/cuda.md).

## Usage and Tools

- Gathering system/GPU information with `nvidia-smi`:
    - Show overview: `nvidia-smi`
    - Show topology matrix: `nvidia-smi topo --matrix`
    - Show topology info: `nvidia-smi topo <option>`
    - Show NVLink info: `nvidia-smi  nvlink --status -i 0` (for GPU #0)
    - Monitor device stats: `nvidia-smi dmon`
- To specify which devices are available to the CUDA application and in which order, set the `CUDA_VISIBLE_DEVICES` env var to a comma-separated list of device IDs.

## Troubleshooting

**"Driver/library version mismatch" and similar**:

Other related error messages from various tools:

- "Failed to initialize NVML: Driver/library version mismatch"
- "forward compatibility was attempted on non supported HW"

Caused by the NVIDIA driver being updated without the kernel module being reloaded.

Solution: Reboot.

{% include footer.md %}
