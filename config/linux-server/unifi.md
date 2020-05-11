---
title: Ubiquiti UniFi Controller (Debian)
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

{% include footer.md %}
