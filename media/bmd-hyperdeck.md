---
title: "Blackmagic Design: HyperDeck"
breadcrumbs:
- title: Media
---
{% include header.md %}

## HyperDeck Studio Mini

### Fan Mod

The original fan is noisy, but can be replaced with e.g. a (*Noctua NF-A4x20 PWM*)[https://www.noctua.at/en/products/nf-a4x20-pwm] fan (used as example here).

Some YouTube video showing the same procedure: [Quik Tech Solutions L.L.C: HyperDeck Studio Mini Fan Replacement](https://www.youtube.com/watch?v=AnLuwS6ei2A)

Steps:

1. Remove the top lid by unscrewing all the screws on the sides.
1. Unplug and unscrew the old fan.
1. Cut the old fan cable at around the middle and throw away the old fan (keep the old connector).
1. Get the new Noctua fan and cut the fan cable at around the middle (throw away the new connector).
1. Get the [*Noctua OmniJoin*](https://www.noctua.at/en/expertise/tech/omnijoin-adaptor-set) cable kit that came with the fan (the four connectors).
    - Alternatively get the four connectors from elsewhere or just solder the cables.
    - You will need pliers to be able to squeeze closed the connectors.
1. Attach or solder the new fan to the old connector in the following way:
    - Connector <span style="background-color: darkgray; color: white;">black</span>
      &mdash; fan <span style="background-color: darkgray; color: white;">black</span>
    - Connector <span style="background-color: red; color: white;">red</span>
      &mdash; fan <span style="background-color: yellow; color: black;">yellow</span>
    - Connector <span style="background-color: yellow; color: black;">yellow</span>
      &mdash; fan <span style="background-color: green; color: white;">green</span>
    - Connector <span style="background-color: blue; color: white;">blue</span>
      &mdash; fan <span style="background-color: blue; color: white;">blue</span>
1. Mount the fan and connect the fan connector to the board. Make sure the fan is mounted the correct way (pushing air out of the unit) and that the fan cable is not in the way of the fan or other electronics (consider using a cable tie).
1. Screw the top lid back on.
1. Power on the device and make sure the fan is working.

{% include footer.md %}
