---
title: Linux General
breadcrumbs:
- title: General
---
{% include header.md %}

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

- Environment variables from `*/environment.d/*.conf` aren't visible for login sessions when using systemd. `/etc/environment` works, though. See [systemd#7641](https://github.com/systemd/systemd/issues/7641).

## Programs

### General

- Sorting: `sort`
    - Set `LC_ALL=C` to use byte-value sorting instead of locale-enabled sorting (which can be a bit unpredictable).

### AAA

- Sudo:
    - Show sudo permissions for current user: `sudo -l`

### Devices

- System topology (with `hwloc`):
    - Show system topology: `lstopo`
    - `lstopo` will try to output in GUI mode if supported. Use `lstopo-no-graphics` to force non-graphical output.
    - Run as root for more info.
    - Show more info (non-GUI): `-v`
    - Output in image format: Check the manual.
- USB:
    - Show brief: `lsusb`
    - Show verbose: `lsusb -v`
- PCI/PCIe:
    - Show brief: `lspci`
    - Show with loaded kernel modules: `lspci -k`

### Executables

- Show type and info: `file <executable>`
    - Shows e.g. if it's an ELF executable, target architecture, if dynamically linked, which ELF interpreter to use, if it's stripped etc.
- Show library dependencies (for glibc): `ldd <executable>`
    - It lists shared library file names and memory location to map it to, or "statically linked" if no dynamic dependencies.
    - Alternatively, run the executable with env var `LD_TRACE_LOADED_OBJECTS=1` set to instruct glibc (**TODO** the loader/interpreter?) to print dependencies and exit (this is normally how `ldd` works internally).
    - Warning: Never use this on untrusted executables, they may bypass the expected behavior and run malicious code instead.
- Show printable character strings in the executable: `strings -a <executable>`
- Run application and show dynamic library calls: `ltrace <executable> [args]`
- Run application and show system calls: `strace <executable> [args]`
- Strip the symbol table and debug info from an executable: `strip <executable>`
    - Without certain options (read the manual), it will still keep some useful info in the file.
- Rebuild the symbol table for a statically linked executable: See `gensymtab`.
- Show symbol table: `nm <file>`
    - Only works for object files and unstripped executables (see `strip`).

### File Systems and Logical Volume Managers

- Partition disk (TUI): `gdisk <dev>` or `fdisk <dev>`
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
- Shred disk with `shred`:
    - Example: `shred -n2 -v <file>`
    - `-n<n>` speficied the number of passes. This takes ages to begin with for large disks, so keep it as low as appropriate. 1 pass is generally enough, 2 to be sure.
    - `--zero` adds an extra, final pass to write all zeroes.
    - `-v` shows progress.

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
    - `shred --remove --zero -v <file>`
