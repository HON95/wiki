---
title: Open Broadcaster Software (OBS)
breadcrumbs:
- title: Media
---
{% include header.md %}

## Info

- Color format:
    - NV12 means Y'UV/Y'CbCr 4:2:0 chroma subsampling (chroma resolution halved in both dimensions), which is what OBS always uses for streaming output (see [issue #3517](https://github.com/obsproject/obs-studio/issues/3517)).
    - RGB provides the most detailed colors, but with overhead. It's pointless to use for streaming.
    - GPU offloading might support only some formats (I _think_ it supports NV12 but not e.g. RGB).
- Color space:
    - Use BT.709, it's newer than BT.601.
- Color range:
    - "Full" is a little better, but mostly pointless for streaming. Use "partial".
- Make sure to set the color format, color space and color range both in the OBS advanced settings and for sources, and try to keep them consistent.

## Plugins

### OBS NDI Plugin

- Setup (Windows):
    1. Download the `obs-ndi-*-Windows.zip` archive: [Download](https://github.com/Palakis/obs-ndi/releases)
    1. Copy the files into the OBS installation directory (merge with existing directories).
    1. Start OBS.
    1. If you haven't installed NDI or NDI Tools, a warning should appear with a download link. Install it and restart OBS.
    1. Make sure NDI sources are available from the "new source" list.
- Info:
    - It uses "raw" NDI, not NDI|HX (compressed), meaning a 1920x1080 60Hz stream could use up to 132Mb/s (throughput from an NDI whitepaper).
- Issues (the ones I've faced):
    - Growing latency over time (1s delay after ~30m): https://github.com/Palakis/obs-ndi/issues/667
        - Maybe low latency mode (async OBS output) fixes this? Might introduce stutter tho.

{% include footer.md %}
