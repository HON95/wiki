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
    - `ss <options>`
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

### Performance and Power Efficiency

- Set the CPU frequency scaling governor mode:
    - High performance: `echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
    - Power save: `echo powersave | ...`
- Show current core frequencies: `grep "cpu MHz" /proc/cpuinfo | cut -d' ' -f3`

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
- Stress test:
    - Stress CPU: `stress-ng -c $(nproc) -t 600`

## Tasks

### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

### Download Videos from YouTube and Sites

- Using [youtube-dl](http://ytdl-org.github.io/youtube-dl/) ([repo](https://github.com/ytdl-org/youtube-dl)).
- Use Docker ([wernight's image](https://github.com/wernight/docker-youtube-dl)): `docker run --rm -v//$PWD:/downloads wernight/youtube-dl <...>`
- Download single video: `youtube-dl -c <URL>`
    - `-c`/`--continue` to re-run the command if it previously failed during download.
- Download full channel or playlist: `youtube-dl -qiwc --no-warnings [-o <format>] <URL>`
    - `-q`/`--quiet` and `--no-warnings` to only errors. Alternatively, redirect STDERR to a log file and keep STDOUT non-quiet to be able to check the status. There may be videos that fail to download for different reasons, so do watch for errors.
    - `-i`/`--ignore-errors` to avoid stopping on errors.
    - `-wc`/`--no-overwrites --continue` to download only new/missing videos.
    - `-o <format>` to specify the output filename format. See below.
- Download audio from video: `youtube-dl -c --extract-audio --audio-quality 0`
    - `--audio-format <format>`: Audio format, like "mp3", "wav", etc. Defaults to "best".
    - `--audio-quality <0-9>`: Audio quality, where 0 is best. Defaults to "5".
- Modify the output file path and name:
    - Supports a Python-style format string.
    - See [output template (youtube-dl)](https://github.com/ytdl-org/youtube-dl#output-template) for a list of variables.
    - Example: `-o "%(uploader)s (%(upload_date)s) - %(title)s [%(id)s].%(ext)s"`
- Common warnings and errors:
    - "*WARNING: Requested formats are incompatible for merge and will be merged into mkv.*": The best quality video and audio are different formats and will therefore be merged into an MKV file. This is completely fine.
    - "*ERROR: [...]: YouTube said: Unable to extract video data*": Try to open the video in an incognito browser to check what's up with it. If it requires you to log in, you may need to specify cookies and possibly your user agent. To specify cookies, log into a browser (Firefox or Chrome), export the cookies to file using the "cookie.txt" extension, and specify the cookie file for youtube-dl with the `--cookie <file>` option (see [How do I pass cookies to youtube-dl? (youtube-dl)](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#how-do-i-pass-cookies-to-youtube-dl)).

### Rip DVD to ISO

CDs and DVDs use 2048 byte sectors and may have both unintentional and intentional data errors.
Some will explode in size when you try to rip them.
There are multiple methods to try.
I recommend using ddrescue since it's the simplest and because of its error handling features.

Install support for encrypted/protected DVDs:
- Enable the `contrib` or `non-free` repo areas (I'm not sure which).
- `apt install libdvd-pkg && dpkg-reconfigure libdvd-pkg`

Gather information about the disc:
- (Once) `apt install genisoimage`
- `isoinfo -d -i /dev/sr0`

#### Using dvdbackup

1. (Once) `apt install dvdbackup`
1. (Optional) Inspect the DVD: `dvdbackup -i /dev/sr0 -I`
1. Rip the whole DVD to a subdirectory: `dvdbackup -i /dev/sr0 -o . -M`
1. Make an ISO: `genisoimage -dvd-video -udf -o <name>{.iso,}`

#### Using vobcopy

1. (Once) `apt install vobcopy`
1. Mount the disc: `mkdir -p /media/dvd && mount /dev/dvd /media/dvd`
1. Rip it to the current dir: `vobcopy -i /media/dvd -l -m`
1. Unmount the disc: `umount /media/dvd`

#### Using dd

If the disc is damaged, use ddrescue instead.

1. Find sector size and count: `isosize -x /dev/sr0`
1. `dd if=/dev/sr0 of=<name>.iso bs=2048 count=3659360 conv=noerror status=progress`
    - `conv=noerror` prevents halting on error and writes zero to the output instead.

#### Using GNU ddrescue

ddrescue is a sophisticated recovery tool which gracefully handles read errors.
When using a map file, it can be aborted and run multiple times and using different sources to try to fix corrupt sections.
A typical way to use this method is to run it with fast options first and then optionally with slower options afterwards.
When the output is a regular file, the corrupt sectors will contain zeros.
This method can also be used to backup dying hard drives etc., but the options used below are for CD/DVD discs.

1. (Once) `apt install gddrescue`
1. Make sure the disk/disc is not mounted.
1. Run without scraping: `ddrescue -n -b2048 /dev/sr0 <name>.{iso,map}`
1. Run with direct access: `ddrescue -d -r1 -b2048 /dev/sr0 <name>.{iso,map}`

{% include footer.md %}
