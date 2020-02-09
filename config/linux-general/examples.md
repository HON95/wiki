---
title: Linux Examples
breadcrumbs:
- title: Configuration
- title: Linux General
---
{% include header.md %}

## Commands

### File Systems and Logical Volume Managers

- Partition disk: `gdisk <dev>` or `fdisk <dev>`
- Create filesystem: `mkfs.<fs> <dev>`

### Files

- Find files:
  - By UID: `find / -user <UID>`
  - Without a user: `find / -nouser`
  - With setuid permission bit: `find / -perm /4000`
- Recursive search and replace: `find <dir> \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/123/456/g'`
  - `-type d -name .git -prune` skips `.git` directories and can be excluded outside of git repos.

### Fun

- Pretty colors: `<something> | lolcat`

### Installations and Packages

- Find packages depending on the package (APT): `apt rdepends --installed <package>`

### Monitoring

- Monitor system and processes: `htop`
- Monitor interrupt usage: `irqtop`
- Monitor network load: `nload`
- Monitor lots of stuff: `glances`

### Performance and Power Efficiency

- Set the CPU frequency scaling governor mode:
    - High performance: `echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
    - Power save: ` echo powersave | ...`
- Show current core frequencies: `grep "cpu MHz" /proc/cpuinfo | cut -d' ' -f3`

### Processes and Memory

- Useful ps args: `ps ax o uid,user:12,pid,comm`

### Security

- Show CPU vulnerabilities: `tail -n +1 /sys/devices/system/cpu/vulnerabilities/*`

## Tasks

### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

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
