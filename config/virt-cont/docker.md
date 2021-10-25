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
    - (Info) By default, Docker does not enable IPv6 for containers and does not add any IP(6)Tables rules for the NAT or filter tables, which you need to take into consideration if you plan to use IPv6 (with or without automatic IPTables rules). See the miscellaneous not below on IPv6 support for more info about its brokenness and the implications of that. Docker _does_ however recently support handling IPv6 subnets similar to IPv4, meaning using NAT masquerading and appropriate firewalling. It doesn't work properly for internal networks, though, as it breaks IPv6 ND. The following steps describe how to set that up, as it is the only working solution IMO. MACVLANs with external routers will not be NAT-ed.
    - Open `/etc/docker/daemon.json`.
    - Set `"ipv6": true` to enable IPv6 support at all.
    - Set `"fixed-cidr-v6": "<prefix/64>"` to some [random](https://simpledns.plus/private-ipv6) (ULA) (if using NAT masq.) or routable (GUA or ULA) (if not using NAT masq.) /64 prefix, to be used by the default bridge.
    - Set `"ip6tables": true` to enable automatic filter and NAT rules through IP6Tables (required for both security and NAT).
1. (Recommended) Change the cgroup manager to systemd:
    - In `/etc/docker/daemon.json`, set `"exec-opts": ["native.cgroupdriver=systemd"]`.
    - It defaults to Docker's own cgroup manager/driver called cgroupfs.
    - systemd (as the init system for most modern Linux systems) also functions as a cgroup manager, and using multiple cgroup managers may cause the system to become unstable under resource pressure.
    - If the system already has existing containers, they should be completely recreated after changing the cgroup manager.
1. (Optional) Change the storage driver:
    - By default it uses the `overlay2` driver, which is recommended for most setups. (`aufs` was the default before that.)
    - The only other alternatives worth consideration are `btrfs` and `zfs`, if the system is configured for those file systems.
1. (Recommended) Change IPv4 network pool:
    - In `/etc/docker/daemon.json`, set `"default-address-pools": [{"base": "172.17.0.0/12", "size": 24}]`.
    - For local networks (not Swarm overlays), it defaults to pool `172.17.0.0/12` with `/16` allocations, resulting in a maximum of `2^(16-12)=16` allocations.
1. (Recommended) Change default DNS servers for containers:
    - In `/etc/docker/daemon.json`, set `"dns": ["1.1.1.1", "2606:4700:4700::1111"]` (example using Cloudflare) (3 servers max).
    - It defaults to `8.8.8.8` and `8.8.4.4` (Google).
1. (Optional) Change the logging options (JSON file driver):
    - It defaults to the JSON file driver with a single file of unlimited size.
    - Configured globally in `/etc/docker/daemon.json`.
    - Set the driver (explicitly): `"log-driver": "json-file"`
    - Set the max file size: `"log-opts": { "max-size": "10m" }`
    - Set the max number of files (for log rotation): `"log-opts": { "max-file": "5" }`
    - Set the compression for rotated files: `"log-opts": { "compress": "enabled" }`
1. (Recommended) Disable the userland proxy:
    - It's no longer recommended to keep this enabled, future Docker versions will brobably disable it by default.
    - Disabling it _may_ break your published IPv6 ports, so you may want to test that.
    - In `/etc/docker/daemon.json`, set `"userland-proxy": false`.
1. (Optional) Change the container network MTU:
    - Path MTU discovery seems to be broken in Docker networks, causing connection problems when the upstream network is using an MTU lower than 1500.
    - In `/etc/docker/daemon.json`, set `"mtu": 1280` (for the minimum for IPv6) or similar.
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

Docker Compose will fail to work if `/tmp` is mounted with `noexec`.

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

## Best Practices

- Building:
    - Use simple base images without stuff you don't need (especially for the final image if using multi-stage builds). `alpine` is nice, but uses musl libc instead of glibc, which may cause problems for certain apps.
    - Use official base images you can trust.
    - Completely build inside the container to avoid relying on external tools and libraries (for better reproducability and portability).
    - Use multi-stage builds to separate the heavier build environment/image containing all the build tools and many layers from the final image with the build app copied into it from the previous stage.
    - To exploit cacheability when building an image multiple times (e.g. during development), put everything that doesn't change (e.g. installing packages) at the top of the Dockerfile and stuff that changes frequently (e.g. copying source files and compilation) as close to the bottom as possible.
    - Use `COPY` instead of `ADD`, unless you actually need some of the fancy and sometimes unexpected features of `ADD`.
    - Use `ARG`s and `ENV`s (with defaults) for vars you may want to change before building.
    - `EXPOSE` is pointless and purely informational.
    - Use `ENTRYPOINT` (in array form) to specify the entrypoint script or application and `CMD` (in array form) to specify default additional arguments to the `ENDTYPOINT`.
    - Create a `.dockerignore` file, similar to `.gitignore` files, to avoid copying useless or sensitive files into the container.
- Signal handling:
    - Make sure your application is handling signals correctly (e.g. such that it stops properly). The initial process in the container runs with PID 1, which is typically reserved for the init process and is handled specially by certain things.
    - If your application does not handle signals properly internally, build the image with [tini](https://github.com/krallin/tini) as the entrypoint or run the container with `--init` to make Docker inject tini as the entrypoint.
- Don't run as root:
    - Either set a static user in the Dockerfile, change to a specific user (static or dynamic) in the entrypoint script or app itself, or specify a user through Docker run (or equivalent). The latter approach (specified in Docker run) is assumed hereafter.
    - The app may still be build by root and may be owned by root since the user running it generally shouldn't need to modify the app itself.
    - If the app needs to modify files, put them in `/tmp`. Maybe make it easy to override the paths for more flexibility wrt. volumes and bind mounts.
- Credentials and sensitive files:
    - Don't hard code them anywhere.
    - Don't ever put them on the image file system during building as it may get caught by one of the image layers.
    - Specify them as mounted files (with proper permissions), env vars (slightly controversial), Docker secrets or similar.
- Implement health checks.
- Docker Compose:
    - Drop the `version` property (it's deprecated).
    - Use YAML aliases and anchors to avoid repeating yourself too much. To create an anchor, add `&<anchor>` behind a property (e.g. a service definition). To copy all content from below the property the anchor references, specify `<<: *<anchor>` inside the new property (i.e. one layer lower than the anchor on the other property). Copied properties can be overridden by explicitly specifying them.
    - Consider implementing health checks within the DC file if the image does not already implement them (Google it).
    - Consider putting envvars in a separate env file (specified using `--env-file` on the CLI or `env_file: []` in the DC file).

## Miscellanea

### IPv6 Support

- TL;DR: Docker doesn't properly support IPv6.
- While IPv6 base support may be enabled by setting `"ipv6": true` in the daemon config (disabled by default), it does not add any IP(6)Tables rules for the filter and NAT tables, as it does for IPv4/IPTables. (See [moby/moby #13481](https://github.com/moby/moby/issues/13481), [moby/moby #21951](https://github.com/moby/moby/issues/21951), [moby/moby #25407](https://github.com/moby/moby/issues/25407), [moby/libnetwork #2557](https://github.com/moby/libnetwork/issues/2557).)
- Using `"ipv6": true` without `"ip6tables": true` means the following for IPv6 subnets on Docker bridge networks (and probably other network types):
    - The IPv6 subnet must use a routable prefix which is actually routed to the Docker host (unlike IPv4 which uses NAT masquerading by default). While this is more appropriate for typical infrastructures, this may be quite impractical for e.g. typical home networks.
    - If you accept forwarded traffic by default (in e.g. IPTables): The IPv6 subnet is not firewalled in any way, leaving it completely open to other networks "on" or "connected to" the Docker host, meaning you need to manually add IPTables rules to limit access to each Docker network.
    - If you drop/reject forwarded traffic by default (in e.g. IPTables): The IPv6 subnet is completely closed and hosts on the Docker network can't even communicate between themselves (assuming your system filters bridge traffic). To allow intra-network traffic, you need to manually add something like `ip6tables -A FORWARD -i docker0 -o docker0 -j ACCEPT` for each Docker network. To allow for inter-network traffic, you need to manually add rules for that as well.
- To enable IPv4-like IPTables support (with NAT-ing and firewalling), set `"ip6tables": true` in the daemon config (disabled by default) in the daemon config. If you want to disable NAT masquerading for both IPv4 and IPv6 (while still using the filtering rules provided by `"ip6tables": true`), set `enable_ip_masquerade=false` on individual networks. Disabling NAT masquerading for only IPv6 is not yet possible. MACVLANs with external routers will not get automatically NAT-ed.
- IPv6-only networks (without IPv4) are not supported. (See [moby/moby #32675](https://github.com/moby/moby/issues/32675), [moby/libnetwork #826](https://github.com/moby/libnetwork/pull/826).)
- IPv6 communication between containers (ICC) on IPv6-enabled _internal_ bridges with IP6Tables enabled is broken, due to IPv6 ND being blocked by the applied IP6Tables rules. On non-internal bridges it works fine. One workaround is to not use IPv6 on internal bridges or to not use internal bridges. (See [libnetwork/issues #2626](https://github.com/moby/libnetwork/issues/2626).)
- The userland proxy (enabled by default, can be disabled) accepts both IPv4 and IPv6 incoming traffic but uses only IPv4 toward containers, which replaces the IPv6 source address with an internal IPv4 address (I'm not sure which), effectively hiding the real address and may bypass certain defences as it's apparently coming from within the local network. It also has other non-IPv6-related problems. (See [moby/moby #11185](https://github.com/moby/moby/issues/11185), [moby/moby #14856](https://github.com/moby/moby/issues/14856), [moby/moby #17666](https://github.com/moby/moby/issues/17666).)

### Other Problems

- Path MTU discovery seems to be broken in Docker networks, causing connection problems when the upstream network is using an MTU lower than 1500. Set the MTU to 1280 (the IPv6 minimum) to solve this.
- Docker seems to forget static addresses of containers when changing network properties (**TODO** at least when using the Ansible module, maybe that's what's causing the problem). Re-up everything to fix it.

## Useful Software

- [watchtower](https://github.com/containrrr/watchtower): Automatically update images and restart containers.
- [cAdvisor](https://github.com/google/cadvisor): Monitor containers (including a Prometheus metrics endpoint).

{% include footer.md %}
