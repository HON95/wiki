---
title: Network Device Interface (NDI)
breadcrumbs:
- title: Media
---
{% include header.md %}

A network video protocol by NewTek.

## Info

- A royalty-free protocol by NewTek for sharing video over IP in a standard Gigabit LAN (or better).
- Provides multiple high-quality, low-latency and frame-accurate video and audio feeds.
- Uses mDNS by default for autodiscovery. Alternatively, one or more discovery servers may be used.
- Supports multicast sending, but it's disabled by default.

### Encoding

- The normal, high-bandwidth encoder is simply called "NDI".
- NDI provides multi-generational stability, meaning repeated encodings don't degrade quality.
- Has a technical latency of 16 video scan lines, although typically lower in implementations.
- "NDI|HX", meaning "NDI High Efficiency", uses much lower bitrate and is appropriate when bandwidth is limited.

### Transport Protocols

- Reliable UDP: Supports very high-latency networks. Has built-in  congestion control and loss recovery and no head-of-line blocking.
- Multipath TCP: Uses multiple NICS and multiple network paths.
- Single TCP: Nothing special.
- UDP with FEC: For when reliable delivery is not required. Has forward error correction (FEC).

### Recommendations

- The network must be high-bandwidth, low-latency, jitter-free and highly available.
- The network should be mostly dedicated to NDI streams.
- The network topology should be designed with requirements in mind.
- Gigabit, consumer off-the-shelf (COTS) equipment is generally good enough.
- While NDI supports using multiple NICs and may automatically distribute streams to different NICs, NIC teaming/aggregation is often preferred if possible.
- The network should be optimized for multicast traffic with IGMP if multicast sending is enabled.
- Maximum throughputs for streams:
    - NDI 1920x1080 60P: 132Mb/s
    - NDI 1920x1080 60P (with alpha): 165Mb/s
    - NDI 3840*2160 60P: 249Mb/s
    - NDI 3840*2160 60P (with alpha): 312Mb/s
    - NDI|HX 1920x1080 60P: 15.9Mb/s
    - NDI|HX 1920x1080 60P (with alpha): 10.9Mb/s
    - NDI|HX 3840*2160 60P: 30.0Mb/s
    - NDI|HX 3840*2160 60P (with alpha): 21.0Mb/s

{% include footer.md %}
