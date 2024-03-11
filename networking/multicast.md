---
title: Multicast
breadcrumbs:
- title: Network
---
{% include header.md %}

## Basics

- Supports one-to-one, one-to-many, many-to-one and many-to-many communication. \*-to-many is generally the only useful variants, as \*-to-one is typically better solved using unicast.
- Not natively supported on the Internet, mostly used within organisations and service providers only.
- Typically uses UDP, as TCP handshakes won't work.
- Any host can send multicast into the network without first declaring an intent to do so. The first-hop router will then create a multicast forwarding entry.
- Receiving multicast generally requires "joining the group" first, so routers know where to forward it to.
- Uses either any-source multicast (ASM) or source-specific multicsat (SSM).
- Multicast entries are denoted using a _source comma group_ `(S, G)` entry for sender S and group G. With any-source multicast, a _star comma group_ `(*, G)` entry is used for lookups and will match any sender.
- Whereas unicast uses a RIB and a FIB, multicast uses an MRIB and an MFIB.
- Hosts on a network use Internet Group Messaging Protocol (IGMP) for IPv4 or Multicast Listener Discovery (MLD) for IPv6 toward the first-hop router to declare the interest in joining a multicast group (_joining_ and _leaving_). The router registers this in the MFIB and may use Protocol Independent Multicast (PIM) for IPv4 or PIM6 for IPv6 to forward the registration upstream.
- Like other IP space, multicast IP space is managed by IANA.
- _Replication_ is the process of duplicating a packet when it needs to be sent out of multiple interfaces.
- Unlike an IP broadcast where the MAC address is the all-ones address, IP multicast is mapped to the MAC address range `01:00:5e:00:00:00-01:00:5e:7f:ff:ff` (25b). The lower 23 bits of the IP address is mapped to the lower 23 bits of the MAC address. Switches register this address range as multicast and floods it, while hosts can use the mapping for more efficient group filtering.

### Address Space

See the [IPv4](../ipv4/) and [IPv6](../ipv6/) pages.

## Protocols

### Internet Group Messaging Protocol (IGMP)

- For cooordination between the host and the first-hop router.
- See [IPv4](../ipv4/).

### Multicast Listener Discovery (MLD)

- For cooordination between the host and the first-hop router.
- See [IPv6](../ipv6/).

## Vendor Support

### Cisco IOS XE

#### Operational Commands

- Routing:
    - Show mcast routing table: `show {ip|ipv6} mroute [group]`
- IGMP (IPv4):
    - Show active groups: `show ip igmp groups`
    - Show routed interface info: `show ip igmp interface <interface>`
- MLD (IPv6):
    - Show routed interface info: `show ipv6 mld interface <interface>`
    - Show active groups (summary): `show ipv6 mld groups summary`
    - Show active groups (detail): `show ipv6 mld groups [group-address] [interface <interface>] [detail]`

#### Configuration

- Enable multicast routing: `{ip|ipv6} multicast-routing`
- IGMP (IPv4):
    - Set query interval: `ip igmp query-interval [interval]` (seconds)
        - Shows timers, version, DR, querier etc.
    - Set query MRT: `ip igmp query-max-response-time [interval]` (seconds)
    - Set query timeout, for querier election: `ip igmp query-timeout [interval]` (seconds)
    - Set query count before group removal: `ip igmp last-member-query-count [count]` (1-7)
        - Defaults to `ip igmp robustness`.
    - Set the robustness (the number of expected packet drops): `ip igmp robustness <count>` (1-7)
    - Set immediate-leave mode: `ip igmp immediate-leave [group-list <groups>]`
        - Treats the interface as having only a single host, so leave messages causes the group to be removed from the interface immediately instead of querying a few times first.
        - Use this on access ports.
    - Show snooper info: `show ip igmp snooping <...>`
- MLD (IPv6):
    - Set query MRT: `ipv6 mld query-max-response-time [interval]` (seconds)
    - **TODO**

#### Resources

- [Implementing IPv6 Multicast (Cisco Catalyst 9500)](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst9500/software/release/16-8/configuration_guide/ipv6/b_168_ipv6_9500_cg/b_168_ipv6_9500_cg_chapter_010.pdf)

{% include footer.md %}
