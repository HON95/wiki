---
title: Video Streaming
breadcrumbs:
- title: Configuration
- title: Media
---
{% include header.md %}

## General

- Resources:
    - [Webcam setup (ArchWiki)](https://wiki.archlinux.org/index.php/Webcam_setup)

## Hardware

- Some webcams come with H264 hardware encoders. Notably, Logitech's C920/C922 had a H264 hardware encoder in earlier versions but then removed it.
- Webcams may require/reserve a lot of bandwidth, so try to avoid USB hubs.

## Utility Stuff

- Install Video 4 Linux 2 (v4l2): `apt install v4l-utils`
- Show video devices:
    - List devices: `v4l2-ctl --list-devices`
    - Show brief device info: `v4l2-ctl [-d <dev>] --info`
    - Show extended device info: `v4l2-ctl [-d <dev>] --all`
    - Show device formats: `v4l2-ctl [-d <dev>] --info --list-formats`
    - If no device is specified, it defaults to `/dev/video0`.
    - Certain devices show up as multiple `/dev/video*` files. Typically there's one video capture device and one metadata capture device. Use the command above to find out.
- Modify video device properties:
    - Show properties with min, max and current values: `v4l2-ctl [-d <dev>] --all`
    - Different webcams come with different properties and property names.
    - Change a property (non-permanent): `v4l2-ctl [-d <dev>] -c <property>=<value>`
    - Properties may be modified while the device is in use.
    - As property changes are not permanent, you may want to set them in a script or something.
    - Higher exposure may lead to reduced frame rate. To make it brighter you may increase the gain instead.
    - Focus and white balance _can_ typically be left at auto. Brightness, contrast and saturation _should_ typically be left at default.
    - Logitech C920 and similar:
        - Disable auto focus: `focus_auto=0`
        - Disable auto exposure: `exposure_auto=1`
        - Set exposure manually (after auto is disabled): `exposure_absolute=250`
        - Set gain: `gain=250`
        - Disable auto white balance: `white_balance_temperature_auto=0`
        - Set white balance manually (after auto is disabled): `white_balance_temperature=4000`
        - Set brightness, contrast and saturation (generally not needed): `brightness=128`, `contrast=128`, `saturation=128`
- Show video feed using `ffplay`:
    - Requires package `ffmpeg` (Ubuntu).
    - Command: `ffplay <dev>`
    - For some reason this typically uses a limited framerate and resolution.

## VLC

- Resources:
    - [Command line (VideoLAN)](https://wiki.videolan.org/Documentation:Command_line/)
    - [Command line streaming (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Advanced_Streaming_Using_the_Command_Line/)
    - [Command line streaming examples (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/)
    - [Streaming over IPv6 (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Streaming_over_IPv6/)
- Basic command format: `vlc <input> --sout=#module1{options}:module2{options}:module3...`
- Some modules:
    - `standard`/`std`: Save the stream to file or send it over a network.
    - `transcode`: Transcode the video.
    - `duplicate`: Duplicate the feed, e.g. to send it to different destinations.
    - `display`: Show the input stream locally. Can be used to verify that the input or previous parts chain is working as expected. Can be used with `duplicate` to monitor the stream.
    - `rtp`: Stream as RTP/RTSP.
- Transcode module options:
    - Codec list: [Codec (VideoLAN)](https://wiki.videolan.org/Codec/)
    - Specify video codec using `vcodec=` (e.g. `mp4v` or `h264`) and audio codec using `acodec=`. Use `none` to disable audio or video.
    - Specify the video and audio buffer sizes in kB/s using `vb=` and `ab=`.
- Standard module options:
    - HTTP example: `--sout='#[...]:standard{access=http,mux=ts}' --http-host=localhost --http-port=5555`
    - The `ts` mux is the most common one.
- RTP module options:
    - Supports RTSP.
    - Basic example: `rtp{mux=ts,dst=<addr>,port=<port>}`
    - `dst` must be some destination unicast or multicast address. `port` may be omitted to use the default.
    - Uses UDP by default.
- v4l2 input module:
    - [v4l2 module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/v4l2/)
    - Input format: `v4l2://<dev>[:<option>=<value>][more-options]`
    - Specify format: `chroma=<format>` (e.g. `mjpg` or `h264` if supported) (`yuyv` may be the default and gives terrible frame rate)
    - Specify width, height, frame rate: `width=1920:height=1080:fps=30` (1080p)
- Stream webcam with RTP (no RTSP) (example):
    - Command: `cvlc v4l2:///dev/video0:width=1920:height=1080:fps=30:chroma=mjpg --live-caching=10 --sout='#transcode{vcodec=mp4v,acodec=none}:rtp{mux=ts,dst=localhost}'`
    - `dst` is the destination unicast or multicast address to continuously stream to.
- Stream webcam with HTTP (example):
    - Command: `cvlc v4l2:///dev/video0:width=1920:height=1080:fps=30:chroma=mjpg --live-caching=10 --sout='#transcode{vcodec=mp4v,acodec=none}:standard{access=http,mux=ts}' --http-host=localhost --http-port=5555`
    - HTTP streams may be easily used as sources in e.g. OBS.
- View network stream (example):
    - View RTP stream: `vlc [--network-caching=100] <protocol>://<url>`
    - Specify `--network-caching=<delay>` to set the buffering delay in milliseconds. Defaults to 1 second.
    - Use `cvlc` to only show the video output and not the whole GUI.
- Record network stream to file (example):
    - Command: `cvlc <input> --sout='#transcode{vcodec=mp4v,acodec=none}:std{access=file,mux=ps,dst=test.mpg}'`

## Record to File

- Record HTTP (MPEG?) stream to file, automatically split every X seconds, restart if the stream is unavailable: `while true; do ffmpeg -hide_banner -loglevel error -i http://localhost:5555/ -c copy -map 0 -f segment -segment_time $((5*60)) -segment_format mp4 -strftime 1 "%Y-%m-%d_%H-%M-%S.mp4"; sleep 5; done`

{% include footer.md %}
