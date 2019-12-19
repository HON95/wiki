---
title: Network Security
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration
- title: Network
---
{% include header.md %}

## Hosts

- Directed broadcasts of ICMP echo:
  - Should generally be disabled.
  - Exploited by smurf and fraggle attacks.
  - Linux:
    - ICMP echo reception disabled by default.
    - `icmp_echo_ignore_broadcasts=1`
- ICMP redirects:
  - Should be blocked or ignored.
  - Allows attackers to change the default gateway or inject bogus routes.
  - The secure variant (Linux) specifies that the host will only accept redirects from hosts in its gateway list.
  - Can be blocked by the firewall or ignored through configuration.
  - Ignore with Linux:
    - Redirects are accepted by default on hosts and ignored by default on routers. IPv4 secure redirects are enabled by default.
    - IPv4: `net.ipv4.conf.all.accept_redirects=0`
    - IPv6: `net.ipv6.conf.all.accept_redirects=0`
    - IPv4 secure: `net.ipv4.conf.all.secure_redirects=0`
- Syn cookies:
  - Should be enabled on servers.
  - Prevents connection-based DDoS attacks.
  - When the connection queue is filled up, syn cookies are used for new connections. Connections using syn cookies must have all TCP options rejected, thus violating TCP.
  - Linux:
    - Enabled by default.
    - `net.ipv4.tcp_syncookies=1`

## Switches

**TODO** (see switch pages)

## Routers

- Bogin filtering:
  - Should be enabled if appropriate.
  - Blocks packets from fake/invalid addresses such as from unused or unallocated prefixes.
  - May include RFC 1918 addresses.
  - Can be done by explicitly blacklisting all stable bogon prefixes.
- Source verification:
  - Should be enabled if appropriate.
  - Prevents attackers on stub networks from spoofing source addresses outside the network.
  - Can be done with the firewall.
- Reverse path filtering:
  - Should be enabled.
  - Filters packets from sources that are not reachable by the FIB (loose mode); or filter packets from sources that are not received on the interface that would be used to reach the source (strict mode).
  - Use strict mode for most cases and loose mode if using asymmetric routing.
  - Linux:
    - Disabled by default but enabled by some distros.
    - Use 1 for strict mode and 2 for loose mode.
    - `net.ipv4.conf.all.rp_filter=<1|2>`
- Directed broadcasts (forwarding):
  - Should generally be disabled.
  - Exploited by smurf and fraggle attacks.
  - Linux:
    - **TODO**
  - Cisco IOS:
    - Disabled by default.
    - `no ip directed-broadcast`
- Source routing:
  - Should generally be disabled.
  - Allows attackers to send packets to unintended paths/destinations.
  - Uses the Strict Source Route (SSR) or Loose Source Routing (LSR) IPv4 header options.
  - IPv6 source routing has been deprecated and replaced by segment routing.
  - Linux:
    - Enabled by default on routers.
    - IPv4: `net.ipv4.conf.all.accept_source_route=0`
    - (Optional) IPv6 (segment routing): `net.ipv6.conf.all.accept_source_route=-1`
  - Cisco IOS:
    - `no source-route`
- ICMP redirects:
  - See [Hosts](#hosts).

## L4 Firewalls

- NAT:
  - Universal Plug and Play (UPnP), NAT Port Mapping Protocol (NAT-PMP), Port Control Protocol (PCP), Session Traversal Utilities for NAT (STUN), etc. can function as attack vectors as an adversarial program may be able to exploit it to allow external connections to internal devices. It should generally be turned off except if explicitly needed. It's typically used by multiplayer games and other peer-to-peer applications.

## L7 Firewalls

## Intrusion Detection Systems (IDSes)

## Extra Notes

### Firewalls and Intrusion Detection Systems (IDSes)

- Stateful firewall: Provides connection tracking for TCP/UDP traffic.
- Network address translation (NAT):
  - Mainly done in firewalls but also in some routers.
  - Many different types, including masquerading with port forwarding.
  - Hairpinning/reflection: Reroute internal requests from a NATed network to an edge router's external IP address back into the router. It allows using domain names with public IP addresses from within the NATed network.
  - Greatly reduced the rate of IPv4 address exhaustion at the cost of breaking the end-to-end principle, which introduced many new problems.
  - Generally avoided in IPv6. Network prefix translation (NPT), however, can be used to translate (highly) dynamic global prefixes to static site-local prefixes.
- Layer 7 firewalls: Provides deep packet inspection (DPI). A.k.a. next-generation firewalls (NGFW). Provides a foundation for IDS/IPS, user identity management and web application firewalls (WAF).
- Intrusion prevention systemes (IPSes or IDPs): Can block traffic once a threat has been identified, unlike a plain IDS.
