---
title: Linux Router
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}
Debian 10 Buster

## Setup

- Setup the Linux node as described in [Debian Server: Basic Setup](/config/linux-server/debian-server/#basic-setup).
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

## Security

See [Network Security: Routers](config/network/security#routers).

## Tuning

- Disabling dynamic frequency and voltage scaling (Intel SpeedStep).
- Disabling multithreading (Intel Hyper-Threading).

{% include footer.md %}
