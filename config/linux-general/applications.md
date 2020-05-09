---
title: Linux Applications
breadcrumbs:
- title: Configuration
- title: Linux General
---
{% include header.md %}

## Docker

### Setup

1. Install: [Docker Documentation: Get Docker Engine - Community for Debian](https://docs.docker.com/install/linux/docker-ce/debian/).
1. (Optional) Setup swap limit:
    - If `docker info` contains `WARNING: No swap limit support`, it's not working and should maybe be fixed.
    - It incurs a small performance degredation and is optional but recommended.
    - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
    - Run `update-grub` and reboot.
1. Configure `/etc/docker/daemon.json`:
    - Enable IPv6: `"ipv6": true` and `"fixed-cidr-v6": "<ipv6-subnet>/64"`
        - Note that IPv6 it not NATed like IPv4 is in Docker.
    - Set DNS servers: `"dns": ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"]`
        - If not set, containers will use `8.8.8.8` and `8.8.4.4` by default.
    - (Optional) Disable automatic IPTables rules: `"iptables": false`
1. (Optional, not recommended on servers) Allow certain users to use Docker: Add them to the `docker` group.

### Usage

- Miscellanea:
    - Show disk usage: `docker system df -v`
- Cleanup:
    - Prune unused images: `docker image prune -a`
    - Prune unused volumes: `docker volume prune`
- Docker run options:
    - Set name: `--name=<name>`
    - Run in detatched mode: `-d`
    - Run using interactive terminal: `-it`
    - Automatically remove when stopped: `--rm`
    - Automatically restart: `--restart=unless-stopped`
    - Use "tini" as entrypoint and use PID 1: `--init`
    - Set env var: `-e <var>=<val>`
    - Publish network port: `-p <host-port>:<cont-port>[/udp]`
    - Mount volume: `-v <vol>:<cont-path>` (`<vol>` must have a path prefix like `./` or `/` if it is a directory and not a named volume)
- Networks:
    - Create simple bridged network: `docker network create --driver=bridge --subnet=<ipv4-net> --ipv6 --subnet=<ipv6-net> <name>`
    - Create network connected to host bridge: `docker network create --driver=bridge --subnet=<ipv4-net> --gateway=<ipv4-gateway> --ipv6 --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o "com.docker.network.bridge.name=<host-if> <name>`
    - Create network connected to host interface: `docker network create --driver=macvlan --subnet=<ipv4-net> --gateway=<ipv4-gateway> --ipv6 --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o parent=<netif> <name>`
    - Run container with network: `docker run --network=<net-name> --ip=<ipv4-addr> --ip6=<ipv6-addr> --dns=<dns-server> <image>`

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

## smartmontools

- For monitoring disk health.
- Install: `apt install smartmontools`
- Show all info: `smartctl -a <dev>`
- Tests are available in foreground and background mode, where foreground mode is given higher priority.
- Tests:
    - Short test: Can be useful to quickly identify a faulty drive.
    - Long test: May be used to validate the results found in the short test.
    - Convoyance test: Intended to quickly discover damage incurred during transportation/shipping.
    - Select test: Test only the specified LBAs.
- Run test: `smartctl -t <short|long|conveyance|select> [-C] <dev>`
    - `-C`: Foreground mode.

{% include footer.md %}
