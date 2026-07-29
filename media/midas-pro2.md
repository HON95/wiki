---
title: Midas PRO2
breadcrumbs:
- title: Media
---
{% include header.md %}

## General

- 96kHz 40-bit floating-point phase-coherent beginning to end.
- Runs in either FOH mode, MON mode or advanced mode.
- The DL251 stage box is included, with 48 inputs and 16 outputs.
- In addition to normal stereo mode, it supports several surround sound modes.

## Channels, Buses and Groups

- Input channels (64x):
    - Mic/line inputs (56x): Inputs with Midas mic preamps, either physically on the console or on a stage box.
    - FX returns (8x): Internal effects returns.
- Mix buses (27x):
    - Aux buses (16x):
        - Mainly for grouping of inputs and then sending them to either an output or another bus, e.g. for monitors and auxillary sends.
        - Can only source input channels.
        - Taps inputs pre-fader, post-fader or in subgroup mode (100% send from all chosen inputs).
        - Can be routed into matrix or master buses depending on the bus mode.
    - Matrix buses (8x):
        - Mainly for modifying existing buses and outputting them to different destinations, e.g. for PA zones (EQ and timing changes) and auxillary sends.
        - Can source input channels, aux buses and master buses. Sourcing input channels directly allows adding extra inputs to existing mixes, e.g. an audience or talkback mic.
        - Taps inputs post-fader.
        - Can not be routed into any other bus, only used for outputs.
    - Master buses (3x):
        - Dedicated left, right and mono (center) outputs.
        - Can be routed into matrix buses.
- Variable Control Association (VCA) groups (8x):
    - **TODO**
- Mix Control Association (MCA) groups (192x):
    - **TODO**
    - Only available in advanced mode.
- Population (pop) groups (6x):
    - Used for grouping inputs in arbitrary groups (similar to VCAs, but without control features).
- All buses (except mono) can be linked as a stereo pair.

## Dynamics

- **TODO** Compressors, EQ.

{% include footer.md %}
