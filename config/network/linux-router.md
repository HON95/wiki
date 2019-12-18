---
title: Linux Router
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}
Debian 10 Buster

## Setup

See [Debian Server: Basic Setup](/config/linux-server/debian-server/#basic-setup).

- Some of these steps are completely optional and some may be moved to other boxes.
- Setup the firewall for filtering both forwarded traffic and input/output to the router.
- Setup the firewall for NAT.
- Enable IP forwarding in `/etc/sysctl.conf`, then run `sysctl -p`:
  - `net.ipv4.ip_forward=1`
  - `net.ipv6.conf.all.forwarding=1`
  - Run `sysctl -p` to reload.
- Setup the network interfaces for all the directly connected networks.
- Setup a default gateway, static routes and/or routing protocols.
- Setup radvd for IPv6 NDP.
- (Optional) Setup a DHCPv6 server like the ISC DHCP Server.
- Setup a DHCP server like the ISC DHCP Server.
- (Optional) Setup a DNS server, like Unbound.
- **TODO** Multicast routing.

## Notes

1. For high-performance routing:
   1. Disabling dynamic frequency and voltage scaling (Intel SpeedStep).
   2. Disabling multithreading (Intel Hyper-Threading).
2. Enable IPv4 and IPv6 forwarding in `/etc/sysctl.conf`:
   1. `net.ipv4.ip_forward=1`
   2. `net.ipv6.conf.all.forwarding=1`
3. Configure the firewall for forwarding traffic.
   1. Configure NAT.
   2. Setup bogon and RFC 1918 filtering.
   3. Verify source for stub networks.
4. Setup DHCP servers for IPv4 and IPv6 (unless using IPv6 SLAAC).
5. Setup a DNS server.
6. Setup other servers, like NTP.

{% include footer.md %}
