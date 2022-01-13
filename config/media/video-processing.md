---
title: Video Processing
breadcrumbs:
- title: Configuration
- title: Media
---
{% include header.md %}

## General

- Copy files from memory card (lol):
    - Mount the card: `sudo mount /dev/mmcblk0p1 /mnt/lol0`
    - Copy over the files: `rsync -a --progress /mnt/lol0/DCIM/100GOPRO/*.MP4 ~/Desktop/GoPro-2021-jul-ned`
    - Unmount the card: `sudo umount /mnt/lol0`
- Show media info about some media file: `mediainfo <file>` (requires `mediainfo`)

{% include footer.md %}
