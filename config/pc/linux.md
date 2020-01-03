---
title: Linux
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}
Debian 10 Buster

## Examples

### Commands

#### File Systems and Logical Volume Managers

- Partition disk: `gdisk <dev>` (GPT) or `fdisk <dev>` (MBR)
- Create filesystem: `mkfs.<fs> <dev>`
- ZFS: See ZFS (**TODO**).

#### Files

- Find files:
  - By UID: `find / -user <UID>`
  - Without a user: `find / -nouser`
  - With setuid permission bit: `find / -perm /4000`
- Recursive search and replace: `find <dir> \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/123/456/g'`
  - `-type d -name .git -prune` skips `.git` directories and can be excluded outside of git repos.

#### Fun

- Pretty colors: `something | lolcat`

#### Installations and Packages

- Find packages depending on the package: `apt rdepends --installed <package>`

#### Performance and Power Efficiency

- Set the CPU frequency scaling governor mode:
    - High performance: `echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
    - Power save: ` echo powersave | ...`
- Monitor system and processes: `htop`
- Monitor interrupt usage: `irqtop`

#### Processes and Memory

- Useful ps args: `ps ax o uid,user:12,pid,comm`

### Tasks

#### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

{% include footer.md %}
