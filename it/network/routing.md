---
title: Routing Theory
breadcrumbs:
- title: IT
- title: Network
---
{% include header.md %}

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

## BGP

- A path vector protocol and the only EGP used on the Internet.
- Version 4 (BGP-4) with multiprotocol extensions (MBGP) is the most common version, which supports CIDR, route aggregation and _address families_ such as multicast IPv4, unicast IPv6 and VPN information for MPLS.
- Uses a set of attributes to describe a route (see subsection).
- Route filtering and RPKI are methods commonly used to prevent accidental or malicious misconfiguration where prefixes are routed a place they should not.
- Redistributing between BGP and an IGP should in most cases be avoided. BGP has huge routing tables. IGP is dumber than BGP. IGP flapping should not leak onto EGPs, this may also be penalized by _BGP dampening_.
- Unlike typical IGPs, it does not support any kind of auto discovery of other BGP peers, but peers must instead be statically configured. It uses TCP port 179.
- Exterior BGP (eBGP) is used to advertise and receive routes from peers in other ASes, while interior BGP (iBGP) is used to distribute routes between all eBGP routers in the same AS. iBGP is used instead of an IGP because an IGP would lose BGP information.
- The iBGP split horizon rule: Routers are not allowed to adversise a route learned from one iBGP peering to another iBGP peering. This prevents loops in iBGP, but requires that peers must be connected in a full mesh. To reduce the complexity of the iBGP full mesh, techniques like route reflectors (RRs) (dividing the AS into clusters) and confederations (dividing the AS into sub-ASes) may be used.
- eBGP peers are generally required to be directly connected, which is enforced by using an IP TTL of 1. This limit may be relaxed by using multihop sessions. iBGP however is not subject to thus requirement.
- The synchronization rule: When a router receives a new route to announce from iBGP, it must first wait until it can validate the route from the IGP (in case iBGP is faster). This prevents announcing over eBGP a route that can't yet be routed within the AS.
- Full BGP tables are exchanged only during the start of peer sessions. Thereafter, only new announcements or withdrawals are exchanged.
- Network layer reachability information (NLRI) is basically what BGP calls prefixes/routes (and some extra information for address families other than IPv4).
- Message types:
    - Open: The first message sent when starting a session, for identifying eachother's capabilities and exchange basic information (not routes).
    - Update: Exchanges new route advertisements or withdrawals.
    - Notification: Signals errors and/or closes the session.
    - Keepalive: Shows it's still alive in the absence of update messages. Both keepalives and updates reset the hold timer.

### Attributes

Classification:

- Mandatory/descretionary: If the attribute must be included in all updates.
- Well-knon/optional: If all implementations are required to recognize the attribute.
- Transitive/non-transitive: If an AS should be advertise an attribute it received from one AS to other ASes or if it is only of significance between pairs of ASes/peers.

Some important attributes:

- Origin (well-known, mandatory): How the prefix entered BGP. 0/"i" means from IGP, 1/"e" means from EGP, 2/"?" means redistributed from other sources or static routes.
- AS path (well-known, mandatory): The path of ASes to pass through in order to reach the destination. An eBGP peer prepends its own ASN before advertising it to other peers. ASes are free to append their ASN multiple times in series to artificially make the path longer (BGP prefers the shortest AS path during the path selection algorithm). If an AS aggregates prefixes from other ASes, it may use AS sets to indicate all ASes from which it aggregated the prefixes, giving an AS path like e.g. `100, {200, 201}`.
- Next hop (well-known, mandatory): The address of the nex hop towards the destination. eBGP peers will always change this to their own address but iBGP peers will never alter it.
- Multi-exit discriminator (MED) (optional, non-transitive): When two ASes peer with multiple eBGP peerings, this number signals which of the two eBGP peerings should be used for incoming traffic (lower is preferred). This is only of significance between friendly ASes as ASes are selfish and free to ignore it (other alternatives for steering incoming traffic are AS path prepending, special communities and (as a very last resort) advertising more specific prefixes).
- Local preference (well-known, discretionary, non-transitive): A number used to prioritise outgoing paths to another AS (higher is preferred).
- Weight (Cisco-proprietary): Like local pref., but not exchanged between iBGP peers.
- Community (optional, transitive): A bit of extra information used to group prefixes that should be treated similarly within or between ASes. There exists a few well-known communities such as "internet" (advertise to all neighbors), "no-advertise" (don't advertise toBGP neighbors), "no-export" (don't export to eBGP neighbors) and "local-as" (don't advertise outside the sub-AS).

### Path Selection

The path selection algorithm is used to select a single best path for each prefix. The following shows an ordered list of decisions for which route to use (based on Cisco, may be inaccurate):

1. (Before path selection) Longest prefix match.
1. Highest weight (Cisco).
1. Highest local pref.
1. Locally originated ("network" or "aggregate" command).
1. Shortest AS path.
1. Lowest origin (IGP then EGP then other).
1. Lowest MED (typically ignored).
1. eBGP over iBGP.
1. Lowest IGP metric.
1. Lowest BGP router ID.

{% include footer.md %}
