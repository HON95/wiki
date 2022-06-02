---
title: Audio Basics
breadcrumbs:
- title: Media
---
{% include header.md %}

- Bands:
    - Lows (ca. 20Hz-100Hz)
    - Low midrange (ca. 100Hz-1kHz)
    - High midrange (ca. 1kHz-10kHz)
    - Highs (ca. 10kHz-20kHz)
- Signal levels:
    - (Note) This is the voltage (and somewhat impedance) inside cables/equipment.
    - Mic level: Output from a microphone. Very weak, requires a preamp.
    - Instrument level: Output from e.g. a guitar. Like mic level but slightly stronger.
    - Line level (+4dBu): Professional equipment.
    - Line level (-10dBV): Consumer equipment. Lower than +4dBu. Not to be confused with dB**v**.
    - Speaker level: High-power signal going from an amplifier to a (passive) speaker.
    - Phono: Old, for turntables etc. Much lower voltage than line level. Typically needs a phono preamp/stage with RIAA equalization.
- Balance mode:
    - Unbalanced: Ground and signal.
    - Balanced: Ground and hot and cold signal with equal impedance. The cold signal is 0V but not (directly) connected to ground.
    - Differential: Balanced but the cold signal is the opposite voltage of the hot signal instead of 0V.
    - Balanced and unbalanced mono plugs/sockets can generally be connected together (with the loss of the balanced signal), but don't connect e.g. a stereo unbalanced TRS to a mono balanced TRS. It'll sound weird due to the signal mismatch.
- Ground loops:
    - When there exists physical loop in the ground wires. Typically when devices are connected to different grounded power outlets.
    - Different potentials in the loop will cause undesired current flow.
    - Can be heard as a 50Hz/60Hz hum in the audio signal.
    - Solutions:
        - Use balanced signals.
        - Connect all equipment to a single grounding point, i.e. a single power outlet.
        - Break the shielding on one cable to break the loop. Different boxes, like DI units, may have this as a feature known as a ground lift. However, make sure all shields are connected at one end (don't lift everything). Don't break the shielding/earthing on devices that needs it for safety reasons!
        - Use a ground loop isolation transformer.
        - Group the ground cables together so no currents get induced into the cables.
        - Use a resistor and/or a ferrite bead to limit AC current.
- Phantom power: Applies 48V to XLR3 (or similar) inputs, for powering mics and similar. Applying this to devices which aren't made for it can break them.
- Impedance: Basically resistance but for AC.
- Proximity effect: Increase of low frequency response when an audio source is close to a directional or cardioid microphone.
- Equal-loudness contours:
    - The perceived loudness for a given SPL depends on the frequency.
    - This is typically visualized as equal-loudness contours, with frequency on the first axis, SPL on the second axis and a set of equal-loudness curves.
    - Fletcher–Munson curves is an early version of equal-loudness contours, but is still sometimes used to refer to the same thing.
    - This is why low-volume music sounds so bass-less and why e.g. car stereos typically provide a "loudness" setting to try to correct it for low volume levels (and make it sound terrible for normal volume levels).
- Feedback:
    - Happens when sound is fed from speakers back into a microphone (accidentally), at a high enough "loop gain" that the feedback noise level quickly escalates to annoying/damaging levels.
    - Generally only happens at certain resonating frequencies, depending on the venue/room.
    - Preventing feedback:
        - Avoid placing microphones in front of speakers.
        - Use appropriate microphones, e.g. dynamic microphones pointing away from any (loud)speakers.
        - Use an equalizer to reduce the level for feedback-inducing frequencies. To find the frequencies, test the setup at loud levels to try to induce it, then measure which frequency it's happening at.
        - Don't use "feedback destroyers", they're crap.

{% include footer.md %}
