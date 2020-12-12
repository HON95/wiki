---
title: CUDA
breadcrumbs:
- title: Software Engineering
- title: Frameworks
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

**Ubuntu (package from main repos):**

1. Update your NVIDIA driver.
    - Typically through the "Driver Manager" on Ubuntu-based distros, which installs it through the package manager.
    - Check which version you have installed with `dpkg -l | grep nvidia-driver`.
1. Install the CUDA toolkit: `apt install nvidia-cuda-toolkit`

**Ubuntu (downloaded package or runfile):**

See [NVIDIA CUDA Installation Guide for Linux (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html).

## Running

- To specify which devices are available to the CUDA application and in which order, set the `CUDA_VISIBLE_DEVICES` env var to a comma-separated list of device IDs.

{% include footer.md %}
