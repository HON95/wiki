---
title: Audio Basics
breadcrumbs:
- title: Audio & Video
- title: Audio
---
{% include header.md %}

- Bands:
  - Lows (ca. 20Hz-100Hz)
  - Low midrange (ca. 100Hz-1kHz)
  - High midrange (ca. 1kHz-10kHz)
  - Highs (ca. 10kHz-20kHz)
- Signal levels:
  - +4dBu: Professional equipment.
  - -10dBV: Consumer equipment. Lower than +4dBu. Not to be confused with dB**v**.
  - Phono: Old, for turntables etc. Much lower voltage than line level. Typically needs a phono preamp/stage with RIAA equalization.
  - Not to be confused with SPL dB.
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
    - Break the shielding on one cable to break the loop. Different boxes, like DI units, may have this as a feature known as a ground lift. However, make sure all shields are connected at one end. Don't break the shielding/earthing on devices that needs it for safety reasons!
    - Use a ground loop isolation transformer.
    - Group the ground cables together so no currents get induced into the cables.
    - Use a resistor and/or a ferrite bead to limit AC current.
- Phantom power:
  - Applies 48V to XLR3 (or similar) mic inputs. Applying this to devices which aren't made for it can break them.
- Impedance:
  - Basically resistance but for AC.

{% include footer.md %}
