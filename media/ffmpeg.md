---
title: FFmpeg
breadcrumbs:
- title: Media
---
{% include header.md %}

## TODO

(Ignore this section.)

- `-crf 23`: Constant rate factor. Defaults to 23. Set to 0 for lossless video.

## Resources

- [steven2358: FFmpeg cheat sheet](https://gist.github.com/steven2358/ba153c642fe2bb1e47485962df07c730)
- [NVIDIA Developer Blog: NVIDIA FFmpeg Transcoding Guide](https://developer.nvidia.com/blog/nvidia-ffmpeg-transcoding-guide/)

## Installation

(Including V4L2 for Linux distros.)

- Linux (Ubuntu/Debian): `sudo apt install ffmpeg v4l-utils`
- Linux (Arch): `sudo pacman -S ffmpeg v4l-utils`
- Windows: Download binaries from some FFmpeg mirror site.

## View fTODO

- View video feed: `ffplay <dev>`
    - For some reason this typically uses a limited framerate and resolution.

## Examples

### Recording

- Record stream to file, automatically split every X seconds, restart if the stream is unavailable:
    - Script: `while true; do ffmpeg -hide_banner -loglevel error -i http://localhost:5555/ -c copy -map 0 -f segment -segment_time $((5*60)) -segment_format mp4 -strftime 1 "%Y-%m-%d_%H-%M-%S.mp4"; sleep 1; done`
- Record time lapse at 10x speed without audio:
    - Command: `ffmpeg -i http://localhost:5555/ -filter:v "setpts=0.1*PTS" -an out.mkv`

## Tasks

### Concatenate Video Files

Useful e.g. to recombine video files for recorders which automatically splits the recording.

1. `ffmpeg -f concat -safe 0 -i <(for f in ./*.MP4; do echo "file '$PWD/$f'"; done) -c copy output.MP4`
    - For lexicographically sorted files ending in `.MP4`.

### Speed Up/Slow Down Video, but Keep All Frames

Useful e.g. to change the framerate of a video-only timelapse video.

See: [Speeding up/slowing down video (FFmpeg)](https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video)

1. Convert to raw bitstream:
    - H.264: `ffmpeg -i input.mp4 -map 0:v -c:v copy -bsf:v h264_mp4toannexb raw.h264`
    - H.265: `ffmpeg -i input.mp4 -map 0:v -c:v copy -bsf:v hevc_mp4toannexb raw.h265`
1. Generate new video: `ffmpeg -fflags +genpts -r <fps> -i raw.h264 -c:v copy output.mp4` (for desired frame rate `fps`)

{% include footer.md %}
