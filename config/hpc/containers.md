---
title: Containers
breadcrumbs:
- title: Configuration
- title: High-Performance Computing (HPC)
---
{% include header.md %}

## Alternative Technologies

### Docker

#### Resources

- Config notes: [Docker](/config/virt-cont/docker/)

#### General Information

- The de facto container solution.
- It's generally **not recommended for HPC** (see reasons below), but it's fine for running on a local system if that's just more practical for you.
- Having access to run containers is effectively the same as having root access to the host machine. This is generally not acceptable on shared resources.
- The daemon adds extra complexity (and overhead/jitter) not required in HPC scenarios.
- Generally lacks typical HPC architecture support like batch integration, non-local resources and high-performance interconnects.

### Singularity

#### Resources

- Homepage: [Singularity](https://singularity.hpcng.org/)
- Config notes: [Singularity](/config/hpc/singularity/)

#### Information

- Images:
    - Uses a format called SIF, which is file-based (appropriate for parallel/distributed filesystems).
    - Managing images equates to managing files.
    - Images can still be pulled from repositories (which will download them as files).
    - Supports Docker images, but will automatically convert them to SIF.
- No daemon process.
- Does not require or provide root access to use.
- Uses the same user, working directiry and env vars as the host (**TODO** more info required).
- Supports Slurm.
- Supports GPU (NVIDIA CUDA and AMD ROCm).

### NVIDIA Enroot

#### Resources

- Homepage: [NVIDIA Enroot](https://github.com/NVIDIA/enroot)

#### Information

- Fully unprivileged `chroot`. Works similarly to typical container technologies, but removes "unnecessary" parts of the isolation mechanisms. Converts traditional container/OS images into "unprivileged sandboxes".
- Newer than some other alternatives.
- Supports using Docker images (and Docker Hub).
- No daemon.
- Slurm integration using NVIDIA's [Pyxis](https://github.com/NVIDIA/pyxis) SPANK plugin.
- Support NVIDIA GPUs through NVIDIA's [libnvidia-container](https://github.com/nvidia/libnvidia-container) library and CLI utility.
    - **TODO** AMD ROCm support?

### Shifter

I've never used it. It's very similar to Singularity.

## Best Practices

- Containers should run as users (the default for e.g. Singularity, but not Docker).
- Use trusted base images with pinned versions. The same goes for dependencies.
- Make your own base images with commonly used tools/libs.
- Datasets and similar do not need to be copied into the image, it can be bind mounted at runtime instead.
- Spack and Easybuild may be used to simplify building container recipes (Dockerfiles and Singularity-something), to avoid boilerplate and bad practices.
- BuildAh may be used to build images without a recipe.
- Dockerfile (or similar) recommendations:
    - Combine `RUN` commands to reduce the number of layers and this the size of the image.
    - To exploit the build cache, place the most cacheable commands at the top to avoid running them again on rebuilds.
    - Use multi-stage builds for separate build and run time images/environments.

{% include footer.md %}
