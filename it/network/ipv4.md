---
title: IPv6 Theory
breadcrumbs:
- title: IT
- title: Networking
---
{% include header.md %}

## Special Prefixes

|Prefix|Description|
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

### Special Addresses

- The first address in a network is reserved for identifying the network and cannot be used by any hosts.
- The last address in the network is reserved for directed broadcasts targeted at all hosts within the certain network.
  It it routable and frequently blocked.

{% include footer.md %}
