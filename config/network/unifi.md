---
title: UniFi Access Points
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Network
---
{% include header.md %}

Using: UniFi AP AC (different variants) with controller v5

## Access Points

### Miscellaneous

- Disable wireless uplinks \(meshing\) if not used:
  - \(Alternative 1\) Disable per site: Go to site settings and disable "uplink connectivity monitor".
  - \(Alternative 2\) Disable per AP: Go to AP settings, "wireless uplinks" and disable everything.
  - Upgrade the controller and AP firmware. Old versions can be buggy wrt. wireless uplinks and can cause L2 loops.

{% include footer.md %}
