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

## Switches

**TODO** (see switch pages)

## Routers

- Directed broadcasts:
  - Should be disabled.
  - Used by smurf and fraggle attacks.

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
