---
title: Linux General
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Resources

### Security

- [Linux Hardening Checklist (trimstray)](https://github.com/trimstray/linux-hardening-checklist)
- [The Practical Linux Hardening Guide (trimstray)](https://github.com/trimstray/the-practical-linux-hardening-guide)

## Information

### Distros

#### Debian

- Nobody user and group: `nobody:nogroup`
- List of default groups: [SystemGroups (Debian Wiki)](https://wiki.debian.org/SystemGroups#Other_System_Groups)
- Release info file: `/etc/debian_version`

#### RHEL

- Nobody user and group: `nobody:nobody`
- Release info file: `/etc/redhat-release` or `/etc/centos-release`

### Miscellanea

- `urandom` VS `random`: `random` blocks when running out of entropy while `urandom` does not. For all practical purposes, `urandom` will almost never be *less random* than `random` and `random` may block at inappropriate times, so always use `urandom`.

### Bugs

- Environment variables from `*/environment.d/*.conf` aren't visible for login sessions when using systemd. `*/environment.conf` works, though. See [systemd#7641](https://github.com/systemd/systemd/issues/7641).

## Commands

### AAA

- Sudo:
    - Show sudo permissions for current user: `sudo -l`

### Executables:

- Show type and info: `file <executable>`
- Show library dependencies (for glibc): `ldd <executable>`
    - It lists shared library file names and memory location to map it to, or "statically linked" if no dynamic dependencies.
    - Alternatively, run the executable with envvar `LD_TRACE_LOADED_OBJECTS=1` set instruct glibc to print dependencies and exit. This is basically how `ldd` works internally, but with more options.
    - Warning: This might execute the program if not using glibc.
- Show printable character strings in the executable: `strings -a <executable>`
- Run application and show dynamic library calls: `ltrace <executable> [args]`
- Run application and show system calls: `strace <executable> [args]`
- Strip the symbol table and debug info from an executable: `strip <executable>`
    - Without certain options, it will still keep some useful info in the file.
- Rebuild the symbol table for a statically linked executable: See `gensymtab`.

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
- Space usage:
    - `du -sh <dirs>`
    - K4DirStat (GUI) (package `k4dirstat`)
- Shred files:
    - `shred --remove --zero <file>`

### Fun

- Color text from STDIN: `lolcat`
- `cowsay`
- `fortune`

### Monitoring (General)

- For more specific monitoring, see the other sections.
- `htop`:
    - ncurses-based process viewer like `top`, but prettier and more interactive.
    - Install (APT): `apt install htop`
    - Usage: `htop` (interactive)
- `glances`:
    - Homepage: [nicolargo.github.io/glances/](https://nicolargo.github.io/glances/)
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

### Software Installation

#### APT (Debian)

- Find packages depending on the package: `apt rdepends --installed <package>`
- Quickly add new repo: `add-apt-repository <repo-line`
    - It will add the line to `/etc/apt/sources.list`, where you can manually remove it again.
- Keys:
    - List: `apt-key list`
        - It will also show which file contains it.
    - Remvoe key: `apt-key del <key-id>`
        - The 8-digit hex key ID may either be found on `pub` line or as the last 8 hex digits on the continuation line.

#### Pacman (Arch)

- Full system upgrade: `pacman -Syu`
- Search package: `pacman -Ss <package-name>`
- Show package info: `pacman -Si <package>`
- Install package: `pacman -S <packages>`
    - Never use `-Sy` to avoid partial upgrades.
- Remove package: `pacman -R <packages>`
    - Remove orphans too: `-s`
    - Purge configurations: `-n`

### Network

- Monitor usage:
    - `nload <if>`
    - `iftop -i <if>`
    - `speedometer -t <if> -r <if> [...]`
    - `dstat -tcyn --net-packets 60`
- Monitor per-process usage:
    - `nethog`
- Test throughput:
    - Internet: `speedtest` (from [speedtest.net](https://www.speedtest.net/apps/cli))
    - Internal: `iperf3`
- Show sockets (with `ss`):
    - Example: `ss -tulpn`
    - Note: `ss` replaces `netstat` and is mostly option compatible.
    - Option `tu`: Include TCP and UDP sockets (no UNIX sockets).
    - Option `l`: Include listening sockets (no client sockets).
    - Option `p`: Show protocol (requires root).
    - Option `n`: Don't translate port numbers to common service names.
- Show misc. stats:
    - Show kernel SNMP counters: `nstat`
    - Show per-protocol stats: `netstat -s`
- Bring interface up or down:
    - Note: Your network manager probably has a more appropriate way to do this.
    - Directly up or down interface: `ip link set dev <if> {up|down}`
- Traffic shaping and link simulation:
    - See `tc` to simulate e.g. random packet drop, random latencies, limited bandwidth etc.

#### ip

- General notes:
    - Subcommands may be shortened (e.g. as `ip a` instead of `ip address`)
    - For subcommands like `address` and `link`, it will default to show all elements if no further option is specified.
- General options:
    - Specified before the subcommand (e.g. `ip -c a`).
    - `-c`: Show colored output.
    - `-4` or `-6`: Show IPv4 or IPv6 addresses only.
    - `-s`: Show stats (bytes, packets, errors, dropped, etc. for RX and TX).
    - `-br`: Show brief with one line per interface (MAC address and status for `link`, addresses for `address`).
    - `-o`: Show one line per interface (but all info unlike `-br`).
    - `-j [-p]`: Print as JSON. Add `-p` for pretty printing.
- Show L2/MAC addresses:
    - Command: `ip link [show [<interface>]]`
- Show L3/IP addresses:
    - Command: `ip address [show [<interface> [scope <scope>]]]`
    - Argument `scope global`: Only show global addresses (excludes localhost/`host`, link-local/`link`, etc.).
- Show neighbors:
    - Command: `ip neighbor`
- Show routes:
    - Command: `ip route`
- Show multicast addresses:
    - Command: `ip maddress`
- Show multicast routes:
    - Command: `ip mroute`

#### tcpdump

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
- Generate XKCD-style (multi-word) passwords (using package `xkcdpass`): `xkcdpass`
- Generate SHA cryptographical hashes: `sha{256,512} <files>`
- Check PGP signature of file (using GPG):
    1. Get the data file, a detached/separate signature file (`.sig`) for the data file, and the publisher's key (manually downloaded or through a key server). The Data file and sig may be from untrusted sources (like a download mirror).
    1. (Alternative 1) Import a downloaded keyfile:
        1. Note: Download the publisher's key file (`.asc`) and its fingerprint from a trusted source.
        1. Show the details and fingerprint of the key: `gpg --show-keys <keyfile>`
        1. (Recommended) Compare the fingerprint from the keyfile from the one on the publisher's website or whatever (some trusted source).
        1. Make sure the `uid` of the key is recognizable wrt. the intended use.
        1. Import the key: `gpg --import <keyfile>`
    1. (Alternative 2) Import the keyfile from a key server:
        1. Note: Import the publisher's key from a key server, given a server URL and fingerprint. The fingerprint must be from a trusted source.
        1. Inspect the key before importing: **TODO**
        1. Make sure the `uid` of the key is recognizable wrt. the intended use.
        1. Download the key: `gpg [--keyserver <url>] --recv-keys <key-id>`
    1. Finally, verify the data file using the detached signature and imported key: `gpg --verify <sigfile> <datafile>`

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
- Run command with high or low CPU priority:
    - Command: `nice -n<n> <cmd>` (`-20 <= n <= 19`)
    - The nice value goes from -20 (highest priority) to 19 (lowest priority), with 0 as the default priority.
    - The nice value is inherited by child processes (meaning forking processes maintains the nice value it started with).
    - Use `renice` to change the value.
    - Use `ionice` to set the I/O scheduler and scheduler-specific priority.
- Stress test with stress-ng:
    - Install (Debian): `apt install stress-ng`
    - Stress CPU: `stress-ng -c $(nproc) -t $((10*60))` (use all CPU threads for 10 minutes)
- Chroot into other Linux installation:
    1. Note: Used to e.g. fix a broken install or reset a user password from a USB live ISO.
    1. Mount the root partition: `mount /dev/sda2 /mnt` (example)
    1. Mount e.g. the EFI partition: `mount /dev/sda1 /mnt/boot/efi` (example)
    1. Mount system stuff:
        1. `mount -t proc proc /mnt/proc`
        1. `mount -t sysfs sys /mnt/sys`
        1. `mount -t bind /dev /mnt/dev`
    1. Enter jail: `chroot /mnt [/bin/bash]`
        - Specifying the shell to use, e.g. `/bin/bash`, may be necessary.
    1. Do stuff.
    1. Exit jail: `exit`

## Tasks

### Burn Windows ISO (Ubuntu)

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

{% include footer.md %}
