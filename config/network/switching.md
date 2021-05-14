---
title: Switching
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

Layer 2 stuff.

## Terms

| Cisco IOS | Brocade ICX |
| - | - |
| Access port | Untagged port |
| Trunk port | Tagged port |
| Native VLAN | Dual mode |

## VLAN IDs

Valid VID range (802.1Q): 1-4095

Reserved:
- 1: Default native VLAN.
- 1002: FDDI default (Cisco).
- 1003: Token ring default (Cisco).
- 1004: FDDI-Net (Cisco).
- 1005: TRNET (Cisco).
- 4095: Implementation use.

## Spanning Tree Protocol (STP)

### Variants

| Names | Supporting Devices\* | Description |
| :--- | :--- | :--- |
| 802.1D, STP | Cisco IOS, Linksys LGS | Single instance, slow |
| PVST/PVST+ | Cisco IOS | Like STP, one instance per VLAN |
| VSTP | Juniper | Compatible with Cisco's PVST |
| 802.1w, RSTP | Brocade ICX, Linksys LGS | Single instance, fast, backwards-compatible with STP. |
| Rapid-PVST+ | Cisco IOS | Like PVST+ but based on RSTP |
| VSTP | Juniper | Based on RSTP, compatible with STP and Cisco's PVST |
| 802.1s, MSTP, MST | Cisco IOS | Multiple instances with configurable VLAN members |
| 802.1Q |  | ??? |

(\*) Very incomplete list.

### General

- Use extended system ID for multi-VLAN switches.
- Make sure all switches are using compatible variants and default priorities.
- Make sure all VLANs are running STP or that STP is running globally (not per VLAN).
- STP (excluding per-VLAN STP and generally not MST) (including rapid versions) will consider multiple links between switches a loop, even when the links carry different VLANs.
- The bridge priority should generally be a multiple of 4096.
- PVST and 802.1Q regions cannot interoperate directly, but can through PVST+ regions.

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

### Miscellanea

#### Cisco IOS

- VTP can be very dangerous if not used properly and is enabled by default. It also doesn't carry MST configuration.
- Rapid-PVST+ ignores UplinkFast and BackboneFast and supports UDLD.

{% include footer.md %}
