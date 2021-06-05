---
title: Docker
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

Using **Debian**.

## Setup

1. Install: [Install Docker Engine on Debian (Docker Documentation)](https://docs.docker.com/engine/install/debian/).
1. (Optional) Setup swap limit:
    - If `docker info` contains `WARNING: No swap limit support`, it's not working properly and should maybe be fixed.
    - Enabling/fixing it incurs a small performance degredation and is optional but recommended.
    - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
    - Run `update-grub` and reboot the system.
1. (Recommended) Setup IPv6 firewall and NAT:
    - By default, Docker does not add any IPTables NAT rules or filter rules, which leaves Docker IPv6 networks open (bad) and requires using a routed prefix (sometimes inpractical). While using using globally routable IPv6 is the gold standard, Docker does not provide firewalling for that when not using NAT as well.
    - Open `/etc/docker/daemon.json`.
    - Set `"ipv6": true` to enable IPv6 support at all.
    - Set `"fixed-cidr-v6": "<prefix/64>"` to some [generated](https://simpledns.plus/private-ipv6) (ULA) or publicly routable (GUA) /64 prefix, to be used by the default bridge.
    - Set `"ip6tables": true` to enable adding filter and NAT rules to IP6Tables (required for both security and NAT). This only affects non-internal bridges and not e.g. MACVLANs with external routers.
1. (Optional) Change IPv4 network pool:
    - - In `/etc/docker/daemon.json`, set `"default-address-pools": [{"base": "10.0.0.0/16", "size": "24"}]`.
1. (Optional) Change default DNS servers for containers:
    - In `/etc/docker/daemon.json`, set `"dns": ["1.1.1.1", "2606:4700:4700::1111"]` (example using Cloudflare) (3 servers max).
    - It defaults to `8.8.8.8` and `8.8.4.4` (Google).
1. (Optional) Enable Prometheus metrics endpoint:
    - This only exports internal Docker metrics, not anything about the containers (use cAdvisor for that).
    - In `/etc/docker/daemon.json`, set `"experimental": true` and `"metrics-addr": "[::]:9323"`.
1. (Optional) Allow non-root users to use Docker:
    - This is not recommended on servers as it effectively grants them root access without sudo.
    - Add them to the `docker` group.

## Usage

- Docker run options:
    - Set name: `--name=<name>`
    - Run in detatched mode: `-d`
    - Run using interactive TTY: `-it`
    - Automatically remove when stopped: `--rm`
    - Automatically restart: `--restart=unless-stopped`
    - Use "tini" as entrypoint with PID 1: `--init`
    - Set env var: `-e <var>=<val>`
    - Publish network port on host: `-p <host-port>:<cont-port>[/udp]`
    - Mount volume: `-v <host-path>:<container-path>`
        - The host path must have a path prefix like `./` or `/` if it is a file/dir and not a named volume.
- Cleanup:
    - Prune unused images: `docker image prune -a`
    - Prune unused volumes: `docker volume prune`
- Miscellanea:
    - Show disk usage: `docker system df -v`

### Networking

- See the miscellaneous note about the lacking IPv6 support in Docker.
- Network types:
    - Bridge: A plain virtual bridge where all containers and the host are connected and can communicate. It can optionally be directly connected to a host bridge, but that doesn't always work as expected.
    - Overlay: Overlay network for swarm stuff.
    - Host: The container use the network stack of the host. Ports are published directly to the host.
    - MACVLAN: Bridges connected to a host (parent) interface, allowing containers to be connected to a network the host is part of. Can optionally use trunking on the host interface. All communication between containers and the host is dropped (consider using a host-connected bridge if you need this).
    - L2 IPVLAN: Similar to MACVLAN, but all containers use the host's MAC address. Containers can communicate, but the host can't communicate with any containers.
    - L3 IPVLAN: Every VM uses a separate subnet and all communication, internally and externally, is routed. (**TODO:** Containers and the host can communicate?)
- Note that most L2 network types (with multiple containers present on the same L2 broadcast domain) are likely to be vulnerable to ARP/NDP spoofing.
- While Docker will automatically generate a private IPv4 subnet for networks, you need to [generate](https://simpledns.plus/private-ipv6) the private IPv6 /64 prefix yourself (or use a routable one).
- Create:
    - Create bridged network: `docker network create [--internal] [--subnet=<ipv4-net>] [--ipv6 --subnet=<ipv6-net>] <name>`
        - For internal, set the subnet(s) explicitly to avoid setting a default gateway.
    - Create MACVLAN: `docker network create --driver=macvlan --subnet=<ipv4-net> --ipv6 --subnet=<ipv6-net> -o parent=<netif>[.<vid>] <name>`
    - Create L2 IPVLAN with parent interface: `docker network create --driver=ipvlan <subnets-and-gateways> -o parent=<netif> <name>`
    - Create external bridged network (not recommended): `docker network create --driver=bridge <subnets-and-gateways> -o "com.docker.network.bridge.name=<host-if> <name>`
- Use:
    - Run container with network: `docker run --network=<net-name> --ip=<ipv4-addr> --ip6=<ipv6-addr> --dns=<dns-server> [...] <image>`
- Disable IPv4 and IPv6 NAT/masquerade for a bridge network: `docker network create <...> -o "com.docker.network.bridge.enable_ip_masquerade=false" <name>`
- Set the Linux name of a bridge network: `docker network create <...> -o "com.docker.network.bridge.name=<name>" <name>`

## Docker Compose

### Setup

1. Install Docker: See above.
1. Install: [Docker Documentation: Install Docker Compose](https://docs.docker.com/compose/install/).
1. Install command completion: [Docker Documentation: Command-line completion](https://docs.docker.com/compose/completion/).

### Troubleshooting

#### Fix Docker Compose No-Exec Tmp-Dir

Docker Compose will fail to work if `/tmp` has `noexec`.

1. Move `/usr/local/bin/docker-compose` to `/usr/local/bin/docker-compose-normal`.
1. Create `/usr/local/bin/docker-compose` with the contents below and make it executable.
1. Create the new TMPDIR dir.

New `docker-compose`:

```sh
#!/bin/bash
# Some dir without noexec
export TMPDIR=/var/lib/docker-compose-tmp
/usr/local/bin/docker-compose-normal "$@"
```

## NVIDIA Container Toolkit

The toolkit is used for running CUDA applications within containers.

### Setup

See the [installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).

## Miscellanea

### IPv6 Support

- TL;DR: Docker doesn't prioritize implementing IPv6 properly.
- While IPv4 uses IPTables filter rules for firewalling and IPTables NAT rules for masquerading and port forwarding, it generally uses no such mechanisms when enabling IPv6 (using `"ipv6": true`). Setting `"ip6tables": true` (disabled by default) is required to mimic the IPv4 behavior of filtering and NAT-ing. To disable NAT masquerading for both IPv4 and IPv6, set `enable_ip_masquerade=false` on individual networks. Disabling NAT masquerading for only IPv6 is not yet possible. (See [moby/moby #13481](https://github.com/moby/moby/issues/13481), [moby/moby #21951](https://github.com/moby/moby/issues/21951), [moby/moby #25407](https://github.com/moby/moby/issues/25407), [moby/libnetwork #2557](https://github.com/moby/libnetwork/issues/2557).)
- IPv6-only networks (without IPv4) are not supported. (See [moby/moby #32675](https://github.com/moby/moby/issues/32675), [moby/libnetwork #826](https://github.com/moby/libnetwork/pull/826).)
- IPv6 communication between containers (ICC) on IPv6-enabled bridges with IP6Tables enabled is broken, due to NDP (using multicast) being blocked by IP6Tables. On non-internal bridges it works fine. One workaround is to not use IPv6 on internal bridges or to not use internal bridges. (See [libnetwork/issues #2626](https://github.com/moby/libnetwork/issues/2626).)
- The userland proxy (enabled by default, can be disabled) accepts both IPv4 and IPv6 incoming traffic but uses only IPv4 toward containers, which replaces the IPv6 source address with an internal IPv4 address (I'm not sure which), effectively hiding the real address and may bypass certain defences as it's apparently coming from within the local network. It also has other non-IPv6-related problems. (See [moby/moby #11185](https://github.com/moby/moby/issues/11185), [moby/moby #14856](https://github.com/moby/moby/issues/14856), [moby/moby #17666](https://github.com/moby/moby/issues/17666).)

## Useful Software

- [watchtower](https://github.com/containrrr/watchtower): Automatically update images and restart containers.
- [cAdvisor](https://github.com/google/cadvisor): Monitor containers (including a Prometheus metrics endpoint).

{% include footer.md %}
