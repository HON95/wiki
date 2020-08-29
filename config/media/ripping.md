---
title: Media Ripping
breadcrumbs:
- title: Configuration
- title: Media
---
{% include header.md %}

## Download Videos from YouTube and Sites

Using [youtube-dl](http://ytdl-org.github.io/youtube-dl/) ([repo](https://github.com/ytdl-org/youtube-dl)).

- Run in Docker:
    - Using ([wernight's image](https://github.com/wernight/docker-youtube-dl)).
    - Command prefix: `docker run --rm -v//$PWD:/downloads wernight/youtube-dl <...>`
- Run binary:
    - Find the download instructions in the repo.
    - Install "ffmpeg" to allow downloading best quality audio and video: `apt install ffmpeg`
- Download single video: `youtube-dl -c <URL>`
    - `-c`/`--continue` to re-run the command if it previously failed during download.
- Download full channel or playlist: `youtube-dl -qiwc --no-warnings [-o <format>] <URL>`
    - `-q`/`--quiet` and `--no-warnings` to only errors. Alternatively, redirect STDERR to a log file and keep STDOUT non-quiet to be able to check the status. There may be videos that fail to download for different reasons, so do watch for errors.
    - `-i`/`--ignore-errors` to avoid stopping on errors.
    - `-wc`/`--no-overwrites --continue` to download only new/missing videos.
    - `-o <format>` to specify the output filename format. See below.
- Video quality:
    - Specify `-f bestvideo+bestaudio` to download the best video format and best audio format and (by default) merge them. This is the default, but only as long as "ffmpeg" is installed. If it's not installed and this option is not specified, it may instead download a lower quality format.
- Download audio from video: `youtube-dl -c --extract-audio --audio-quality 0`
    - `--audio-format <format>`: Audio format, like "mp3", "wav", etc. Defaults to "best".
    - `--audio-quality <0-9>`: Audio quality, where 0 is best. Defaults to "5".
- Modify the output file path and name:
    - Supports a Python-style format string.
    - See [output template (youtube-dl)](https://github.com/ytdl-org/youtube-dl#output-template) for a list of variables.
    - Example: `-o "%(uploader)s (%(upload_date)s) - %(title)s [%(id)s].%(ext)s"`
- Full examples:
    - YouTube video (video/channel/playlist): `youtube-dl -iwc -f bestvideo+bestaudio --cookie ~/cookies.txt -o "%(uploader)s (%(upload_date)s) - %(title)s [%(id)s].%(ext)s" <url>`
- Common warnings and errors:
    - "*WARNING: Requested formats are incompatible for merge and will be merged into mkv.*": The best quality video and audio are different formats and will therefore be merged into an MKV file. This is completely fine.
    - "*ERROR: [...]: YouTube said: Unable to extract video data*": Try to open the video in an incognito browser to check what's up with it. If it requires you to log in, you may need to specify cookies and possibly your user agent. To specify cookies, log into a browser (Firefox or Chrome), export the cookies to file using the "cookie.txt" extension, and specify the cookie file for youtube-dl with the `--cookie <file>` option (see [How do I pass cookies to youtube-dl? (youtube-dl)](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#how-do-i-pass-cookies-to-youtube-dl)).

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
