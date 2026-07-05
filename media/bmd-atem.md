---
title: "Blackmagic Design: ATEM"
breadcrumbs:
- title: Media
---
{% include header.md %}

## ATEM 2 M/E Production Studio 4K

### Fan Mod

Some YouTube video showing the same procedure: [Ryan Harper: BlackMagic Design ATEM 2 M/E Fan Placement](https://www.youtube.com/watch?v=V72MRBk_fk0)

Fans and Noctua alternatives:

- 2x 60x25mm 12V 4-pin (chassis inlet): Noctua NF-A6x25
- 6x 40x10mm 12V 3-pin (chip radiator push): Noctua NF-A4x10 FLX

Steps:

1. Remove the top lid by unscrewing all the screws on the sides.
1. Unplug and unscrew the old fan.
1. Replacing the 6 40mm 3-pin fans:
    1. Cut the old fan cable at around the middle and throw away the old fan (keep the old connector).
    1. Get the new Noctua fan and cut the fan cable at around the middle (throw away the new connector).
    1. The colors on the old fan should be the same as for the Noctua fan, so just color match and solder them togethe (or use the [*Noctua OmniJoin*](https://www.noctua.at/en/expertise/tech/omnijoin-adaptor-set) cable kit that might have come with the fans).
    1. Mount the fan and reconnect the connector to the board.
1. Replacing the 2 60mm 4-pin fans:
    1. **TODO**: I haven't replaced there yet, so I'm not sure about the pinouts/colors. Also, the screws are hard to get to.
1. Screw the top lid back on.
1. Power on the device and make sure the fan is working.

{% include footer.md %}
