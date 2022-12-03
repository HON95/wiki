---
title: Network Architecture
breadcrumbs:
- title: Network
---
{% include header.md %}

## Topologies

### Flat

- A single L2 domain/layer.
- Switching, routing and firewalling is all done by the same device or device stack, with clients directly connected.

### Three-layer Hierarchical Model

- Appropriate for large networks spanning multiple regions (e.g. multiple buildings).
- Scales well.
- Focuses on north-south traffic.
- Consists of three layers.
- Access layer:
    - L2 switches.
    - Connected to clients.
    - Typically one access-layer VLAN spans one or a few access switches.
    - Should implement first-hop security.
    - Connected upstream to distribution switches.
- Distribution layer:
    - Aka "distro" layer.
    - L3 switches.
    - Terminates access-layer VLANs.
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

- Similar to the three-layer hierarchical model, but with the core and distribution layers collapsed into the same devices.
- This generally means that there is only one routed layer.
- Distro layer devices may be interconnected directly or through one or more core _switches_ (not routers) which are _not_ themselves interconnected.
- Appropriate for medium/small sites without multiples regions, where a separate core network is not needed.

### Collapsed Distribution

- Similar to the three-layer hierarchical model, but with the distribution and access layers collapsed.
- Generally not very useful.

### Spine-Leaf

- A type of Clos network (non-hierarchical).
- Two or three layers: Leaf layer, spine layer and an optional super-spine layer (for larger networks).
- Leaf switches connect to every spine switch and not to any other leaf switches.
- Spine routers (or switches) are not connected to any other spine routers.
- Hosts connect only to leaf switches.
- All spine-leaf links are L3 (routed).
- Every pair of leaf switches are always two hops away from each other.
- Routers to external areas, firewalls and load balancers are added connected leaf switches called border leaves.
- Large spine-leaf networks may be broken into multiple networks where the spine rouers are connected to routers in the super-spine layer.
- Focuses on east-west traffic.
- Requires ECMP for optimal utilization.
- Well suited for data centers.
- Well suited for VXLAN for allowing hosts to move easily between leaf switches.

## Terms

- Equal-cost multi-path routing (ECMP): Routing strategy for forwarding over multiple best paths to the same destination.
- Oversubscription: Less uplink capacity than downlink capacity. Appropriate when downstream devices rarely use the uplink simultaneously, allowing them to share the uplink capacity without sacrifice.

## Miscellanea

- Q-in-Q (simple) or VXLAN (sophisticated) may be used to span VLANs over different areas.

{% include footer.md %}
