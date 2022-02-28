---
title: Docker
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

## TODO

- CGroup driver? Similar to setting `native.cgroupdriver=systemd` for Docker to use the systemd driver instead of creating a new one.
- Default network MTU. (Some of my networks require a lower MTU because Azure IPv6 networking sucks.)
- Prometheus/OpenMetrics metrics.
- Swap limit support. Similar to setting `cgroup_enable=memory swapaccount=1` for Docker.

## Setup

### Podman

#### Debian

1. (Note) Debian 11, Ubuntu 20.10 etc. should have Podman in the main repos.
1. Add Kubic repo (Ubuntu 20.04 and older):
    1. Install dependencies: `apt install curl gnupg`
    1. Get OS info: `source /etc/os-release`
    1. Add GPG key: `curl -sSf https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key | gpg --dearmor > /usr/share/keyrings/kubic-libcontainers-archive-keyring.gpg`
    1. Add repo: `echo "deb [signed-by=/usr/share/keyrings/kubic-libcontainers-archive-keyring.gpg] http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/kubic-libcontainers.list`
1. Install: `apt install podman`
1. Enable auto-start:
    1. Enable: `systemctl enable --now podman-restart.service`
    1. (Note) The service is required to automatically start containers with `restart=always` on reboot.
1. Verify install: `podman info`
1. (Optional) Add Docker compat stuff:
    1. Set Docker executable link: `ln -s /usr/bin/podman /usr/bin/docker`
    1. Set Docket socket path: `echo "DOCKER_HOST=unix:///run/podman/podman.sock" >> /etc/environment`
    1. Set sudo to accept the socket path env var: `echo "Defaults env_keep += \"DOCKER_HOST\"" >> /etc/sudoers.d/podman-compat`

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

1. Add the repo: See the [installation guide](https://nvidia.github.io/nvidia-container-runtime).
1. Install: `apt install nvidia-container-toolkit` (not `nvidia-docker2`)
1. Fix [an ldconfig bug](https://github.com/NVIDIA/nvidia-docker/issues/1399) (Debian 11): In `/etc/nvidia-container-runtime/config.toml`, under the `nvidia-container-cli` section, set `ldconfig = "/sbin/ldconfig"` (remove the `@` prefix).
1. Test: `podman run --privileged --rm docker.io/nvidia/cuda:11.0-base nvidia-smi`

## Usage

### General

- See [Docker usage](../docker/#usage).
    - Most commands are Docker clones and simply replacing `docker` with `podman` in the command will typically work.
    - Configuration files are a bit different.
- Registries:
    - Since Podman supports multiple default registries instead of just Docker Hub, it's recommended to prepend `docker.io/` to images you expect to find in Docker Hub.
1. Auto-start:
    - The `podman-restart.service` provides auto-starting of containers.
    - Only containers with `restart=always` will be auto-started.
1. Auto-updating:
    - Auto-updating is provided by a systemd timer and service.
    - Run `podman auto-update` to run manually.
    - Set label `io.containers.autoupdate=registry` on containers to enable auto-updates.
    - **TODO** Apparently this requires systemd-unit containers.

### Networking

- Firewall:
    - Unlike Docker, you can't just restart some daemon to fix the firewall rules after reapplying your normal IPTables rules from a script or something.
    - (Bug) Doesn't open the ports when exposing ports from containers, for some reason. Works if changing the default forwarding actions to accept, but why would I do that. To work around it, you need to manually add forwarding accept rules to the container IP addresses.
- DNS:
    - By default, the host's DNS domainname and servers will be set in the container's `/etc/resolv.conf`.
- IPv6:
    - Doesn't seem to be as broken/neglected as in Docker. _To be continued ..._
    - (Bug) When creating a network with an IPv6 subnet, it ignores the provided IPv4 subnet and uses a default one instead.
    - Add `--ipv6 --subnet=<subnet>/64` to enable on bridges (with NAT and firewalling, like IPv4).
- Miscellanea:
    - The MTU issues I had with Docker seems to be gone. It correctly received packet-too-big messages when the upstream transport has a lower MTU.

{% include footer.md %}
