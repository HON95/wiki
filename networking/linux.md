---
title: Linux Switching & Routing
breadcrumbs:
- title: Networking
---
{% include header.md %}

### Foreword
{:.no_toc}

Using Linux servers as switches and routers may often be an inexpensive option and
allows you to implement most network functionalities in one box.
They may be virtualized to possibly reduce power usage and noise and take up no physical space.
It is generally more unreliable than using enterprise routers and switches, though,
and may require a good amount of time troubleshooting performance and compatibility issues.
The issues may not become apparent until tested live with tens to houndreds of clients,
as a simple throughput test will not uncover bottlenecks related to large amounts of connections
(which can be hard to test realistically in lab environments).
Issues may also be related to stupid things like which ports you're using on the *same* NIC.

## Setup (Debian)

(In semi-random order.)

- Setup the Linux node as described in [Debian Server: Basic Setup](/linux-servers/debian-server/#basic-setup).
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

## Tuning

- Disabling dynamic frequency and voltage scaling (Intel SpeedStep).
- Disabling multithreading (Intel Hyper-Threading).
- Disable protocol hardware offloading as it typically causes more problems than it solves.
- Make sure network interrupts from a given NIC are distributed across all cores.
    - See `/proc/interrupts`.
- Enable or disable hardware offloading (temporary):
    - Enable/disable large receive offload (LRO) or generic receive offload (GRO): `ethtool -K <if> <lro|gro> on`
    - Enable/disable TX/RX checksum offload: `ethtool -K <if> tx on rx on`
    - Enable/disable scatter/gather aka vectored I/O: `ethtool -K <if> sg on`
    - (And some others.)
- Change NIC RX/TX buffer sizes:
    - Show supported and current sizes: `ethtool -g <if>`
    - Set new sizes: `ethtool -G <if> tx 4096 rx 4096`
- Change MTU:
    - Typical Ethernet MTUs: 1500 (normal), 9000 (jumbo frames).
    - Typical InfiniBand MTUs: 2044 (2048), 4092 (4096).
    - Set: `ip link set <if> mtu <mtu>`
- Increase TCP buffer sizes:
    - **TODO**
- **TODO**
    - [https://fasterdata.es.net/host-tuning/linux/](https://fasterdata.es.net/host-tuning/linux/)
    - [https://community.mellanox.com/s/article/performance-tuning-for-mellanox-adapters](https://community.mellanox.com/s/article/performance-tuning-for-mellanox-adapters)

## Notes

- DHCPv4 servers and clients use raw sockets, which bypasses Netfilter, because it uses special IP addresses.
  DHCPv6 does not, however, because it uses real IP addresses.

{% include footer.md %}
