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
- [CUDA GPUs (NVIDIA)](https://developer.nvidia.com/cuda-gpus)

## Installation

### Linux

The toolkit on Linux can be installed through the package manager or through a runfile (script). Using the package manager method is recommended whenever possible. The toolkit also requires a matching NVIDIA driver to be installed.

**Ubuntu:**

1. Install NVIDIA driver.
    - Typically through the "Driver Manager" on Ubuntu-based distros, which installs it through the package manager.
    - See 
1. Install build prerequisites: `apt install build-essential linux-headers-$(uname -r)`

{% include footer.md %}
