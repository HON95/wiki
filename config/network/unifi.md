---
title: Ubiquiti UniFi Controller
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

### Using
{:.no_toc}

- Controller v5 on Debian 9 (Stretch)
- AP AC Lite
- AP AC LR

## Installation (Debian 9)

UniFi 5 is the latest version and does only officially support Debian 9 (Stretch) and Ubuntu Desktop/Server 16.04 for Linux. It requires Java 8 and other stuff which is an absolute pain to install on later versions of Debian. There is also the official physical Cloud Key device and multiple unofficial Docker images and installation packages for Linux servers.

Official installation instructions: [UniFi: How to Install & Upgrade the UniFi Network Controller Software](https://help.ubnt.com/hc/en-us/articles/360012282453-UniFi-How-to-Install-Upgrade-the-UniFi-Network-Controller-Software)

1. Install Debian 9 (yes, 9).
1. Configure it: See [Debian Server](../debian/) (for Debian 10).
1. Allow the following incoming ports (see [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)):
    - TCP 8080: Device-controller communication (for devices)
    - TCP 8443: GUI/API (for admins)
    - TCP 8880: HTTP portal (for guests)
    - TCP 8843: HTTPS portal (for guests)
    - TCP 6789: Mobile speedtest (for admins)
    - UDP 1900: L2 adoption (for devices, optional)
    - UDP 3478: STUN (for devices)
    - UDP 10001: Device discovery (for devices)
1. (Optional) NAT port 443 to 8443 in IPTables: `iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443`
1. Go to the UniFi downloads page and download for Linux/Debian.
1. Install: `apt install <?>.deb`
1. Configure:
    - File: `/var/lib/unifi/system.properties`
    - (Optional) Reduce the pre-allocated memory size: `unifi.xms=256`
1. (Optional) Check the logs:
    - UniFi: `/usr/lib/unifi/logs/server.log`
    - MongoDB: `/usr/lib/unifi/logs/mongod.log`
1. Set up UniFi in the web UI.

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
