---
title: Multicast
breadcrumbs:
- title: Networking
---
{% include header.md %}

## TODO

- PIM-SM with Anycast-RP, often with MSDP or Cisco Nexus-specific Anycast-RP-set.
- PIM-BiDir with Phantom-RP.

## Basics

- Supports one-to-one, one-to-many, many-to-one and many-to-many communication. \*-to-many is generally the only useful variants, as \*-to-one is typically better solved using unicast.
- Not natively supported on the Internet, mostly used within organisations and service providers only.
- Typically uses UDP, as TCP handshakes won't work.
- Any host can send multicast into the network without to create a multicast stream, it doesn't first need to declare an intent to do so. The first-hop router will then create a multicast forwarding entry.
- Receiving multicast generally requires "joining the group" first, so routers know where to forward it to.
- Uses either any-source multicast (ASM) or source-specific multicsat (SSM).
- Multicast entries are denoted using a _source comma group_ `(S, G)` entry for sender S and group G. With any-source multicast, a _star comma group_ `(*, G)` entry is used for lookups and will match any sender.
- Whereas unicast uses a RIB and a FIB, multicast uses an MRIB and an MFIB.
- Hosts on a network use Internet Group Messaging Protocol (IGMP) for IPv4 or Multicast Listener Discovery (MLD) for IPv6 toward the first-hop router to declare the interest in joining a multicast group (_joining_ and _leaving_). The router registers this in the MFIB and may use Protocol Independent Multicast (PIM) for IPv4 or PIM6 for IPv6 to forward the registration upstream.
- Like other IP space, multicast IP space is managed by IANA.
- _Replication_ is the process of duplicating a packet when it needs to be sent out of multiple interfaces, at branching points in the multicast tree. For complex switches such as chassis devices with line cards, the replication step is often pushed to the last switching complex possible (_egress replication_).
- IP multicast is mapped to the MAC address range `01:00:5e:00:00:00 - 01:00:5e:7f:ff:ff`, with the lower 23 bits of the IP address is mapped to the lower 23 bits of the MAC address. Switches register this address range as multicast and floods it, while hosts can use the mapping for more efficient group filtering. Notice that this has a 32-to-1 oversubscription of groups.
- Storm control should typically be configured on switches to prevent multicast using all available bandwidth.

### Address Space

See the [IPv4](/networking/ipv4/) and [IPv6](/networking/ipv6/) pages.

## Protocols

### Internet Group Messaging Protocol (IGMP)

- For last-hop multicast subscription management in IPv4 networks.
- See [IPv4](/networking/ipv4/).

### Multicast Listener Discovery (MLD)

- For last-hop multicast subscription management in IPv6 networks.
- See [IPv6](/networking/ipv6/).

## Vendor Support

### Cisco IOS XE

#### Operational Commands

- "Routing" (mostly PIM):
    - Show active groups: `show {ip|ipv6} [vrf <vrf>] mroute [group] [{verbose|count}]`
    - Show RPF interface/destination: `show ip rpf [vrf <vrf>] <address>` (source or RP)
- PIM:
    - Show interfaces: `show ip pim interface brief`
    - Show neighbors: `show ip pim neighbor`
- IGMP (IPv4):
    - Show active groups: `show ip igmp groups`
    - Show routed interface info: `show ip igmp interface <interface>`
- MLD (IPv6):
    - Show routed interface info: `show ipv6 mld interface <interface>`
    - Show active groups (summary): `show ipv6 mld groups summary`
    - Show active groups (detail): `show ipv6 mld groups [group-address] [interface <interface>] [detail]`
- IGMP snooping (IPv4):
    - Show basic info: `show ip igmp snooping`
    - Show mrouter interfaces: `show ip igmp snooping mrouter`
    - Show groups interfaces: `show ip igmp snooping groups`
- MLD snooping (IPv6):
    - **TODO**

#### Configuration

- Enable multicast routing: `{ip|ipv6} multicast-routing`
- IGMP (IPv4):
    - Enable on router interface (through PIM): `ip pim sparse-mode` (IGMPv2 by default)
    - Change version on router interface; `ip igmp version {1|2|3}`
    - Set query interval: `ip igmp query-interval [interval]` (seconds)
    - Set query MRT: `ip igmp query-max-response-time [interval]` (seconds)
    - Set query timeout, for querier election: `ip igmp query-timeout [interval]` (seconds)
    - Set query count before group removal: `ip igmp last-member-query-count [count]` (1-7)
        - Defaults to `ip igmp robustness`.
    - Set the robustness (the number of expected packet drops): `ip igmp robustness <count>` (1-7)
    - Set immediate-leave mode: `ip igmp immediate-leave [group-list <groups>]`
        - Treats the interface as having only a single host, so leave messages causes the group to be removed from the interface immediately instead of querying a few times first.
        - Use this on access ports.
- IGMP snooping (IPv4):
    - Enable snooping (enabled by default): `ip igmp snooping`
- MLD (IPv6):
    - Set query MRT: `ipv6 mld query-max-response-time [interval]` (seconds)
    - **TODO**

#### Resources

- [Implementing IPv6 Multicast (Cisco Catalyst 9500)](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst9500/software/release/16-8/configuration_guide/ipv6/b_168_ipv6_9500_cg/b_168_ipv6_9500_cg_chapter_010.pdf)

{% include footer.md %}
