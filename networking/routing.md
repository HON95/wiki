---
title: Routing
breadcrumbs:
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [BGP](../bgp/)

## General

- Route source types:
    - Directly connected.
    - Static (manually configured).
    - Dynamic (from routing protocol).
- Typical routing protocol types:
    - All types are based on shortest path from one vertex to all other vertices on a directed graph.
    - Link state (LS):
        - Information about all links are distributed/flooded to all routers in some area.
        - Uses a variant of Dijkstra's algorithm which runs independently on all routers based on all link states to build the routing tables.
        - May be computationally intensive and traffic heavy for larger areas.
    - Distance vector (DV):
        - Uses a variant of the Bellman Ford algorithm where routers cooperatively and iteratively build their routing tables based on neighbors' routing tables.
        - Vulnerable to the count-to-infinity problem, but certain mechanisms like split horizon with poisoned reverse, maximum hops and hold times may be used to avoid/reduce the problem.
        - May have high convergence times for large areas.
    - Path vector or distance path:
        - Like DV, but includes the path to reach the destination.
        - May include a set of attributes which makes it better suited for policy routing.
        - The path avoids loops and therefore the count-to-infinity problem.
    - PV protocols (like BGP) are generally exterior gateway protocols (EGPs) (inter-AS) while LS (like OSPF ans IS-IS) and DV (like RIP) protocols are generally interiot gateway protocols (IGPs) (intra-AS).
    - Some protocols support hierarchical architectures consisting of multiple areas.
- Administrative distance:
    - If multiple equal prefixes are learned from different routing protocols, the administrative distance for each protocol is used (by most vendors) to select the route used.
    - Note that this selection is _after_ longest-path matching if multiple resulting equal paths exist.
    - Cisco uses the following administrative distances (the lowest is chosen):
        - Directly connected (0)
        - Static (1)
        - eBGP (20)
        - OSPF (110)
        - IS-IS (115)
        - RIP (120)
        - iBGP (200)
        - Unknown (255)
- Classless inter-domain routing (CIDR) allows for aggregating multiple neighboring long prefixes into fewer combined prefixes, aka route summarization or supernetting. (Variable length subnet mask (VLSM), on a distant but related note, is about splitting a short prefix into longer ones, aka subnetting.)
- Care should be taken when redistributing routes between routing protocols, due to e.g. loops, information loss, flapping propagation.

## Autonomous Systems (ASes)

- Identified by a registered AS nuymber (ASN).
- ASNs and IP addresses (and other Internet number resources) are assigned and registered by regional Internet registries (RIRs) (ARIN, RIPE NCC, AFRINIC, APNIC and LACNIC). RIRs are delegated resoursed by the Internet Assigned Numbers Authority (IANA). Local Internet registries (LIRs) are large organizations (typically ISPs) which have been allocated one or more large blocks of IP addresses which it may assign to its customers.
- In addition to getting assigned a unique ASN, one can potentially borrow ASNs from the upstream ISP or use the private ASN range (64512-65535).
- Tied to an individual or an organization.
- Should represent a single administrative zone.
- Single-homed or multi-homed.
- May allow peering with neighboring ASes, where all traffic has a source in one AS and a destination in the other AS.
- May allow transit, where traffic flows through the AS to/from neighboring ASes, but neither the sources or destinations of the traffic is in the AS.
- Peering and transit between neighboring ASes physically happens at Internet exchange points (IXPs) or a private network interconnect (PNI).

{% include footer.md %}
