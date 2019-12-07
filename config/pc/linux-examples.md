---
title: Linux Examples
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
---
{% include header.md %}

Using: Debian 10 Buster

## Commands

### File Systems and Logical Volume Managers

- Partition disk: `gdisk <dev>` \(GPT\) or `fdisk <dev>` \(MBR\)
- Create filesystem: `mkfs.<fs> <dev>`
- ZFS: See ZFS \(**TODO**\).

### Files

- Find files:
  - By UID: `find / -user <UID>`
  - Without a user: `find / -nouser`
  - With setuid permission bit: `find / -perm /4000`

### Fun

- Pretty colors: `something | lolcat`

### Hardware

- Check if hard drives are spinning: `smartctl -i -n standby /dev/sdc | grep "^Power mode"`
  - "Active" and "idle" means most likely spinning, "standby" and "sleeping" means most likely not spinning.
- Get physical block size of drive: `hdparm -I /dev/sda | grep -i physical`

### Installations and Packages

- Find packages depending on the package: `apt rdepends --installed <package>`

### Processes and Memory

- Useful ps args: `ps ax o uid,user:12,pid,comm`

## Tasks

### Burn Windows ISO

1. Install the graphical application `woeusb` from `ppa:nilarimogard/webupd8`.

{% include footer.md %}
