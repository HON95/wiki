---
title: IPv4 Theory
breadcrumbs:
- title: Network
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
| `232.0.0.0/8` | SSM range, locally assigned |
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

- For multicast cooordination between the host and the first-hop router.
- Allows multicast listeners to _join_ and _leave_ multicast groups, and allows the router to query the listeners for group memberships.
- IGMPv1 (RFC 1054):
    - Mostly replaced by ICMPv2 and ICMPv3, rarely used.
    - The querier queries all hosts at local address 224.0.0.1, and hosts respond.
    - Hosts have no mechanism for leaving a group, other than waiting for the timeout. This can lead to being a member of a very large number of groups while "channel surfing".
    - It has no querier election method, other than relying on PIM DR election.
- IGMPv2 (RFC 2236):
    - Adds a leave process, group queries, querier election (separated from DR election) and a maximum response time (MRT) field.
    - Group queries are only sent to the specific groups and not all hosts.
    - The maximum response time (MRT) is used in queries to inform hosts about how long the router will wait for a report. Hosts will wait a random amount of time less than the MRT and then sends a report if no other host has sent one yet. This reduces the amount of reports in the local network. IGMPv1 uses a hardcoded value of 10 seconds instead. The maximum configurable value is 25 seconds (255s/10). If the timer runs out on the router and no reports have been received, it informs PIM that there are no more listeners.
- Configuration and commands: See [Multicast](/networking/multicast/).

{% include footer.md %}
