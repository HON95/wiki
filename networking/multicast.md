---
title: Multicast
breadcrumbs:
- title: Networking
---
{% include header.md %}

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

- For cooordination between the host and the first-hop router for IPv4 multicast.
- Has a designated _querier_ per subnet, often the default gateway router itself. The querier sends periodic queries to the hosts and the hosts report their group memberships.
- IGMPv1 (RFC 988):
    - Offers the basic query-and-response functionality to determine group memberships, sent to the all-hosts group 224.0.0.1.
    - Doesn't support signaling to leave groups other than waiting for the timeout, meaning hosts quickly joining a large number of groups for an intended short period of time per group will end up with a lot of unwanted memberships waiting to time out and a large amount of pointless traffic.
    - The querier is selected using PIM.
    - Rarely used.
- IGMPv2 (RFC 2236):
    - Like v1 but with a leave process, group-queries, separated DR and querier role, querier election and the MRT field.
    - Using the leave process, hosts can simply send a leave message to the querier to leave a group.
    - Group queries are sent to specific groups instead of sending it to the all-hosts group. General queries are still sent to the all-hosts group to determine memberships of any group.
    - The new querier election requires that all multicast routers send a general query to the all-hosts group and then by default chooses the router with the highest IP address as the dedicated router (DR) and the router with the lowest address ad the querier. PIM is no longer needed for the election.
    - The new maximum response time (MRT) defines how long a host can wait before sending a membership report following a group query. When it receives a query, it will wait a random amount of time lower than the MRT and only send a report if no other host has done it yet, to avoid sending superfluous reports.
    - Still supported by most routers.
- IGMPv3 (RFCs 3376 and 4604):
    - Added support for SSM. The header got expanded with a list of source addresses to subscribe to for a given group, or sources to exclude membership to.
    - The max response time (MRT) got replaced by a max response code (MRC), which semantically still works the same but now supports much larger values due to a new, strange number format.
- Version interoperability: With a mix of support on hosts on a subnet, the lowest common version is used.
- IGMP snooping:
    - Used by switches to snoop on group joins and leaves to track which ports to send multicast to, to avoid flooding on the L2 domain.
    - Switches snoop on IGMP query messages and PIM hellos in order to map the group address to output interfaces in the CAM table.
    - Ports connected to a multicast-capable router should be marked, as they require special treatment.
    - The switch does not forward joins and leaves to the mcast router interface unless it it the first join or last leave.
    - As an alternative to snooping, Cisco Group Management Protocol (CGMP) and Router-port Group Management Protocol (RGMP) were developed, but are rarely used.

### Multicast Listener Discovery (MLD)

- For cooordination between the host and the first-hop router for IPv6 multicast, similarly to IGMP for IPv4.
- See [IPv6](/networking/ipv6/).

## Vendor Support

### Cisco IOS XE

#### Operational Commands

- Routing:
    - Show mcast routing table: `show {ip|ipv6} mroute [group]`
- IGMP (IPv4):
    - Show active groups: `show ip igmp groups`
    - Show routed interface info: `show ip igmp interface <interface>`
- IGMP snooping (IPv4):
    - Show basic info: `show ip igmp snooping`
    - Show mrouter interfaces: `show ip igmp snooping mrouter`
    - Show groups interfaces: `show ip igmp snooping groups`
- MLD (IPv6):
    - Show routed interface info: `show ipv6 mld interface <interface>`
    - Show active groups (summary): `show ipv6 mld groups summary`
    - Show active groups (detail): `show ipv6 mld groups [group-address] [interface <interface>] [detail]`

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
