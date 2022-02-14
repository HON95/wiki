---
title: Docker
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

## Setup

### Podman

#### Debian

1. Add Kubic repo (pre Debian 11∕Ubuntu 20.10 only):
    1. Install dependencies: `apt install curl wget gnupg2`
    1. Get OS info: `source /etc/os-release`
    1. Add repo: `echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/kubic-libcontainers.list`
    1. Add GPG key (old way): `wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | apt-key add -`
1. Install: `apt install podman`
1. Enable (**TODO** required?): `systemctl enable --now podman.service podman.socket`
1. Verify install: `podman info`
1. (Optional) Add Docker compat stuff:
    1. Set Docket socket path: `echo "DOCKER_HOST=unix:///run/podman/podman.sock" >> /etc/environment`
    1. Set Docker binary link: `ln -s /usr/bin/podman /usr/bin/docker`

#### Arch

1. Install: `pacman -S podman`
1. (Optional) (**TODO** required?) Install hostname resolution between containers: `pacman -S podman-dnsname`
1. (Optional) Add Docker compat stuff:
    1. Install: `pacman -S podman-docker`
    1. Quiet Docker emulation message: `touch /etc/containers/nodocker`

### Docker Compose

- Alternatively, you can use Podman Compose instead. Podman does provide CI/CD testing with Docker Compose, though, and IMO Podman Compose just doesn't work as well.
- Requires Podman with the Docker compat stuff to be set up.

#### Debian

1. Install Docker Compose: [Docker Documentation: Install Docker Compose](https://docs.docker.com/compose/install/).
1. Install command completion: [Docker Documentation: Command-line completion](https://docs.docker.com/compose/completion/).

#### Arch

1. Install: `pacman -S docker-compose`

### NVIDIA Container Toolkit

**TODO**

## Usage

### General

- See [Docker usage](../docker/#usage).
    - Most commands are Docker clones and simply replacing `docker` with `podman` in the command will typically work.
    - Configuration files are a bit different.
- Since Podman supports multiple default registries instead of just Docker Hub, it's recommended to prepend `docker.io/` to images you expect to find in Docker Hub.

### Networking

- IPv6:
    - Doesn't seem to be as broken/neglected as in Docker.
    - Add `--ipv6 --subnet=<subnet>/64` to enable on bridges (with NAT and firewalling, like IPv4).

{% include footer.md %}
