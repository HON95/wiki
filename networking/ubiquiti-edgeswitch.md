---
title: Ubiquiti EdgeSwitch
breadcrumbs:
- title: Server
---
{% include header.md %}

## General

- Default credentials: Username `ubnt`, password `ubnt`.
- Serial settings: Baud 115200, 8 data bits, 0 parity bits, 1 stop bit, no flow control.

## Initial Setup

Tested with an EdgeSwitch 16 XG.

1. Basics (use where appropriate):
    1. Log in: Username `ubnt`, password `ubnt`.
    1. Enter enable mode: `en`
    1. Enter config mode: `conf`
    1. Exit any mode: `exit`
    1. Save config: `write mem`
1. Setup enable-mode stuff:
    1. Set hostname: `hostname <hostname>`
    1. **TODO** Network stuff?
    1. Setup VLANs:
        1. Enter VLAN mode: `vlan database`
        1. **TODO**
1. Setup basics:
    1. Set pre-login banner: `set clibanner "Hello"`
1. Setup AAA:
    1. **TODO**
1. **TODO**:
    1. IGMP/MLD snooping.

## Tasks

### Reset

1. Wait until fully booted.
1. Press and hold the reset button for 30 seconds (exact duration is unclear). Holding it for a too short duration will simply reboot the device instead.

### Upgrade Software

**TODO**

{% include footer.md %}
