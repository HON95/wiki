---
title: Cisco General
breadcrumbs:
- title: Networking
---
{% include header.md %}

*I keep most of my Cisco notes elsewhere, sorry.*

Stuff that mostly applies to all Cisco network equipment.

## Resources

- [Cisco Config Analysis Tool (CCAT)](https://github.com/cisco-config-analysis-tool/ccat)

## Technologies

### Multi-chassis EtherChannel (MEC)

- General Cisco term, like MC-LAG/MLAG in other vendors' terminology.
- Includes technologies like  Stackwise (Catalyst), Virtual Switching System (VSS) (aka Stackwise Virtual) (Catalyst) and Virtual Port-Channel (vPC) (Nexus).
- Allows connecting EtherChannels (LACP/PAgP) to a logical unit consisting of multiple physical units, such that the physical EtherChannel links go to multiple physical units.
- Provides redundancy in case one of the physical units of the logical unit dies.
- Requires that the physical units are configured partially or fully as a logical device, e.g. using StackWise, VSS or vPC.
- The simpler L2 alternative would be separate EtherChannels and STP to make sure only one is active at the time.

## Protocols

### Port Aggregation Protocol (PAgP)

- Cisco-proprietary protocol for link aggregation.
- Use LACP instead.

### Link Aggregation Control Protocol (LACP)

- An IEEE protocol (aka 802.3ad) for link aggregation.
- LACPDU packets are used to transmit control information. Often this can be configured as slow (30s) or fast (1s), where fast is recommended for faster fault detection.
- The hash policy is used to determine which physical link to send packets on, e.g. by hashing layer 2 (MAC) and layer 3 (IP) addresses.
- A unique system ID is used by each device to make sure all links are connected to the same device on the other end.

### UniDirectional Link Detection (UDLD)

- A Cisco-proprietary protocol for detecting unidirectional links.
- Disabled by default.
- This can happen when one fiber strand has been damaged but the other one works, which would make it hard to know that the link is down and it could cause STP loops.
- It's mostly used for fiber ports, but can also be used for copper ports.
- Use aggressive mode to err-disable the port when it stops receiving periodic UDLD messages.
- A partial alternative is to use single member LACP.
- Configuration:
    - Set message interval: `udld message time <seconds>`
    - Enable in normal og aggressive mode globally on all fiber ports: `udld <enable|aggressive>`
    - Enable per-interface: `udld port <enable|aggressive>`

### Cisco Discovery Protocol (CDP)

- A Cisco-proprietary protocol for interchanging device information to neighbor devices.
- Use LLDP instead.
- Disable globally: `no cdp run`

### Link Layer Discovery Protocol (LLDP)

- An IEEE protocol (defined in IEEE 802.1AB) for interchanging device information to neighbor devices.
- **TODO** LLDP and LLDP-MED

## Other Features

### ACL Based Forwarding (ABF)

- Supported by ASR9000 (certain line cards) (Cisco IOS XR).
- Basically policy-based ruting (PBR), implemented using ACLs.
- Supports ingress ACLs only.
- Nexthops:
    - Up to 3 alternative nexthops can be specified for a rule using the `nexthop<n> [vrf <vrf>] [{ipv4|ipv6} <nexthop-ip>]` clause.
    - If multiple nexthops are specified then the first one with an up interface with a connected subnet will be used.
    - If none of the nexthops are "up" then the normal default route is used instead.
    - If the `default` clause is specified then the nexthops will only be used in place of a default route and not if any specific routes in the routing table match.
- VRFs:
    - Egress VRFs can be specified as part of the nexthop clause.
    - If no IP address is specified for the nexthop then the routing table of the VRF is used.
    - If no VRF is specified for a nexthop clause then the default VRF is used.
- If traffic should be dropped if the first next hops are down, then create a `DROP_VRF` VRF with a null default route and use that as the last nexthop.
- **TODO** If all nexthops are down, does ut use the normal routing table or specifically the normal default route? Something about null route not working mentioned.
- An example usage for ABFs is to route RFC 1918 networks heading through a GW toward the Internet into a NAT VRF or separate NAT router.
- Examples:
    - Some rule: `10 permit ipv4 any 100.100.100.0/24 nexthop1 VRF RED ipv4 1.1.1.1 nexthop2 VRF BLUE ipv4 2.2.2.2 nexthop3 ipv4 3.3.3.3`
    - Show that the ABF id programmed correctly in HW: `show access-lists ipv4 abf-1 hardware ingress location 0/1/cpu0`

## Miscellanea

### Version and Image String Notations

- Version 12 notation (e.g. `12.4(24a)T1`):
    - Major release (`12`).
    - Minor release (`4`).
    - Maintenance number (`24`).
    - Rebuild number (alt. 1) (`a`).
    - Train identifier (`T`).
    - Rebuild number (alt. 2) (`1`).
- Version 15 notation (e.g. `15.0(1)M1`):
    - Major release (`15`).
    - Minor release (`0`).
    - Feature release (`1`).
    - Release type (`M`).
    - Rebuild number (`1`).
- If it has `K9` in the image name, it has cryptographic features included. Some images don't because of US export laws.

{% include footer.md %}
