---
title: CUDA
breadcrumbs:
- title: Configuration
- title: High-Performance Computing (HPC)
---
{% include header.md %}

NVIDIA CUDA (Compute Unified Device Architecture) Toolkit, for programming CUDA-capable GPUs.

## Resources

- [NVIDIA CUDA Installation Guide for Linux (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [NVIDIA CUDA Installation Guide for Windows (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)
- [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
- [CUDA GPUs (NVIDIA)](https://developer.nvidia.com/cuda-gpus)

## Installation

### Linux

The toolkit on Linux can be installed in different ways:
- Through an an existing package in your distro's repos (simplest and most compatible, but may be outdated).
- Through a downloaded package manager package (up to date but may be incompatible with your installed NVIDIA driver).
- Through a runfile (same as previous but more cross-distro and harder to manage).

Note that the toolkit requires a matching NVIDIA driver to be installed.

#### Ubuntu (Main Repos)

Note: May be outdated.

1. Update your NVIDIA driver.
    - Typically through the "Driver Manager" on Ubuntu-based distros, which installs it through the package manager.
    - Check which version you have installed with `dpkg -l | grep nvidia-driver`.
1. Install the CUDA toolkit: `apt install nvidia-cuda-toolkit`

#### Ubuntu (NVIDIA CUDA Repo)

See [NVIDIA CUDA Installation Guide for Linux (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html).

1. Follow the steps to add the NVIDIA CUDA repo: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
    - But don't install `cuda` yet.
1. Remove anything NVIDIA or CUDA from the system to avoid conflicts: `apt purge --autoremove cuda nvidia-* libnvidia-*`
    - Warning: May break your PC. There may be better ways to do this.
1. Install CUDA from the new repo (includes the NVIDIA driver): `apt install cuda`
1. Setup path: In `/etc/environment`, append `:/usr/local/cuda/bin` to the end of the PATH list.

## Running

- Gathering system/GPU information with `nvidia-smi`:
    - Show overview: `nvidia-smi`
    - Show topology matrix: `nvidia-smi topo --matrix`
    - Show topology info: `nvidia-smi topo <option>`
    - Show NVLink info: `nvidia-smi  nvlink --status -i 0` (for GPU #0)
    - Monitor device stats: `nvidia-smi dmon`
- To specify which devices are available to the CUDA application and in which order, set the `CUDA_VISIBLE_DEVICES` env var to a comma-separated list of device IDs.

{% include footer.md %}
