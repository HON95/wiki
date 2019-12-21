---
title: UniFi Access Points
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}
AP, AP AC Lite, AP AC LR

Controller v5

## Access Points

### Wireless Uplink (Meshing)

- Old firmware versions can be buggy wrt. wireless uplinks and can cause L2 loops.
- The APs can be adopted wirelessly if one of them is connected to the network.
- APs that are adopted wirelessly are will automatically allow meshing to other APs while APs that are adopted while wired will not. This can be changed in the AP settings.
- Disable wireless uplinks (meshing) if not used:
  - (Alternative 1) Disable per site: Go to site settings and disable "uplink connectivity monitor".
  - (Alternative 2) Disable per AP: Go to AP settings, "wireless uplinks" and disable everything.

{% include footer.md %}
