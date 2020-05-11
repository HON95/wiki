---
title: Ubiquiti UniFi
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}

- Controller v5 on Debian 9 (Stretch)
- AP AC Lite
- AP AC LR

## Controller

For setting up the controller on a Debian server, see [Ubiquiti UniFi Controller (Debian)](../../linux-server/unifi/).

## Access Points

- PoE info: [UniFi: Supported PoE Protocols](https://help.ubnt.com/hc/en-us/articles/115000263008--UniFi-Understanding-PoE-and-How-UniFi-Devices-are-Powered)
- Adoption methods: [UniFi: Device Adoption Methods for Remote UniFi Controllers](https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Device-Adoption-Methods-for-Remote-UniFi-Controllers)
    - The DHCP option is typically the most appropriate IMO.
- Reset: Hold RESET button until the front light alternate between black, white and blue.
- Default credentials (after RESET and before adoption): Username `ubnt` with password `ubnt`.
- IPv6 management: It does not seem to support DHCPv6. I don't know about SLAAC.
- Problematic settings:
    - "Guest Policy": For client isolation and captive portal. Does not support IPv6. May cause communication to fail after connecting to the AP.
    - "High Performance Devices": May cause the connection establishment to to fail.

### Wireless Uplink (Meshing)

- Old firmware versions can be buggy wrt. wireless uplinks and can cause L2 loops.
- The APs can be adopted wirelessly if one of them is connected to the network.
- APs that are adopted wirelessly are will automatically allow meshing to other APs while APs that are adopted while wired will not. This can be changed in the AP settings.
- Disable wireless uplinks (meshing) if not used:
  - (Alternative 1) Disable per site: Go to site settings and disable "uplink connectivity monitor".
  - (Alternative 2) Disable per AP: Go to AP settings, "wireless uplinks" and disable everything.

{% include footer.md %}
