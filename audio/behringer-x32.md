---
title: Behringer X32
breadcrumbs:
- title: Audio
---
{% include header.md %}

## Routing

- "Channel" types:
    - Channels (mono): Inputs, fed from physical inputs, stageboxes (AES50), sound cards etc.
    - Mix bus (mono): General mix buses, fed by inputs or effects.
    - Effect groups (stereo): Fed by **TODO**
    - Main LR (stereo): Main stereo bus, fed by **TODO**
    - Main M/C (mono): Main mono/center bus, fed by **TODO**
    - Matrices (mono): Fed by buses (incl. main LR+M), can't be fed from channels.
    - DCA groups: Doesn't carry audio but instead remote controls the level of a set of inputs.
- Tap points:
    - Tap points are used for both mixbuses (typically pre-fader) and outputs (typically post-fader).
    - Tap points are wrt. each input channel-output bus-pair, but each two mixbuses must share the tap point (even when not linked).
    - The "+M" tap variant mutes the tap too when the channel/bus is muted.
    - In/LC (1): After preamp gain and low cut.
    - Pre-EQ (2): Before EQ.
    - Post-EQ (3): After EQ, before compressor if using post-EQ compressor.
    - Pre-fader (4): Before fader.
    - Post-fader (5): After fader.
    - Sub group (6): After fader, with no level control for channel send.
