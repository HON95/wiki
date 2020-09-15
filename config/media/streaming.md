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

## VLC

- Resources:
    - [Command line (VideoLAN)](https://wiki.videolan.org/Documentation:Command_line/)
    - [Command line streaming (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Advanced_Streaming_Using_the_Command_Line/)
    - [Command line streaming examples (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/)
    - [Streaming over IPv6 (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Streaming_over_IPv6/)
- Hide GUI:
    - Linux: Use `cvlc` instead of `vlc`.
    - Windows: Specify `-I dummy --dummy-quiet`.

### Access Modules

- Screen capture (`screen`):
    - [screen module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/screen/)
    - Super laggy.
    - Captures all screens by default. Specify coordinates and dimensions to capture a specific screen or section.
    - CLI format: `screen//`
    - CLI example: `screen:// --screen-top=0 --screen-left=1920 --screen-width=1920 --screen-height=1080`
- Video4Linux 2 (`v4l2`) (Linux):
    - [v4l2 module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/v4l2/)
    - Requires V4L2 to be installed. `v4l2-ctl` can be used to control video/webcamera settings. See separate section about V2L2.
    - CLI format: `v4l2://<dev> [v4l2-options]`
    - CLI example: `v4l2:///dev/video0:width=1920:height=1080:fps=30:chroma=mjpg` (**TODO** v4l2 prefix and `--` instead of `:`?)
    - Specify format: `chroma=<format>` (e.g. `mjpg` or `h264` if supported) (`yuyv` may be the default and gives terrible frame rate)
    - Specify width, height, frame rate: `width=1920:height=1080:fps=30` (1080p)
- DirectShow (`dshow`) (Windows):
    - CLI format: `dshow:// [dshow-options]`
    - CLI example: `dshow:// --dshow-vdev="Game Capture HD60 S (Video) (#01)" --dshow-adev=none  --dshow-aspect-ratio=16:9 --dshow-fps=60`
    - You can open "open capture device", select the device and selecting "show more options" in the GUI to find the exact names of the audio and video devices.

### Stream Output Modules

- Specify chain of output modules: `--sout=#module1{options}:module2{options}:module3...`
- Standard (`standard`/`std`):
    - Save the stream to file or send it over a network.
    - HTTP example: `--sout='#[...]:standard{access=http,mux=ts}' --http-host=localhost --http-port=5555`
    - The `ts` mux is the most common one.
- Transcode (`transcode`):
    - Transcode the video.
    - Codec list: [Codec (VideoLAN)](https://wiki.videolan.org/Codec/)
    - Specify video codec using `vcodec=` and audio codec using `acodec=`. Use `none` to disable audio or video. Common video codecs include `h264` (very good and very intense), `mp2v` (good quality but bad/small compression) and `mp4v` (better compression).
    - Specify the video and audio buffer sizes in kB/s using `vb=` and `ab=`.
    - Specify `deinterlace` when using an interlaced source to improbe the quality a little.
- Duplicate (`duplicate`):
    - Duplicate the feed, e.g. to send it to different destinations.
- Display (`display`):
    - Show the input stream locally. Can be used to verify that the input or previous parts chain is working as expected. Can be used with `duplicate` to monitor the stream.
- RTP/RTSP (`rtp`):
    - Stream as RTP, optionally with RTSP.
    - Basic example: `rtp{mux=ts,dst=<addr>,port=<port>}`
    - `dst` must be some destination unicast or multicast address. `port` may be omitted to use the default.
    - Uses UDP by default.

### Video and Sub Filter Modules

- Specified using `--sub-source=<...>`.
- Marquee (`marq`):
    - [marq module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/marq/)
    - Show text and/or time on the screen.
    - For positions and colors, see [time module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/time/).
    - To show it in the output stream, specify the `sfilter=marq` transcode option instead of using `--video-filter=logo`.
    - Example (local): `--sub-source=marq --marq-marquee="%Y-%m-%d, %H:%M:%S" --marq-position=9 --marq-color=0xFFFFFF --marq-size=20`
- Logo (`logo`):
    - [logo module (VideoLAN)](https://wiki.videolan.org/Documentation:Modules/logo/)
    - [HowTo Add a logo (VideoLAN)](https://wiki.videolan.org/VLC_HowTo/Add_a_logo/)
    - Show one or a series of looping images.
    - The image doesn't seem to be scalable, so scale the file beforehand.
    - To show it in the output stream, specify the `sfilter=logo` transcode option instead of using `--video-filter=logo`.
    - Example (local): `--video-filter=logo --logo-file=/c/Users/1234 --logo-position=0 --logo-opacity=255`

### View Stream

- View stream: `vlc <proto>://<host>[:port][/path]`
- Specify `--network-caching=100` (milliseconds) to reduce network buffering causing delay (default to 1 second).
- Use `cvlc` (Linux) or specify `-I dummy --dummy-quiet` to not use the full GUI.
- Specify `--fullscreen` to start in full screen.

### Stream Examples

- Stream webcam with RTP (no RTSP) (Linux):
    - Command: `cvlc v4l2:///dev/video0:width=1920:height=1080:fps=30:chroma=mjpg --live-caching=10 --sout='#transcode{vcodec=mp4v,acodec=none}:rtp{mux=ts,dst=localhost}'`
    - `dst` is the destination unicast or multicast address to continuously stream to.
- Stream webcam with HTTP (Linux):
    - Command: `cvlc v4l2:///dev/video0:width=1920:height=1080:fps=30:chroma=mjpg --live-caching=10 --sout='#transcode{vcodec=mp4v,acodec=none}:standard{access=http,mux=ts}' --http-host=localhost --http-port=5555`
    - HTTP streams may be easily used as sources in e.g. OBS.
- Stream capture card to display and HTTP stream (Windows):
    - Command: `./vlc -I dummy --dummy-quiet dshow:// --dshow-vdev="Game Capture HD60 S (Video) (#01)" --dshow-adev=none  --dshow-size=1920x1080 --dshow-aspect-ratio=16:9 --dshow-fps=60  --live-caching=10 --sout='#transcode{vcodec=mp2v,acodec=none,sfilter=logo}:duplicate{dst=display,dst=standard{access=http,mux=ts}}' --http-host=localhost --http-port=5555`
- Record network stream to file (Linux):
    - Command: `cvlc <input> --sout='#transcode{vcodec=mp4v,acodec=none}:std{access=file,mux=ps,dst=test.mpg}'`

## FFmpeg

- Install:
    - Linux (Ubuntu): `apt install ffmpeg`
    - Windows: Download the binary.
- View video feed: `ffplay <dev>`
    - For some reason this typically uses a limited framerate and resolution.
- Options:
    - `-crf 23`: Constant rate factor. Defaults to 23. Set to 0 for lossless video.

### Examples

- Record stream to file, automatically split every X seconds, restart if the stream is unavailable:
    - Script: `while true; do ffmpeg -hide_banner -loglevel error -i http://localhost:5555/ -c copy -map 0 -f segment -segment_time $((5*60)) -segment_format mp4 -strftime 1 "%Y-%m-%d_%H-%M-%S.mp4"; sleep 5; done`
- Record time lapse at 10x speed without audio:
    - Command: `ffmpeg -i http://localhost:5555/ -filter:v "setpts=0.1*PTS" -an out.mkv`

## Video4Linux 2 (V4L2) (Linux)

- Install: `apt install v4l-utils`
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

{% include footer.md %}
