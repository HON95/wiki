---
title: IPv4 Theory
breadcrumbs:
- title: Networking
---
{% include header.md %}

## Special Prefixes and Addresses

| Prefix | Description |
|-|-|
| `0.0.0.0/8` | Current network |
| `10.0.0.0/8` | Private network |
| `100.64.0.0/10` | Shared address space for CGN |
| `127.0.0.0/8` | Localhost |
| `169.254.0.0/16` | Link-local autoconfiguration |
| `172.16.0.0/12` | Private network |
| `192.0.0.0/24` | IETF Protocol Assignments |
| `192.0.2.0/24` | Documentation (TEST-NET-1) |
| `192.18.0.0/15` | Inter-network benchmarking |
| `192.51.100.0/24` | Documentation (TEST-NET-2) |
| `192.88.99.0/24` | 6to4 anycast (deprecated) |
| `192.168.0.0/16` | Private network |
| `203.0.113.0/24` | Documentation (TEST-NET-3) |
| `224.0.0.0/4` | Multicast (formerly Class D) |
| `240.0.0.0/4` | Reserved (formerly class E) |
| `255.255.255.255/32` | Limited broadcast |

### Multicast (Main)

| Range | Description |
|-|-|
| `224.0.0.0/4` | Multicast range |
| `224.0.0.0/24` | Local Network Control, for local router protocols, like OSPF, uses TTL=1 |
| `224.0.1.0/24` | Internetwork Control, for global protocols, like NTP |
| `224.0.2.0-224.0.255.255` | AD-HOC I, publicly routable and publicly assigned |
| `224.1.0.0/16` | Reserved |
| `224.2.0.0/16` | Session Description Protocol/Session Announcement Protocol (SDP/SAP) |
| `224.3.0.0/15` | AD-HOC II, see block I |
| `224.5.0.0-224.255.255.255` | Reserved |
| `232.0.0.0/8` | Source-specific multicsat (SSM), locally assigned |
| `233.0.0.0-233.251.255.255` | GLOP, /24 blocks for 16-bit ASNs, experimental |
| `233.252.0.0/14` | AD-HOC III, see block I |
| `234.0.0.0-238.255.255.255` | Reserved |
| `239.0.0.0/8` | Administratively scoped, for use within a private domain, like RFC 1918 |

#### Multicast (Special)

| Range | Description |
|-|-|
| `224.0.0.1` | All systems on this subnet |
| `224.0.0.2` | All routers on this subnet |
| `224.0.0.22` | IGMP |
| `224.0.0.251` | mDNS |
| `224.0.0.252` | LLMNR |

### Special Addresses

- The first address in a network is reserved for identifying the network and cannot be used by any hosts.
- The last address in the network is reserved for directed broadcasts targeted at all hosts within the certain network. It it routable and frequently blocked by the last-hop router.

## Addressing

### Classful Routing

Originally the IPv4 address space was split into five classes with fixed, implicit subnet masks, as seen below:

| Class | Leading bits | First address | Network bits | Purpose |
| - | - | - |
| A | `0` | `0.0.0.0` | `8` | Unicast |
| B | `10`| `128.0.0.0` | `16` | Unicast |
| C | `110` | `192.0.0.0` | `24` | Unicast |
| D | `1110` | `224.0.0.0` | N/A | Multicast |
| E | `1111` | `240.0.0.0` | N/A | Reserved |

### VLSM and CIDR

**Variable-length subnet masking (VLSM)** allows splitting networks into multiple smaller networks (subnetting). It is the opposite of fixed-length subnet masking.

**Classless inter-domain routing (CIDR)** allows combining multiple smaller networks (with a common prefix) into a larger network (supernetting). It is the opposite of classful routing.

The terms are frequently interchanged and now typically used to refer to the same thing.

## Protocols

### Internet Group Messaging Protocol (IGMP)

- For cooordination between the host and the first-hop router for IPv4 multicast.
- Has a designated _querier_ per subnet, often the default gateway router itself. The querier sends periodic queries to the hosts and the hosts report their group memberships.
- IGMPv1 (RFCs 988, 1054 and 112):
    - Offers the basic query-and-response functionality to determine group memberships, sent to the all-hosts group 224.0.0.1.
    - Doesn't support signaling to leave groups other than waiting for the timeout, meaning hosts quickly joining a large number of groups for an intended short period of time per group will end up with a lot of unwanted memberships waiting to time out and a large amount of pointless traffic.
    - The querier is selected using PIM.
    - Rarely used.
- IGMPv2 (RFC 2236):
    - Like v1 but with a leave process, group-queries, separated DR and querier role, querier election and the MRT field.
    - Using the leave process, hosts can simply send a leave message to the querier to leave a group.
    - Group queries are sent to specific groups instead of sending it to the all-hosts group. General queries are still sent to the all-hosts group to determine memberships of any group.
    - The new querier election requires that all multicast routers send a general query to the all-hosts group and then by default chooses the router with the highest IP address as the dedicated router (DR) and the router with the lowest address ad the querier. PIM is no longer needed for the election.
    - The new maximum response time (MRT) defines how long a host can wait before sending a membership report following a group query. When it receives a query, it will wait a random amount of time lower than the MRT and only send a report if no other host has done it yet, to avoid sending superfluous reports. IGMPv1 uses a hardcoded value of 10 seconds instead. The maximum configurable value is 25 seconds (255s/10). If the timer runs out on the router and no reports have been received, it informs PIM that there are no more listeners.
    - Still supported by most routers.
- IGMPv3 (RFCs 3376 and 4604):
    - Added support for SSM.
    - The header got expanded with a list of source addresses to subscribe to for a given group, or sources to exclude membership to.
    - The leave message was removed, as the leave process can now be done using the list in the report.
    - The max response time (MRT) got replaced by a max response code (MRC), which semantically still works the same but now supports much larger values due to a new, strange number format.
- Version interoperability: With a mix of support on hosts on a subnet, the lowest common version is used.
- IGMP snooping:
    - Used by switches to snoop on group joins and leaves to track which ports to send multicast to, to avoid flooding on the L2 domain.
    - Switches snoop on IGMP query messages and PIM hellos in order to map the group address to output interfaces in the CAM table.
    - Ports connected to a multicast-capable router should be marked, as they require special treatment.
    - The switch does not forward joins and leaves to the mcast router interface unless it it the first join or last leave.
    - As an alternative to snooping, Cisco Group Management Protocol (CGMP) and Router-port Group Management Protocol (RGMP) were developed, but are rarely used.
- Configuration and commands: See [Multicast](/networking/multicast/).

{% include footer.md %}
