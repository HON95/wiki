---
title: Switching
breadcrumbs:
- title: Networking
---
{% include header.md %}

Layer 2 stuff.

## Terms

| Cisco IOS | HP Aruba | Brocade ICX |
| - | - | - |
| EtherChannel/Port-channel | Trunk | Link aggregation |
| Access port | Untgged port | Untagged port |
| Trunk port | Tagged port | Tagged port |
| Native VLAN | Primary VLAN | Untagged VLAN (dual mode) |
| Default VLAN | | Default VLAN

## Virtual LAN (VLAN)

### VLAN IDs (VIDs)

Valid VID range (802.1Q): 1-4095

Reserved:
- 0: Null/none (802.1Q).
- 1: Default (802.1Q).
- 1002: FDDI default (Cisco, old).
- 1003: Token ring default (Cisco, old).
- 1004: FDDI-Net (Cisco, old).
- 1005: TRNET (Cisco, old).
- 3968–4047: Internally allocated (Cisco Nexus).
- 4095: Reserved for implementation use (802.1Q).

### Q-in-Q

- IEEE 802.1ad/802.1Q.
- For tunneling VLANs using multiple layers of 802.1Q headers.

### Virtual Extensible LAN (VXLAN)

- RFC 7348.
- For tunneling VLANs using a UDP overlay network (default port 4789).
- Often used in L3 spine-leaf topologies or distant locations.
- Often paired with BGP EVPN (VXLAN MP-BGP EVPN for short) as the data plane, to manage tunnels and improve BUM handling.
- 24-bit VXLAN network identifiers (VNIs) identify bridge domains.
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
- BUM handling using head end replication:
    - Requires BGP EVPN.
    - Doesn't scale as well as when using multicast.
    - BUM traffic is replicated and sent as unicast to each VTEP that supports the VNI.
- Consider using jumbo frames on the underlay to avoid fragmentation.

## Spanning Tree Protocol (STP)

### Variants

**TODO**: This needs updating and more compat info.

| Names | Supporting Devices | Description |
| :--- | :--- | :--- |
| 802.1D, STP | Cisco IOS, Juniper Junos, Linksys LGS | Single instance, slow. |
| 802.1w, RSTP | Brocade ICX, Linksys LGS | Rapid STP. Single instance, but fast. Backwards-compatible with STP. |
| 802.1s, MSTP | *TBD* | Multiple STP. Similar to RSTP, but allows creating multiple instances and assigning one or multiple VLANs to them. |
| PVST | Cisco IOS | Like STP, but one instance per VLAN. |
| PVST+ | Cisco IOS | Like PVST, but compatible with classical/single-instance STP. |
| Rapid PVST/PVST+ | Cisco IOS | Like PVST or PVST+, but with rapid convergence times (like RSTP). |
| RSTP | Juniper Junos | **TODO** |
| VSTP | Juniper Junos | Based on RSTP, compatible with STP and Cisco's PVST. |
| 802.1Q |  | ??? |

**Note**: Very incomplete list, does not include most MSTP variants.

### General

- Use extended system ID for multi-VLAN switches.
- Make sure all switches are using compatible variants and default priorities.
- Make sure all VLANs are running STP or that STP is running globally (not per VLAN).
- STP (excluding per-VLAN STP and generally not MST) (including rapid versions) will consider multiple links between switches a loop, even when the links carry different VLANs.
- The bridge priority should generally be a multiple of 4096.
- PVST and 802.1Q regions cannot interoperate directly, but can through PVST+ regions.
- The root bridge should never have ports in blocked state.
- For e.g. two devices with two paths, one device will block one port, the other device won't block any of the ports.

### STP

- The original.
- Generally uses around 30 seconds after a new device is connected until it starts forwarding data (unless using Cisco's "portfast" or similar).
- Path cost depends on link speed.
- Uses BPDUs (bridge protocol data units) to exchange information.
- Generates and imposes a rooted spanning tree onto the non-acyclic network, where a single switch is designated as the root.
- Uses a single tree for all physical ports (no per-VLAN support).
- The BPDU from the root starts with root path cost 0 and accumulates all link costs along the distribution downstream.
- States:
    - Listening: The initial state when a device is connected. No data is forwarded and no MAC addresses are learned. Enters the listening state afterwards.
    - Learning: Like the listening state but with MAC address learning (no data forwarding yet). Enters the forwarding state afterwards.
    - Forwarding: Data is forwarded.
    - Blocking: If during the listening, learning or forwarding state a port is determined to be neither a root port (uplink) or a designated port (downlink), it's blocked.

### RSTP (802.1w)

- Generally backwards-compatible with STP.
- Has much better convergence time for new connections and topology changes than STP.
- Port roles:
    - Root port: The uplink port toward the root switch. Every non-root switch has exactly one.
    - Alternate port: A port which may quickly take over as the root port if the current root port becomes unavailable. (STP doesn't have this type, but e.g. Cisco's "uplinkfast" provides a similar mechanism.)
    - Designated port: Any downlink ports toward switches downstream from the current one wrt. the tree.
    - Backup port: Like the alternate port to the root port, it provides a backup for a designated port.
- Port states:
    - Discarding (aggregates the blocking, listening and disabled states from STP).
    - Learning.
    - Forwarding.

### Special Features

Note: These features are mostly vendor-defined and the specifics of each mechanism depend on the implementations.

- Loop guard: Enabled on root and alternate ports (typically) to move them to the blocking state instead of the forwarding state if they were to stop receiving BPDUs (e.g. due to a unidirectional or congestion), to avoid causing a forwarding loop.
- Root guard: Enabled on designated and backup ports (downlinks) to prevent downstream switches from taking over as the root bridge (e.g. due to misconfiguration).
- BPDU guard: Enabled on edge ports to block it if it receives any BPDUs (e.g. due to malicious purposes).
- BPDU filter: Enabled on edge ports to ignore all received BPDUs.
- Portfast: Enabled on edge ports to immediately move it to the forwarding state instead of going through the discarding and learning phases first, in order to get clients online as fast as possible.

### Cisco IOS

- VTP can be very dangerous if not used properly and is enabled by default. It also doesn't carry MST configuration.
- Rapid-PVST+ ignores UplinkFast and BackboneFast and supports UDLD.

## Ethernet Switching Modes

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

## Miscellanea

- Broadcast, unknown-unicast and multicast traffic (BUM traffic):
    - Generally flooded.
    - Doesn't scale well, which is the primary element of how well L2 domains scale.
    - Throttling and port security helps prevent traffic storms.

{% include footer.md %}
