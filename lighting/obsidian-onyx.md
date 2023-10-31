---
title: Obsidian Onyx
breadcrumbs:
- title: Lighting
---
{% include header.md %}

Obsidian Onyx is a "cheaper" lighting controller, using a unified application for both dedicated consoles and PC.

## Networking

### Onyx Remote

- The official iOS app.
- For Android, try *Unofficial Onyx Remote* instead.
- OSC apps may be used instead, e.g. *touchOSC*.

### X-Net

- X-Net is Onix's protocol for linking multiple Onyx consoles together over the network, with one acting as primary.
- The show runs on the primary, but most state (and chat) is synchronized to all secondaries.
- All consoles need all required licenses for the show. Licenses are not shared/acculumated.
- Only the primary will output DMX, but using Art-Net/sACN instead will allow quick failover if connected to the same network (must be disabled on the secondaries).

### EtherDMX

- For outputting DMX to Art-Net or sACN.

### Telnet and UDP

- Telnet and UDP may be used to send commands to Onyx.

## Hardware

### NX-K (Keypad)

- The four encoders may either be assigned to the main encoders ("parameter") or the screen encoders ("screen") in the preferences.

{% include footer.md %}
