---
title: Linux Examples
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Commands

### File Systems and Logical Volume Managers

- Partition disk: `gdisk <dev>` or `fdisk <dev>`
- Create filesystem: `mkfs.<fs> <dev>`
- Modify fstab:
    - Test it with `mount -a` to make sure it doesn't have errors that may cause boot to fail.
    - Run `systemctl daemon-reload` to avoid having systemd remount stuff that was removed from fstab or other weird shit.
- Benchmark with IOzone:
    - Install (Debian): `apt install iozone3`
    - It uses the current dir.
    - Test with various record sizes and file sizes: `iozone -a`
    - Benchmark: `iozone -t1` (1 thread)
    - Plot results: **TODO** It should be doable with gnuplot somehow.

### Files

- Search:
    - By UID: `find / -user <UID>`
    - Without a user: `find / -nouser`
    - With setuid permission bit: `find / -perm /4000`
    - Recursive search and replace: `find <dir> \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/123/456/g'`
        - `-type d -name .git -prune` skips `.git` directories and can be excluded outside of git repos.
- Usage:
    - `du -sh <dirs>`
    - K4DirStat (GUI) (package `k4dirstat`)
- Shred files:
    - `shred --remove --zero <file>`

### Fun

- Color text from STDIN: `lolcat`
- `cowsay`
- `fortune`

### Hardware

- Show hardware: `lshw`
    - Run as root for more info.
    - Specify `-X` to show GUI (requires `lshw-gtk`).
- Show hardware topology: `lstopo` (requires hwloc)
    - `lstopo` will try to present as a GUI. Use `lstopo-no-graphics` to force console output.
- Show PCI devices: `lspci`
- Show block devices: `lsblk`
- Show USB devices: `lsusb`
- Show CPUs: `lscpu`

### Installations and Packages

#### APT (Debian)

- Find packages depending on the package: `apt rdepends --installed <package>`
- Quickly add new repo: `add-apt-repository <repo-line`
    - It will add the line to `/etc/apt/sources.list`, where you can manually remove it again.
- Keys:
    - List: `apt-key list`
        - It will also show which file contains it.
    - Remvoe key: `apt-key del <key-id>`
        - The 8-digit hex key ID may either be found on `pub` line or as the last 8 hex digits on the continuation line.

### Network

- Monitor usage:
    - `nload <if>`
    - `iftop -i <if>`
    - `speedometer -t <if> -r <if> [...]`
- Monitor per-process usage:
    - `nethog`
- Test throughput:
    - Internet: `speedtest` (the official one, not `speedtest-cli`)
    - Internal: `iperf3`
- Show sockets:
    - `netstat -tulpn`
        - `tu` for TCP and UDP, `l` for listening, `p` for protocol, `n` for numerical post numbers.
    - `ss -tulpn` (replaces netstat version)
- Show interface stats:
    - `ip -s link`
    - `netstat -i`
- Show interfaces and addresses:
    - IPv4 and/or IPv6 plus MAC: `ip [-46] a`
    - Only global IPv4/IPv6: `ip <-46> a show scope global`
- Show neighbors:
    - `ip n`
- Show routes:
    - `ip r` & `ip -6 r`
    - `netstat -r`
- Show multicast groups:
    - `netstat -g`
- Show misc. stats:
    - `nstat`
    - `netstat -s` (statistics)

### Memory

- NUMA stats:
    - `numastat` (from package `numactl`)

### Performance and Power Efficiency

- Set the CPU frequency scaling governor mode:
    - High performance: `echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
    - Power save: `echo powersave | ...`
- Show current core frequencies: `grep "cpu MHz" /proc/cpuinfo | cut -d' ' -f3`

### Profiling

- Command timer (`time`):
    - Provided both as a shell built-in `time` and as `/usr/bin/time`, use the latter.
    - Syntax: `/usr/bin/time -vp <command>`
    - Options:
        - `-p` for POSIX output (one line per time)
        - `-v` for interesting system info about the process.
    - It give the wall time, time spent in usermode and time spent in kernel mode.

### Security

- Show CPU vulnerabilities: `tail -n +1 /sys/devices/system/cpu/vulnerabilities/*`

### Storage

- Test read speed: `hdparm -t <dev>` (safe)
- Show IO load for devices: `iostat [-dxpm] [-t] [interval]`
    - `-d`: Show only device usage.
    - `-x` and `-p`: Include extended attributes and partitions.
    - `-t` and interval: Show timestamp and repeat every x seconds.
- Show IO usage for processes: `iotop -o [-a]`

### System

- Version info:
    - Release info files:
        - Debian (and Ubuntu): `/etc/debian_version`
        - RHEL: `/etc/redhat-release`
        - CentOS: `/etc/centos-release`
    - General release info: `uname -a`
    - Slightly more distro-specific release info: `lsb_release -a`
- Monitor system load:
    - `uptime`
    - `iostat [-c] [-t] [interval]`
- Monitor processes:
    - `ps` (e.g. `ps aux` or `ps ax o uid,user:12,pid,comm`)
- Monitor a mix of things:
    - `htop`
    - `glances`
    - `ytop`
- Monitor interrupts:
    - `irqtop`
    - `watch -n0.1 /proc/interrupts`
- Stress test with stress-mg:
    - Install (Debian): `apt install stress-ng`
    - Stress CPU: `stress-ng -c $(nproc) -t 600`

## Tasks

### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

{% include footer.md %}
