---
title: Linux Examples
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Commands

### General Monitoring

- For more specific monitoring, see the other sections.
- `htop`:
    - ncurses-based process viewer like `top`, but prettier and more interactive.
    - Install (APT): `apt install htop`
    - Usage: `htop` (interactive)
- `glances`:
    - Homepage: [Glances](https://nicolargo.github.io/glances/)
    - Install (PyPI for latest version): `pip3 install glances`
    - ncurses-based viewer for e.g. basic system info, top-like process info, network traffic and disk traffic.
    - Usage: `glances` (interactive)
- `dstat`:
    - A versatile replacement for vmstat, iostat and ifstat (according to itself).
    - Prints scrolling output for showing a lot of types of general metrics, one line of columns for each time step.
    - Usage: `dstat <options> [interval] [count]`
        - Default interval is 1s, default count is unlimited.
        - The values shown are the average since the last interval ended.
        - For intervals over 1s, the last row will update itself each second until the delay has been reached and a new line is created. The values shown are averages since the last final value (when the last line was finalized), so e.g. a 10s interval gives a final line showing a 10s average.
        - The first line is always a snapshot, i.e. all rate-based metrics are 0 or some absolute value.
        - If any column options are provided, they will replace the default ones and are displayed in the order specified.
    - Special options:
        - `-C <>`: Comma-separated list of CPUs/cores to show for, including `total`.
        - `-D <>`: Same but for disks.
        - `-N <>`: Same but for NICs.
        - `-f`: Show stats for all devices (not aggregated).
    - Useful metrics:
        - `-t`: Current time.
        - `-p`: Process stats (by runnable, uninterruptible, new) (changes per second).
        - `-y`: Total interrupt and context switching stats (by interrupts, context switches) (events per second).
        - `-l`: Load average stats (1 min, 5 mins, 15 mins) (total system load multiplied by number of cores).
        - `-c`: CPU stats (by system, user, idle, wait) (percentage of total).
        - `--cpu-use`: Per-CPU usage (by CPU) (percentage).
        - `-m`: Memory stats (by used, buffers, cache, free) (bytes).
        - `-g`: Paging stats (by in, out) (count per second).
        - `-s`: Swap stats (by used, free) (total).
        - `-r`: Storage request stats (by read, write) (requests per second).
        - `-d`: Storage throughput stats (by read, write) (bytes per second).
        - `-n`: Network throughput stats (by recv, send) (bytes per second).
        - `--socket`: Network socket stats (by total, tcp, udp, raw, ip-fragments)
    - Useful plugins (metrics):
        - `--net-packets`: Network request stats (by recv, send) (packets per second).
    - Examples:
        - General overview (CPU, RAM, ints/csws, disk, net): `dstat -tcmyrdn --net-packets 60`
        - Network overview (CPU, ints/csws, net): `dstat -tcyn --net-packets 60`
        - Process overview (CPU, RAM, ints/csws, paging, process, sockets): `dstat -tcmygp --socket 60`

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

#### Tcpdump

- Typical usage: `tcpdump -i <interface> -nn -v [filter]`
- Options:
    - `-w <>.pcap`: Write to capture file instead of formatted to STDOUT.
    - `-i <if>`: Interface to listen on. Defaults to a random-ish interface.
    - `-nn`: Don't resolve hostnames or ports.
    - `-s<n>`: How much of the packets to capture. Use 0 for unlimited (full packet).
    - `-v`/`-vv`: Details to show about packets. More V's for more details.
    - `-l`: Line buffered more, for better stability when piping to e.g. grep.
- Filters:
    - Can consist of complex logical statements using parenthesis, `not`/`!`, `and`/`&&` and `or`/`||`. Make sure to quote the filter to avoid interference from the shell.
    - Protocol: `ip`, `ip6`, `icmp`, `icmp6`, `tcp`, `udp`, ``
    - Ports: `port <n>`
    - IP address: `host <addr>`, `dst <addr>`, `src <addr>`
    - IPv6 router solicitations and advertisements: `icmp6 and (ip6[40] = 133 or ip6[40] = 134)` (133 for RS and 134 for RA)
    - IPv6 neighbor solicitations and advertisements: `icmp6 and (ip6[40] = 135 or ip6[40] = 136)` (135 for NS and 136 for NA)
    - DHCPv4: `ip and udp and (port 67 and port 68)`
    - DHCPv6: `ip6 and udp and (port 547 and port 546)`

### Memory

- NUMA stats:
    - `numastat` (from package `numactl`)

### Performance and Power Efficiency

- Set the CPU frequency scaling governor mode:
    - High performance: `echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
    - Power save: `echo powersave | ...`
- Show current core frequencies: `grep "cpu MHz" /proc/cpuinfo | cut -d' ' -f3`

### Profiling

- `time` (timing commands):
    - Provided both as a shell built-in `time` and as `/usr/bin/time`, use the latter.
    - Typical usage: `/usr/bin/time -p <command>`
    - Options:
        - `-p` for POSIX output (one line per time)
        - `-v` for interesting system info about the process.
    - It give the wall time, time spent in usermode and time spent in kernel mode.
- `strace` (trace system calls and signals):
    - In standard mode, it runs the full command and traces/prints all syscalls (including arguments and return value).
    - Syntax: `strace [options] <command>`
    - Useful options:
        - `-c`: Show summary/overview only. (Hints at which syscalls are worth looking more into.)
        - `-f`: Trace forked child processes too.
        - `-e trace=<syscalls>`: Only trace the specified comma-separated list of syscalls.

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
- Monitor a mix of things: See the "general monitoring" section.
- Monitor interrupts:
    - `irqtop`
    - `watch -n0.1 /proc/interrupts`
- Stress test with stress-ng:
    - Install (Debian): `apt install stress-ng`
    - Stress CPU: `stress-ng -c $(nproc) -t 600`

## Tasks

### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

{% include footer.md %}
