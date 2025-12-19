---
title: BGP EVPN VXLAN Fabrics
breadcrumbs:
- title: Networking
---
{% include header.md %}

Network overlay fabric using BGP EVPN with VXLAN transport.

## TODO

- https://lostintransit.se/2023/12/30/configuring-evpn-on-nx-os/
- https://lostintransit.se/2024/01/31/nx-os-forwarding-constructs-for-vxlan-evpn/

## Basics

- Overlay network or network fabric:
    - A network "fabric" normally consisting of a routed (L3-only) underlay network and a tunneled (L2 and/or L3) overlay network.
    - Lets the underlay care about data transport and the overlay care about endpoints.
    - Normally supports multiple overlay VRFs, in addition to separating the overlay VRF(s) from the underlay VRF.
    - Often used with spine-leaf networks.
- The leafs typically use an anycast gateway with some static MAC- and IP-addresses used across all leafs. This means that inter-VLAN traffic on the same leaf may be routed directly on the leaf.
- Limitations of L2 networks that overlay networks fix:
    - No need for STP, which limits forwarding paths and may cause e.g. instabilities or slow convergence on topology changes.
    - L3-only underlay means ECMP may be used to transport packets over multiple paths (i.e. through all spines).
    - For non-spine-leaf networks, STP generally goes through the "top" switch (root bridge), while routed networks may allow shorter paths between endpoints.
    - Multiple physical hops to nearest router, while overlays use anycast gateways in all leafs.
    - Only 4k VLAN IDs, while VXLAN supports 16M VNIs.
- Overlay learning mechanisms (examples):
    - Flood and learn (classical L2 learning)
    - EVPN (most standardized)
    - COOP (Cisco ACI)
    - LISP (Cisco SDA)

## Border Gateway Protocol (BGP)

See [BGP](../bgp/).

## Virtual Extensible LAN (VXLAN)

- RFC 7348.
- For tunneling VLANs using a UDP overlay network.
- Removes the VLAN tag during transport if present, as it's mapped to a VNI instead.
- Removes the CRC of the original Ethernet frame, as the VXLAN frame will have its own CRC.
- Based on LISP transport, but tunnels packets at the MAC-layer instead of the IP-layer.
- Often used in L3 spine-leaf topologies or distant locations.
- Often paired with BGP EVPN to manage tunnels and improve BUM handling.
- 24-bit VXLAN network identifiers (VNIs) identify bridge domains.
- VXLAN tunnel endpoints (VTEPs) encapsulate/decapsulate the traffic.
- VTEPs may be either on hosts or on switches/routers as gateways.
- Used UDP transport with destination port 4789 and variable source port (based on inner header fields) for better entropy for ECMP.

## Ethernet VPN (EVPN)

- A MP-BGP address family for "Ethernet things".
- Technically EVPN is a SAFI under the L2VPN AFI (i.e. "L2VPN/EVPN").
- Provides:
    - Messaging of MAC and IP prefixes.
    - Ability discover VTEPs.
    - Reduced flooding and optional ARP suppression.

### EVPN Route Types

| Route type | Name | Description |
|-|-|-|
| Type 1 | Ethernet auto-discovery | ? |
| Type 2 | MAC/IP advertisement | Advertise MAC addresses and optionally associated IP addresses. |
| Type 3 | Inclusive multicast ethernet tag | For BUM traffic delivery. |
| Type 4 | Ethernet segment | Used for Designated Forwarder (DF) election in multi-homed scenarios, to decide which PE sends BUM traffic to the multi-homed CE. |
| Type 5 | IP prefix | Advertise IP addresses/prefixes separately from MAC addresses. |
| Type 6 | Selective multicast ethernet tag | For joining multicast groups (ASM og SSM). |
| Type 7/8 | IGMP join/leave synchronization | For synchronizing IGMP state between all PEs for a multi-homed CE, including the DF. |

## Underlay Routing Protocol

- No BFD requires as all underlay neighbors use physical interfaces (no SVIs or subinterfaces).
- Consider using IPv6-only.
- If IPv4 in the underlay is needed, consider using IPv4 over IPv6 nexthops (RFC 5549).
- OSPF or IS-IS:
    - Quick convergence.
    - Supports unnumbered linknets.
    - Simpler to configure.
    - Little configuration required, easy to template.
- BGP:
    - Slightly slower convergence.
    - May support unnumbered links.
    - May support automatic AS numbers.
    - More configuration required, depends on support for automatic parameters.
    - Scales better if using thousands of leafs.
- One VS two protocols:
    - Using BGP in both the underlay and overlay may seem like a simpler design.
    - Using OSPF/IS-IS in the underlay may cause a better separation of underlay and overlay routing.
- Remember to enable ECMP for the chosen protocol.

## BUM Traffic

- Can be handled using either underlay multicast or head-end replication.
- Underlay multicast:
    - PIM with anycast-RP must be configured in the underlay.
    - The underlay multicast group is configured statically for the VNI.
    - The number of multicast groups used is often limited, such that multiple VNIs may map to the same underlay group.
    - The leaf will both join and register for the group.
    - An anycast-RP must be configured, using MSDP (standard) or anycast-RP-set (Cisco Nexus).
- Head-end replication:
    - The source leaf must send a unicast copy of the frame to each other leaf with the VNI.
    - The VTEP list to send the copy to can be configured statically through the config or dynamically through EVPN.

## Cisco Nexus vPC

- Background info and recommendations: [Cisco NX-OS Switches](/cisco-nxos-switches/)
- For an alternative and less vendor-specific LACP approach, consider using ESIs.
- Anycast VTEP:
    - An additional VTEP used so that the VTEPs on the switch pair appear as one from VXLAN/EVPN perspective.
    - Implemented as an secondary address on both VTEP interfaces. EVPN will prefer secondary addresses for advertisements.
    - BGP will add a Site of Origin (SoO) community containing the anycast VTEP, which prevents the peers from learning each-others routes.
- Fabric peering:
    - Instead of using physical peer and keep-alive links, the switch pair may use "fabric peering" through the spines.
    - When using fabric peering, orphan ports are only advertised from the primary VTEP where the orphan port is, not the anycast VTEP.
    - Requires TCAM carving and QoS.
- Traffic between vPC peers:
    - Generally, the vPC peers should not learn EVPN routes from the other peer, to avoid loops. This is enforced through the Site of Origin (SoO) community containing the anycast VTEP.
    - L2 traffic between the leafs can traverse the peer-link trunk instead of EVPN.
    - To allow L3 traffic between the leafs (e.g. from a routed physical port), advertise the prefix with the primary VTEP instead of the anycast VTEP. This is enabled using `advertise-pip` ("Primary IP") and `advertise virtual-rmac`. This means that that type 5 routes will be advertised with PIP plus system MAC and type 2 routes will advertised with VIP plus virtual MAC.

## Miscellanea

- MTU:
    - Requires a larger underlay MTU than overlay MTU to account for the encapsulation overhead, e.g. 50b for IPv4 VXLAN and 70b for IPv6 VXLAN.
- Symmetric VS asymmetric IRB:
    - Refers to how traffic is routed between different VNIs on different leafs.
    - Asymmetric IRB:
        - All VLANs, SVIs and VNIs must be configured for all VLANs/VRFs.
        - The ARP, MAC and route tables must be populated for all VLANs/VRFs.
    - Symmetric IRB:
        - A third VNI is used for transport between leafs.
    - Symmetric IRB is often considered more optimal and less wasteful of resources than asymmetric IRB.

{% include footer.md %}
