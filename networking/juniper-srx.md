---
title: Juniper SRX Series Firewalls
breadcrumbs:
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Juniper Hardware](/config/network/juniper-hardware/)
- [Juniper Junos OS](/config/network/juniper-junos/)

### Using
{:.no_toc}

- SRX320 w/ Junos 19.4R3

## Setup

### Initial Setup

See the Junos general notes.

## Theory

SRX-specific information, see the Junos page for general information.

### Packet Forwarding Mode (Packet-based and Flow-based)

- *Packet-based forwarding* handles packets one by one, also called stateless forwarding (similar to router ACLs). This does not handle connection tracking and other advanced features.
- *Flow-based forwarding* handles packets as streams, also called stateful forwarding. This is the default for IPv4 (IPv6 forwarding is disabled by default).
- Commands:
    - Configured using `set security forwarding-options family inet6 mode flow-based` (example).
    - Run `show security flow status` to show forwarding modes.

### L2 Forwarding Mode (Transparent and Switching)

- The default mode on most newer devices/versions is switching mode.
- Switching mode:
    - Basically L3 mode. Pretty similar to L3 switches, with VLANs and RVIs.
    - Uses IRB/routed interfaces in security zones, forwarding the flow through the flow architecture.
    - Does not enforce policy on intra-VLAN traffic. Intra-VLAN traffic is forwarded directly on the Ethernet chip.
    - Supports LACP.
    - The number of VLANS is limited by hardware. SRX300 supports 1000 VLANs.
- Transparent mode:
    - Basically L2 mode.
    - The firewall acts like an L2 switch connected inline in the infrastructure, allowing simple integration without modifying routing and protocols.
    - Does not support STP, IGMP snooping, Q-in-Q, NAT and VPNs.
    - Uses physical interfaces in security zones.
    - Also called L2 transparent mode (L2TM).
- Commands:
    - Configured using `set protocols l2-learning global-mode {transparent-bridge|switching}`.
    - Show using `show ethernet-switching global-information`.

### Security Zones

- On SRX firewalls, you must assign interfaces to a security zone.
- *Security zones* are the main type of zone, whereas *function zones* are for special purposes. Only the management zone ("MGT") is currently supported and does not allow exchanging traffic with other zones.
- The default policy is to deny traffic both intra-zone and inter-zone. Interfaces not assigned to a zone are part of the *null zone*, where no traffic may pass.
- To allow traffic between zones, you must define a security policy between the zones.
- To allow traffic to the firewall itself (e.g. ICMP, DHCP, SSH), you must configure it under `host-inbound-traffic` for the zone. NDP is enabled by default.
- Commands:
    - Show security zones: `show security zones`

### Security Policies

- Policies are handled using first-match.
    - Reorder existing policies (example): `insert security policies from-zone trust to-zone untrust policy permit-mail before policy permit-all`

### Security Screens

- Used to screen traffic and drop suspicious stuff.

### Address Books

- Address book may be defined globally or within a zone, containing entries as groups of network prefixes.
- The global book (`global`) is used for all security zones, for NAT configs and for global policies.
- Default entries: `any`, `any-ipv4`, `any-ipv6`
- Address sets may contain both IPv4 and IPv6 addresses from the same zone. Sets may also contain other sets.
- Limitations:
    - Address sets may contain at maximum 16384 entries and 256 sets.
    - The harware model limits how many address objects a security policy can reference. For SRX300, this is 2048.
    - Limit-wise, an IPv6 address is counted as 4 IPv4 addresses.
- Examples:
    - Define single address: `set security address-book global address HOST4_DNS_srv 10.0.0.10/32`
    - Define range: `set security address-book global address RNG4_DNS_srv range-address 10.0.0.10 to 10.0.0.11`
    - Define DNS name: `set security address-book global address FQDN4_yolo dns-name example.net`

### Security Policies

- Source and destination addresses may be negated using `source-address-excluded` and `destination-address-excluded`.

{% include footer.md %}
