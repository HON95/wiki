---
title: Computer Testing
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Information Gathering

### Linux

- Show CPU vulnerabilities: `tail -n +1 /sys/devices/system/cpu/vulnerabilities/*`

## CPU

### Prime95

- For stress testing.
- For most OSes.
- Install: [Download](https://www.mersenne.org/download/).

## RAM

### MemTest86

- For health error testing.
- Standalone/bootable.
- Install: [Download](https://www.memtest86.com/download.htm)
    - Use v4 for systems without UEFI support.
- Not the same as Memtest86+. Memtest86+ is an old fork of Memtest86.

## Storage

### smartmontools

- For health testing.
- For Linux.
- See [smartmontools](../../linux-general/applications/#smartmontools).

{% include footer.md %}
