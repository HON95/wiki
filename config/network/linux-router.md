---
title: Linux Router
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Network
---
{% include header.md %}

### Using
Debian 10

## Notes

1. For high-performance routing:
   1. Disabling dynamic frequency and voltage scaling \(Intel SpeedStep\).
   2. Disabling multithreading \(Intel Hyper-Threading\).
2. Enable IPv4 and IPv6 forwarding in `/etc/sysctl.conf`:
   1. `net.ipv4.ip_forward=1`
   2. `net.ipv6.conf.all.forwarding=1`
3. Configure the firewall for forwarding traffic.
   1. Configure NAT.
   2. Setup bogon and RFC 1918 filtering.
   3. Verify source for stub networks.
4. Setup DHCP servers for IPv4 and IPv6 \(unless using IPv6 SLAAC\).
5. Setup a DNS server.
6. Setup other servers, like NTP.

{% include footer.md %}
