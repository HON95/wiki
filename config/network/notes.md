---
title: Network Notes
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Network
---
{% include header.md %}

## Terms

| Cisco IOS | Brocade ICX |
| :--- | :--- |
| Access port (VLAN) | Untagged port |
| Trunk port (VLAN) | Tagged port |
| Native VLAN | Dual mode |

## Spanning Tree

### Variants

| Names | Supporting Devices\* | Description |
| :--- | :--- | :--- |
| 802.1D, STP | Cisco IOS, Linksys LGS | Single instance, slow |
| PVST/PVST+ | Cisco IOS | Like STP, one instance per VLAN |
| VSTP | Juniper | Compatible with Cisco's PVST |
| 802.1w, RSTP | Brocade ICX, Linksys LGS | Single instance, fast, backwards-compatible with STP. |
| Rapid-PVST+ | Cisco IOS | Like PVST+ but based on RSTP |
| VSTP | Juniper | Based on RSTP, compatible with STP and Cisco's PVST |
| 802.1s, MSTP, MST | Cisco IOS | Multiple instances with configurable VLAN members |
| 802.1Q |  | ??? |

(\*) Very incomplete list.

### Notes

- Use extended system ID for multi-VLAN switches.
- Make sure all switches are using compatible variants and default priorities.
- Make sure all VLANs are running STP or that STP is running globally (not per VLAN).
- STP (excluding per-VLAN STP and generally not MST) (including rapid versions) will consider multiple links between switches a loop, even when the links carry different VLANs.
- The bridge priority should generally be a multiple of 4096.
- PVST and 802.1Q regions cannot interoperate directly, but can through PVST+ regions.

#### Cisco IOS

- Disable VTP, it's dangerous if not used properly. It also doesn't carry MST configuration.
- Rapid-PVST+ ignores UplinkFast and BackboneFast and supports UDLD.

### Compatibility Between Switch Models

#### Alternative 1

- Cisco IOS (Cat 3750G): `rapid-pvst`
- Brocade (ICX 6610): `802.1w`
- Linksys (LGS326): `stp` (slow but works)
- Use the same default priority, e.g. 32768.

## Security

### Switches

### Routers

### L4 Firewalls

- Called stateful if it provides connection tracking for TCP/UDP traffic.
- NAT:
  - Universal Plug and Play (UPnP), NAT Port Mapping Protocol (NAT-PMP), Port Control Protocol (PCP), Session Traversal Utilities for NAT (STUN), etc. can function as attack vectors as an adversarial program may be able to exploit it to allow external connections to internal devices. It should generally be turned off except if explicitly needed. It's typically used by multiplayer games and other peer-to-peer applications.

### L7 Firewalls

- A.k.a. next-generation firewall (NGFW).
- Based on deep packet inspection (DPI).
- Can be extended to include:
  - IDS/IPS functionality.
  - User identity management for network traffic.
  - Web application firewall (WAF).

### Intrusion Detection Systems (IDS)

- Called intrusion *prevention* system (IPS or IDP) if it can block traffic after a detected threat.

## Informative Notes

### Routers and Firewalls

- Network address translation (NAT):
  - Mainly done in firewalls but also in some routers.
  - Many different types, including masquerading with port forwarding.
  - Hairpinning/reflection: Reroute internal requests from a NATed network to an edge router's external IP address back into the router. It allows using domain names with public IP addresses from within the NATed network.
  - Greatly reduced the rate of IPv4 address exhaustion at the cost of breaking the end-to-end principle, which introduced many new problems.
  - Generally avoided in IPv6. Network prefix translation (NPT), however, can be used to translate (highly) dynamic global prefixes to static site-local prefixes.

{% include footer.md %}
