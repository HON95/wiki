---
title: Video Processing
breadcrumbs:
- title: Configuration
- title: Media
---
{% include header.md %}

## FFmpeg

For general notes and streaming video notes, see the [Video Streaming](../video-streaming/) page.

### Tasks

#### Concatenate Video Files

Useful e.g. to recombine video files for recorders which automatically splits the recording.

1. `ffmpeg -f concat -safe 0 -i <(for f in ./*.MP4; do echo "file '$PWD/$f'"; done) -c copy output.MP4`
    - For lexicographically sorted files ending in `.MP4`.

#### Speed Up/Slow Down Video, but Keep All Frames

Useful e.g. to change the framerate of a video-only timelapse video.

See: [Speeding up/slowing down video (FFmpeg)](https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video)

1. Convert to raw bitstream:
    - H.264: `ffmpeg -i input.mp4 -map 0:v -c:v copy -bsf:v h264_mp4toannexb raw.h264`
    - H.265: `ffmpeg -i input.mp4 -map 0:v -c:v copy -bsf:v hevc_mp4toannexb raw.h265`
1. Generate new video: `ffmpeg -fflags +genpts -r <fps> -i raw.h264 -c:v copy output.mp4` (for desired frame rate `fps`)

{% include footer.md %}
