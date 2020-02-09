---
title: Network Architecture
breadcrumbs:
- title: IT
- title: Network
---
{% include header.md %}

## Models

### Single Layer

- Switching, routing and firewalling is all done on the same layer, with clients directly connected.

### Three-layer Hierarchical Model

- Appripriate for large networks spanning multiple regions (e.g. multiple buildings).
- Scales well.
- Consists of three layers.
- Access layer:
    - L2 switches.
    - Connected to clients.
    - Typically one access-layer VLAN spans one or a few access switches.
    - Should implement first-hop security.
    - Connected upstream to distribution switches.
- Distribution layer:
    - L3 switches or routers.
    - terminates access-layer VLANs.
    - Implements features like filtering and QoS.
    - May manage individual WAN connections.
    - Connected upstream to core routers and ptionally interconnected with other distribution switches.
- Core layer:
    - Routers.
    - Provides a backbone between distribution regions and toward external networks.
    - Focuses entirely on high bandwidth, low latency, high reliability and high resilience.
    - Avoids anything that may slow down traffic, like access lists, policy enforcement, etc.
    - It's possible to connect multiple core routers and distribution switches by using a switch.

### Collapsed Core

- Similar to the three-layer hierarchical model, but with the core and distribution layers collapsed.
- Appropriate for medium/small sites without multiples regions.

### Collapsed Distribution

- Similar to the three-layer hierarchical model, but with the distribution and access layers collapsed.
- Generally not very useful.

### Spine Leaf

**TODO**

## Notes

- VXLAN or Q-in-Q may be used to span VLANs over different areas.
- Oversubscription: Less uplink capacity than downlink capacity.

{% include footer.md %}
