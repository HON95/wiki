---
title: VLC
breadcrumbs:
- title: Configuration
- title: Media
---
{% include header.md %}

## Resources

- [Command line (VideoLAN)](https://wiki.videolan.org/Documentation:Command_line/)
- [Command line streaming (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Advanced_Streaming_Using_the_Command_Line/)
- [Command line streaming examples (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/)
- [Streaming over IPv6 (VideoLAN)](https://wiki.videolan.org/Documentation:Streaming_HowTo/Streaming_over_IPv6/)

## General

- Hide GUI:
    - Linux: Use `cvlc` instead of `vlc`.
    - Windows: Specify `-I dummy --dummy-quiet`.

## Access Modules

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

## Stream Output Modules

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

## Video and Sub Filter Modules

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

## View Stream

- View stream: `vlc <proto>://<host>[:port][/path]`
    - RTSP (example): `vlc rtsp://<host>:554 --rtsp-user=$rtsp_username --rtsp-pwd=$rtsp_password`
- Specify `--network-caching=100` (milliseconds) to reduce network buffering causing delay (defaults to 1000ms).
- Use `cvlc` (Linux) or specify `-I dummy --dummy-quiet` (Windows) to not use the full GUI.
- Specify `--fullscreen` to start in full screen.

## Examples

### Media Processing

- Convert/transcode or fix badly encoded files (GUI method):
    1. Note: E.g. when othe programs complain that a GoPro video file is corrupted but VLC still manages to open it somehow.
    1. Open VLC.
    1. Go to "File", "Convert".
    1. Open add the source files.
    1. Press "Convert/save".
    1. Select some appropriate profile/formats (use e.g. `mediainfo` to check the format of the source files).
    1. Wait for the playlist to finish "playing" (kinda weird but whatever).
- Concatenate files (no transcoding): `cvlc <input-files-ordered> --sout "#gather:std{access=file,dst=full.mp4}" --sout-keep` (**TODO** `cvlc` doesn't exit when done for me, maybe use `vlc` and manually close the window when it's visually done instead.)

### Streaming

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

{% include footer.md %}
