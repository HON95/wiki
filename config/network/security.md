---
title: Network Security
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

## Hosts

- Smurf and Fraggle attacks:
    - DDoS where the adversary uses sends an ICMP/UDP echo packet (or similar) to a broadcast/multicast address using a spoofed source address, causing all reply traffic to be sent toward the user of the spoofed address.
    - Linux hosts:
        - Ignore broadcast/multicast ICMP echo and timestamp: `net.ipv4.icmp_echo_ignore_broadcasts=1` (Ignored (1) by default)
        - Ignore UDP echo etc.: Firewall it.
- ICMP redirects (IPv4):
    - Should be blocked or ignored for IPv4 since they can act as attack vectors and are basically never used in network designs.
    - Allows attackers to change the default gateway or inject bogus routes.
    - For IPv6, it is a more central functionality and should not be disabled.
    - Can be blocked by the firewall or ignored through configuration.
    - Linux:
        - Linux has a secure variant (`secure_redirects`) that specifies that the host will only accept redirects from hosts in its gateway list.
        - Disable reception of "insecure" ICMP redirects: `net.ipv4.conf.<all+default>.accept_redirects=0` (enabled (1) for hosts and disabled (0) for routers by default)
        - Disable reception of secure ICMP redirects`net.ipv4.conf.<all+default>.secure_redirects=0` (enabled (1) by default)
        - Disable sending ICMP redirects: `net.ipv4.conf.<all+default>.send_redirects=0` (enabled (1) by default)
- SYN cookies:
    - Should be enabled on servers.
    - Prevents TCP DDoS attacks.
    - When the connection queue is filled up, SYN cookies are used for new connections. Connections using SYN cookies must have all TCP options rejected, thus violating TCP.
    - Linux:
        - Enable: `net.ipv4.tcp_syncookies=1` (enabled (1) by default)

## Switches

**TODO** (see switch pages, personal notes and papers on my desk)

## Routers

- ICMP redirects:
    - See the [Hosts](#hosts) section.
- Source routing:
    - Should generally be disabled unless required. May be used in certain mobility scenarios.
    - Allows attackers to send packets to unintended paths/destinations.
    - For IPv4, there is the Strict Source Route (SSR) option and the Loose Source Routing (LSR) option. Both are considered insecure.
    - For IPv6, there is the type 0 routing header, type 2 routing header and type 4 Segment Routing Header.
    - Linux:
        - Enabled by default on routers.
        - Disable IPv4 SSR and LSR: `net.ipv4.conf.<all+default>.accept_source_route=0` (disabled (0) for hosts and enabled (1) for routers by default)
        - Disable IPv6 type 0 routing headers only: `net.ipv6.conf.all.accept_source_route=0` (type 2 only allowed (0) by default)
            - (Optional) Disable both IPv6 type 0 and 2 routing headers: `net.ipv6.conf.all.accept_source_route=-1`
    - Cisco IOS:
        - Disable source routing: `no source-route` (enabled by default)
- Source verification:
    - Should be handled somehow if possible.
    - May prevent spoofed IP addresses, especially
    - Can be done with firewall rules, reverse path forwarding (RPF), DHCP snooping-based verification, etc. based on scenario.
- Reverse path filtering (RPF):
    - Should be enabled for downlinks, but probably not for uplinks and transit links. For the latter two, use ACLs/firewall rules instead. Be especially careful for links with a default route pointing to it.
    - Use strict mode most of the cases, but loose mode if assymmetrical routing may happen.
    - Filters packets from sources that are not reachable by the FIB (loose mode); or filter packets from sources that are not received on the interface that would be used to reach the source (strict mode).
    - Linux:
        - Enable for IPv4 globally or per interface: `net.ipv4.conf.all.rp_filter=<0|1|2>`
        - Status for IPv6: Unknown.
        - Disabled (0), strict (1) or loose (2).
    - Cisco IOS:
        - Enable per interface: `<ip|ipv6> verify unicast source reachable-via <any|rx>`
        - Loose ("any") or strict ("rx").
    - VyOS (global):
        - Enable globally: `firewall source-validation strict`
        - TODO: Status for IPv6.
- Directed broadcast forwarding:
    - Should be disabled.
    - Exploited by e.g. smurf and fraggle attacks.
    - Linux routers:
        - Always disabled.
    - Cisco IOS:
        - Disable `no ip directed-broadcast` (disabled by default)
- Bogin filtering:
    - Should be enabled if appropriate.
    - Blocks packets from fake/invalid addresses such as from unused or unallocated prefixes.
    - May include RFC 1918 addresses.
    - Can be done by explicitly blacklisting all stable bogon prefixes.

## L4 Firewalls

- NAT traversal protocols:
    - E.g. Universal Plug and Play (UPnP), NAT Port Mapping Protocol (NAT-PMP), Port Control Protocol (PCP), Session Traversal Utilities for NAT (STUN).
    - Should generally be turned off unless explicitly needed. It's typically used by multiplayer games and other peer-to-peer applications.
    - Can function as attack vectors as an adversarial program may be able to exploit it to allow external connections to internal devices.

## L7 Firewalls

*Empty.*

## Intrusion Detection Systems (IDSes)

*Empty.*

{% include footer.md %}