- Moving files with `rsync`:
    - Base command: `rsync [opts] <src> <dst>`
    - (Arg) `-v`: Verbose.
    - (Arg) `-s`: Protect args. Prevents remote hosts from interpreting paths, which might cause trouble e.g. if the path contains spaces.
    - (Arg) `-h`: Show numbers as human-readable.
    - (Arg) `--progress`: Show fancy progress bar.
    - (Arg) `-a`: Archive, equal to `-rlptgoD` (recursive, preserve symlinks/owner/group/permissions/modification-time etc.).
    - (Arg) `-z`: Compress. Use for network transfers, not locally.
    - (Arg) `--include <pattern>`: Only copy files/dirs matching the provided pattern. Supports `*` globbing, if quoted properly.
    - (Arg) `--exclude <pattern>`: Exclude files matching the pattern. THe matching works similarly to `--include`, but files matching the `--exclude` pattern overrides any files matched with the `--include` pattern (if any).
    - (Arg) `--delete`: Delete any files in the destination that are not present in the source.
    - (Arg) `--info=progress2`: Show single progress bar (not one per file as for `--progress`).
    - If the source or destination is on a remote machine, specify it as `<user>@<addr>:<path>` to copy over SSH (default transport protocol).
    - Adding a trailing slash to the source (`rsync [...] <src>/ <dst>`) results in copying the source dir _to_ the destination dir (i.e. copying the source dir contents into the destination dir). Omitting it will copy the whole source dir _into_ the destination dir. (**TODO**: This is how it's supposed to work, but for some reason it always copies the _contents_ into the destination dir for me.)
    - The parent of the destination directory needs to exist, but the destination directory itself is automatically created.
    - (Example) Move current dir to remote machine, overwrite and remove all old files: `rsync -azs --delete --progress . "hon@minisummit:Projects/yolo"`

### Fun

- Color text from STDIN: `lolcat`
- `cowsay`
- `fortune`

### Monitoring

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
    - **Warning:** No longer maintained: [dstat-real/dstat#170](https://github.com/dstat-real/dstat/issues/170) (Need to find a replacement.)
    - A versatile replacement for vmstat, iostat and ifstat (according to itself).
    - Prints scrolling output for showing a lot of types of general metrics, one line of columns for each time step.
    - Usage: `dstat <options> [interval] [count]`
        - Default interval is 1s, default count is unlimited.
        - The values shown are the average since the last interval ended.
        - For intervals over 1s, the last row will update itself each second until the delay has been reached and a new line is created. The values shown are averages since the last final value (when the last line was finalized), so e.g. a 10s interval gives a final line showing a 10s average.
        - The first line is always a snapshot, i.e. all rate-based metrics are 0 or some absolute value.
        - If any column options are provided, they will replace the default ones and are displayed in the order specified.
    - Special options:
        - `--bits`: Force usage of bits (e.g. to show network traffic as b/s instead of B/s).
        - `-f`: Show stats for all devices (not aggregated).
        - `-C <>`: Comma-separated list of CPUs/cores to show for, including `total`.
        - `-D <>`: Same but for disks.
        - `-N <>`: Same but for NICs.
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
    - Useful metrics from plugins:
        - `--net-packets`: Network request stats (by recv, send) (packets per second).
    - Examples:
        - General overview (CPU, RAM, ints/csws, disk): `dstat -tcmyrd 5`
        - Network overview (traffic [b/s], packets [p/s]): `dstat -tcyn --net-packets --bits 5`
        - Process overview (CPU, RAM, ints/csws, paging, process, sockets): `dstat -tcmygp --socket 5`

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

- Basics:
    - Update database: `apt update`
    - Install package: `apt install <package>`
    - Normal upgrade: `apt upgrade`
    - Full upgrade (may remove packages): `apt full-upgrade`
    - Show available versions: `apt list -a <package>`
    - Show dependencies: `apt depends <package>`
    - Show reverse dependencies: `apt rdepends [--installed] <package>`
    - Lock package version: `apt-mark hold <package>`
- Add repo (simple, not recommended):
    1. Add key: Download and run `apt-key add <key-file>`.
    1. Add repo: `add-apt-repository <repo-line>`
    1. (Note) This will add the line to `/etc/apt/sources.list`, where you can manually remove it again.
- Add repo (recommended):
    1. (Note) This method makes sure a repo key is only used to verify packages from that repo and isn't trusted globally. It doesn't prevent the repo from providing malicious versions of packages that should come from elsewere, however.
    1. Download the key: Download it to `/usr/share/keyrings/<name>.gpg`.
    1. Add the repo: In `/etc/apt/sources.list.d/<name>.list`, add the repo line and add `[signed-by=/usr/share/keyrings/<name>.gpg]` after `deb` (in the existing square brackets if one exists already).
    1. Update cache: `apt update`
- Keys (for authenticating packages):
    - List: `apt-key list`
        - It will also show which file contains it.
    - Add key (easy): `apt-key add <key-file>`
    - Add key (alternative): Save the keyring file as `/etc/apt/trusted.gpg.d/<name>.gpg` (or `.asc`).
    - Remvoe key: `apt-key del <key-id>`
        - The 8-digit hex key ID may either be found on `pub` line or as the last 8 hex digits on the continuation line.
- Preferences:
    - Used to override package priorities, to control which package version or origin is used (or not).
    - Show policy for package: `apt-cache policy <package>`
    - Preferences are stored in `/etc/apt/preferences` and `/etc/apt/preferences.d/<name>`.
- Log:
    - See `/var/log/dpkg.log`.
- Error handling (when `apt install -f` doesn't fix it):
    - Always run `apt install -f` afterwards, to make sure the problem is resolved and make sure APT isn't left in an errored state.
    - If package conflict, force removal of conflicting package: `dpkg -r --force-depends <package>`
    - If cache trouble, clean the cache: `apt clean` (or `apt autoclean`)

#### Pacman (Arch)

- Full system upgrade: `pacman -Syu`
- Search package: `pacman -Ss <package-name>`
- Show package info: `pacman -Si <package>`
- Install package: `pacman -S <packages>`
    - Never use `-Sy` to avoid partial upgrades.
- Remove package: `pacman -R <packages>`
    - Remove orphans too: `-s`
    - Purge configurations: `-n`
- Autoremove packages: `pacman -R $(pacman -Qdtq)`

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
    - (Note) `ss` replaces `netstat` and is mostly option compatible.
    - Option `tu`: Include TCP and UDP sockets (no UNIX sockets).
    - Option `l`: Include listening sockets (no client sockets).
    - Option `p`: Show protocol (requires root).
    - Option `n`: Don't translate port numbers to common service names.
- Show misc. stats:
    - Show kernel SNMP counters: `nstat`
    - Show per-protocol stats: `netstat -s`
- Bring interface up or down:
    - (Note) Your network manager probably has a more appropriate way to do this.
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
    - Show route used for destination address: `ip route get <dst>`
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

#### Net-SNMP (Client)

- Walk (v2c): `snmpwalk -v2c -c<community> <host> [oid]`
- Walk (v3 auth+priv): `snmpwalk -v3 -l authpriv -u <user> -a SHA -A <auth-pass> -x AES -X <priv-pass> <host> [oid]`
- Examples:
    - Get MAC table for VLAN (v2c): `snmpwalk -v2c -c<community>@<vid> <host> BRIDGE-MIB::dot1dTpFdbTable` (defaults: VLAN 1)
    - Get MAC table for VLAN (v3 w/ context): `snmpwalk -v3 <auth-args> -nvlan-<vid> <host> BRIDGE-MIB::dot1dTpFdbTable` (defaults: VLAN 1)

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
- Generate xkcd-style (multi-word) passwords (using package `xkcdpass`): `xkcdpass`
- Generate SHA cryptographical hashes: `sha{256,512} <files>`

#### PGP/GPG

Using GPG (from package `gnupg2` on Debian).

- Use a local or temporary keyring instead of default one:
    - This is useful if you need to verify a downloaded file with the signing pubkey, but don't want to permanently import the key.
    - Create the keyring and import the key: `gpg --no-default-keyring --keyring ./tmp.keyring --import <pubkey>` (example)
    - Use it by specifying `-no-default-keyring --keyring ./tmp.keyring` in the commands where you need it.
    - Delete it and the `~`-suffixed backup of it when you no longer need it.
- Inspect pubkey:
    - Imported: **TODO**
    - File: `gpg --show-keys <keyfile>`
    - Key server: **TODO**
- Import pubkey:
    - Unless using a keyfile you know is trusted, always verify the fingerprint of imported keys against some trusted source.
    - Import to local/temporary keyring: See section about it.
    - Import from file: `gpg --import <pubkey>`
    - Import from key server: `gpg [--keyserver <url>] --recv-keys <key-id>`
- Check signature of file using a detached signature field (typically `.asc`), the publisher's signing pubkey file, and temporary keyring (complete example):
    1. Download the archive, archive signature and publisher pubkey.
    1. Import the key to a local keyring: `gpg --no-default-keyring --keyring ./tmp.keyring --import <keyfile>`
    1. Verify the archive: `gpg --no-default-keyring --keyring ./tmp.keyring --verify <sig-file> <data-file>`

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
- Monitor USB traffic:
    - Install usbmon (Arch): `yay -S usbtop`
    - Load module: `modprobe usbmon`
    - View live traffic: `sudo usbtop`
- Run command with high or low CPU priority:
    - Command: `nice -n<n> <cmd>` (`-20 <= n <= 19`)
    - The nice value goes from -20 (highest priority) to 19 (lowest priority), with 0 as the default priority.
    - The nice value is inherited by child processes (meaning forking processes maintains the nice value it started with).
    - Use `renice` to change the value.
    - Use `ionice` to set the I/O scheduler and scheduler-specific priority.
- Stress test with stress/stress-ng (see [Computer Testing](/general/computer-testing/)):
    - Install (Debian): `apt install stress-ng`
    - Install (Arch): `apt install stress`
    - Stress CPU: `stress(-ng) -c $(nproc) -t $((10*60))` (use all CPU threads for 10 minutes)
- Chroot into other Linux installation:
    1. (Note) Used to e.g. fix a broken install or reset a user password from a USB live ISO.
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

## Resources

### Security

- [Linux Hardening Checklist (trimstray)](https://github.com/trimstray/linux-hardening-checklist)
- [The Practical Linux Hardening Guide (trimstray)](https://github.com/trimstray/the-practical-linux-hardening-guide)

{% include footer.md %}