- The sampling rate (44.1k or 48k) must be set equally for everything connected, including AES50, USB and USB recordings.
- Use the "L/R + Mono" panning mode, where you manually assign sources to LR and/or mono outputs and pan only applies to LR. If you have a center speaker/cluster, this allows you to assign vocals/talks to only the center to avoid combing filter effects and such which might be especially noticable for certain audio types. The "LCR" mode sets left, center, right side-by-side panning-wise, so that the source is only sent to the center when the pan knob is centered. LCR mode may appropriate for more "immersive" sound images.
- Use "M/C depends on Main L/R" if you want the mono level to follow (depend on) the LR level.
- For setting input channel sources individually (not blocks of 8), map the individual sources to user inputs and then select user input blocks for the channels.
- "Sends on fader" works in both directions, you can select either an input channel or an output bus. The "bus sends" buttons/knobs are redundant (the compact console doesn't even have them).
- Use the "mono bus" and "stereo bus" buttons and associate knobs to route channels to the main LR (stereo) and/or main M (mono/mid/center).
- For the PA speakers, consider putting the full-range speakers and the subwoofers on separate matrices fed from the main bus. This has a few advantages:
    - You can keep the main clean and put house EQ on the matrices instead.
    - You to keep the main bus at zero and instead set the house volume at the matrices.
    - You can use the matrices as the system processor, to handle speaker crossover EQ and stuff. In this case, you probably want a stereo pair for the full-range speakers and a mono or stereo pair for subs.
- Use output delays if speakers are different distances away from the audience (if you're willing to do the math).
- When setting up busses for e.g. monitors, it's a good idea to solo the bus and listen to it using your monitor headphones.
- DCA groups:
    - DCA groups are useful for controlling the volume for or muting a group of inputs (e.g. all vocals or all drum mics).
    - To add channels to the DCA group, hold the DCA group's select button and press select on the channels to add or romove.

### AES50

- Supports 48 inputs and 48 outputs for each interconnect (A and B).
- Typically used for stage boxes (e.g. an SD8, S32 or X32 Rack).
- Use shielded EtherCON to avoid blowing out the AES50 ports in case of static discharge.
- All interconnected devices must use the same clock to avoid audio glitches. To set the X32 to use the clock from a AES50 source (e.g. another X32), configure it in the settings.
- Configuring an X32 as a pure stagebox:
    - **TODO** details, I can't remember exactly. Patch AES50 directly to XLR out, patch inputs as directly as possible to AES50. Preamp settings must still be configured on the X32 stagebox.

## Gating

- Enable gating on microphones to avoid picking up nois and contributing to feedback.
- Use a gain reduction (low "range") of e.g. -9dB to not silence it completely, which can sound weird.

## Equalization

- Use a graphical EQ to tune the main speakers to the venue. Measurement microphones and frequency sweeps may help give some indication on what to tweak, but relying solely on that may generally yield a pretty bad-sonding EQ. Test with the intended sound/music instead for fine tuning.
- For inputs like microphones and instruments, add a low shelf (low cut) at an appropriate frequency to avoid noise from frequencies the source is not supposed to generate. For vocals, add a low cut/shelf somewhere in the 60-80Hz range.
- For full-range speaker outputs, you may optionally add a low shelf and a high shelf if you know which frequencies the speakers are not able to play. This may help protect some old/bad speakers, but is typically not needed.
- If feeding different busses/matrices to the full-range speakers and the subwoofers, consider adding some shelves for better controlling the crossover frequency range. Or don't if you want to at some point turn the subwoofers completely off (for some reason).
- For crossover, you can use the LR24 mode which correctly crosses over if you use the same frequency at each side.
- Some modes like LR24 eats up two EQ bands/slots.

### Ringing out Feedback

- See the notes in [Audio Basics](/audio/audio-basics/), mostly only X32-specific stuff is noted here.
- Use gating and low cut on vocals to avoid contribution from silent/inactive microphones.
- Use a parametrics EQ for the input channel that's causing feedback.
- Use the built-in RTA inside the input channel EQ to see what's happening while tuning the EQ.
- While talking/playing into the mic, very slowly turn up the channel level until you notice feedback. Be prepared to quickly turn down the level. Watch the RTA and cut the feedback frequency a bit. Repeat.
- Avoid EQ-ing too much, it will obviously affect how the mic sounds. At most 3 frequencies, as narrow and shallow as possible.

## Effects

- The X32 has 8 stereo effect banks, where all may be used as inserts but only the first 4 may be used as FX returns that can be fed back into mix busses.
- The first 4 are by default sourced as mono from busses 13–16, with stereo returns (8 stereo-linked busses).
- FX 1 is reverb by default.
- Mute groups can come in handy to mute effects between songs etc.

## Talkback

- The X32 supports two talkbacks (A and B).
- Use the build-in microphone below the display or plug in an external one into the dedicated XLR input.

## User Interface

- Assign controls:
    - The "assign" knobs (4) and buttons (8) allow you to assign functions or links to them, e.g. to modify FX stuff, mute channels or go to a certain view.
    - Three sets can be configured (A, B and C).
    - The X32 Compact doesn't have the strip displays, four knobs or the three buttons to select sets. Switching sets can be done via the view display instead.

## Remote Control

- For Windows/MacOS/Linux, use X32Edit (Arch Linux: `yay/x32edit`).
- Use the "Mixing Station" app on Android and iOS for remote control. It's better than the official app.
- Behringer X-Touch can be used as a remote control surface, connected over the local network. X-Touch remote must be enabled in the X32 settings.

## Recording and Playback

### X-USB Module

- Supports 32 24-bit channels of input and output.
- Allows for virtual sound checks using the module as the channel sources if the physical/original sound checks were recorded.

### X-Live SD-Card Module

- Supports 32-channel recording.
- Has a USB port for connecting to a PC, like the default USB modile.

### USB Drive

- Record and play stereo audio using a USB drive.
- The drive should be USB 2, "fast" (class 10) and must be formatted as FAT32. Some large USB 3 drives work too. Kingston and Sandisk are rumored to be OK.
- Don't remove the USB drive while the access light is lit.
- If you have a lot of headroom in the input mix, increase the recording trim until it reaches an appropriate level.

## Tips and Tricks

- On the Compact version, select two input layers at the same time to show the first on the left channel strips and the second on the right channel strips.
- Enable color for the RTA.
- Bring a 5GHz wireless router to set up your own out-of-band network for remote control. Consider hooking the WAN port up to the local network for internet access, if required. Also consider connecting the tablet using an RJ45 Ethernet adapter to avoid relying on WLAN.

{% include footer.md %}
