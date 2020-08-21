---
title: Switching Theory
breadcrumbs:
- title: IT
- title: Networking
---
{% include header.md %}

## Switching Modes (Ethernet)

- Store and forward switching:
    - Receive the whole packet befoe forwarding it.
    - Checks integrity.
    - Adds delay.
- Cut-through switching:
    - Start forwarding as soon as the destination address has been inspected.
    - Forwards bad packets.
    - Recuces delay.
- Fragment-free switching:
    - Like cut-through switching, but reads at least 64 bytes before forwarding.
    - Prevent forwarding runt frames, which are less than 64 bytes (the minimum frame length).

## Virtual LAN (VLAN)

### Q-in-Q

- IEEE 802.1ad/802.1Q.
- For tunneling VLANs using multiple layers of 802.1Q headers.

### Virtual Extensible LAN (VXLAN)

- RFC 7348.
- For tunneling VLANs using a UDP overlay network (defauylt port 4789).
- VXLAN network identifiers (VNIs) (24-bit) identify bridge domains.
- VXLAN tunnel endpoints (VTEPs) encapsulate/decapsulate the traffic.
- VTEPs may be either on hosts or on switches/routers as gateways.
- Address learning:
    - Data plane learning: Flood and learn.
    - Data plane learning: Uses BGP to route wrt. MAC addresses.
- BUM handling using multicast:
    - Requires multicast routing-enabled infrastructure.
    - VNI are mapped to multicast groups (N:1).
    - VTEPs joins the groups for its VNIs using IGMP.
    - BUM traffic is only sent to the relevant groups.
- BUM handlign using head end replication:
    - Requires BGP EVPN.
    - Doesn't scale as well as when using multicast.
    - BUM traffic is replicated and sent as unicast to each VTEP that supports the VNI.
- Consider using jumbo frames to avoid fragmentation.

## Miscellaneous

- Broadcast, unknown-unicast and multicast traffic (BUM traffic):
    - Generally flooded.
    - Doesn't scale well, which is the primary element of how well L2 domains scale.
    - Throttling and port security helps prevent traffic storms.

{% include footer.md %}
