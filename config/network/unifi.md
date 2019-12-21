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

- It doesn't always work as intended. Wired APs can enter wireless uplink mode and cause network loops (due to a former firmware bug) and wired APs often don't want to enter wireless uplink mode.
- The APs can be adopted wirelessly if one of them is connected to the network.
- Disable wireless uplinks (meshing) if not used:
  - (Alternative 1) Disable per site: Go to site settings and disable "uplink connectivity monitor".
  - (Alternative 2) Disable per AP: Go to AP settings, "wireless uplinks" and disable everything.
  - Upgrade the controller and AP firmware. Old versions can be buggy wrt. wireless uplinks and can cause L2 loops.

{% include footer.md %}
