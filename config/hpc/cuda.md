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

- [CUDA (software engineering)](/config/se/general/cuda.md)

## Resources

- [NVIDIA CUDA Installation Guide for Linux (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [NVIDIA CUDA Installation Guide for Windows (NVIDIA)](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)
- [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)
- [CUDA GPUs (NVIDIA)](https://developer.nvidia.com/cuda-gpus)

## Installation

### Linux

The toolkit on Linux can be installed in different ways:

- Through an an existing package in your distro's repos (simplest and most compatible with other packages, but may be outdated).
- Through a downloaded package manager package (up to date but may be incompatible with your installed NVIDIA driver).
- Through a runfile (same as previous but more cross-distro and harder to manage).

If an NVIDIA driver is already installed, it must match the CUDA version.

Downloads: [CUDA Toolkit Download (NVIDIA)](https://developer.nvidia.com/cuda-downloads)

## Usage

### Programming

See [CUDA (software engineering)](/config/se/general/cuda.md).

### General Tools

- Gathering system/GPU information with `nvidia-smi`:
    - Show overview: `nvidia-smi`
    - Show topology matrix: `nvidia-smi topo --matrix`
    - Show topology info: `nvidia-smi topo <option>`
    - Show NVLink info: `nvidia-smi  nvlink --status -i 0` (for GPU #0)
    - Monitor device stats: `nvidia-smi dmon`
- To specify which devices are available to the CUDA application and in which order, set the `CUDA_VISIBLE_DEVICES` env var to a comma-separated list of device IDs.

{% include footer.md %}
