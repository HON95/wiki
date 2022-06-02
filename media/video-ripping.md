---
title: Video Ripping
breadcrumbs:
- title: Media
---
{% include header.md %}

## Rip DVDs (Linux)

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
