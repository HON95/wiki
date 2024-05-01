---
title: Cisco Nexus Switches (NX-OS)
breadcrumbs:
- title: Networking
---
{% include header.md %}

*I keep most of my Cisco notes elsewhere, sorry.*

## Features

### Virtual Port-Channel (vPC)

- For supporting MEC on a pair of switches, without providing stacking.
- Supported by certain Nexus switches.
- The physical switches remain logically separate, but requires somewhat matching configurations (especially regarding MEC ports).
- Uses conventional network ports.
- Architecture:
    - A *vPC domain* consists of a *pair* of switches. A switch can only be in a single domain.
    - A domain must have a unique domain ID, to avoid accidental peer link peerings or LACP associations caused by cabling or configuration errors.
    - A pair consists of a primary and standby switch, connected with a *keep-alive* link and a high-speed *peer* link.
        - The keep-alive link is a separate link with a dedicated VRF to isolate it from user traffic and reduce the possibility of a split-brain scenario. It may use normal ports (single or LAG), the management interface (which already uses its own VRF) or some OOB L3 network.
        - The peer link forms a backplane for sharing state and vPC forwarding traffic. It may be of a port channel consisting of multiple physical links for redundancy.
    - Important L2 state information such as MAC address tables are shared within the domain.
    - *Member ports* are ports using vPC, i.e. for servers connected to both peers. VLANs on these ports must also be allowed on the peer link. *Orphan ports* are ports not using vPC.
- Loop avoidance rule:
    - To prevent duplicate packets, packets received on the peer link destined to a member port will be dropped.
    - Packets destined to orphan ports will is not affected and allowed.
    - If a member port in a vPC on one peer goes down, the member port on the other peer will no longer count as a member port wrt. the loop avoidance rule and traffic from another port will be allowed through the peer link and the remaining member port.
- Protocols:
    - The peers are running dual-active FHRP by default, such that both peers may directly route packets.
    - The LACP systemd ID is based on the domain ID, to make sure it's the same for both peers. The LACP system priority must also match.
    - STP state is shared. By default, only the primary transmits BPDUs. The `peer-switch` vPC domain option may be used to share the virtual bridge ID and send BPDUs from both peers.
- Failure scenarios:
    - If the physical vPC link to one of the peers fails, the other link will handle all traffic (loop avoidance rule no longer applies).
    - If a peer fails, all member traffic will be handled by the other peer. All orphan links on the failed peer will go down. The remaining peer will become the new primary. If the failed peer comes back online, it will become the secondary.
    - If the peer link fails, all member ports of the secondary peer will be suspended and the other peer will handle all member traffic. Orphan ports are kept up. If then the primary fails, the standby takes over as primary and opens the suspended member ports.
    - If the keep-alive link fails, nothing will happen if roles are already decided and no further failures happen. Peers can sense that the peer link is up, such that forwarding can continue to happen. If then the peer link fails (_after_ the keep-alive link), a split brain scenario will happen where both switches become primaries.
    - If both peer link and keep-alive link fail at the same time but both peers are still up, a split-brain scenario will form. This might cause loops and other problems and must be avoided, so make sure to have proper redundancy for the peer and keep-alive links.
- VXLAN considerations:
    - Both peers must have a separate loopback interface with one primary, unique address and one secondary, shared address. The unique addresses are used for the VXLAN VTEPs. The shared address allows both peers to act as the gateway for the member device, as well as allowing ECMP for the upstream network. This interface will go down if the peer link goes down, together with member ports, to prevent member traffic from being routed through it and to make the VXLAN VTEP go down.
    - The peers should have a routed VLAN on the peer link, for local L3 communication. PIM might be required for this SVI. Use `system nve infra-vlans <VID>` (global) to inform VXLAN that this VLAN is local. This allows L3 traffic to pass between peers in case one of the peers has failed uplinks. The L3 peer linknet must be announced into the routing protocol.
    `peer-gateway` (domain) must be used.
    - The upstream network might work as a substitute for the dedicated keep-alive link.
- VDC considerations:
    - (Only?) one vPC domain per VDC is supported.
    - vPC domains stretching across VDCs is not supported.
- Additional recommendations:
    - Use vPC downlinks only for non-routed devices and where L2 connectivity is required. For routers/firewalls on the other side, use normal L3 links instead, optionally with ECMP.
    - Keep-alive link cabling options (best to worst):
        1. Dedicated 2x 1G links (EtherChannel).
        1. Dedicated 1x 1G link.
        1. Over management interfaces.
        1. Over non-management infrastructure (routed).
        1. (DO NOT) Over peer link (more likely to cause split-brain).
    - Peer link cabling options (best to worst):
        1. 2x 10G/40G/100G links (EtherChannel).
        1. 1x 10G/... link.
    - Give the keep-alive link a dedicated VRF, e.g. "PKL-VRF", if possible.
    - Add a linknet/L3 VLAN on the peer link for local L3 communication. Alternatively, add a dedicated routed link.
    - Always use `peer-switch`.
    - Always use `peer-gateway`. **TODO** See note about `layer3 peer-router`, maybe not use this if not required.
    - Always use `ip arp synchronize` and `ipv6 nd synchronize`.
    - Always use `auto-recovery` and `auto-recovery reload-delay`.
    - If using a chassis and the peer link is connected to only one line card, consider using object tracking to suspend vPC if tracked interfaces (on the line card) go down.

#### Configuration

- Main configuration:
    - `feature vpc` (global) enables vPC. `feature lacp` is also required.
    - `vpc domain <domain-id>` (global) places the peer into the specified domain.
    - `role priority <pri>` (domain) sets the primary priority for the local peer (0 is highest).
    - `peer-keepalive destination <dst-ip> source <src-ip> vrf <vrf>` configures the keep-alive link for some interface with the given linknet IP address within the given VRF.
    - `vpc peer link` (interface) configures the peer link for the current interface (e.g. a trunk LAG).
    - `auto-recovery` (domain) allows the secondary peer to become primary after the peer link and then the and keep-alive link has gone down (e.g. if the previous primary has gone down, in that degredation order).
    - `auto-recovery reload-delay <60-3600>` (domain) allows any peer to become primary of the keep-alive link does not come up after a delay (e.g. when booting both devices).
    - `peer-switch` (domain) should be used to share the STP virtual bridge ID and send BPDUs from both peers. This should only be used if the peers together are the roots of all VLAN STP trees.
    - `peer-gateway` (domain) may be used to allow one peer to forward packets on behalf of the other peer, in cases where the destination MAC address of a packet targets one peer but the packet is actually received on the other peer (e.g. caused by a bad host implementation). This avoids connectivity issues caused by packets arriving at the wrong peer and the loop avoidance causing them to be dropped by the other peer (when transferred over the peer link). If the peers are meant to participate in routing protocol adjacencies, then `layer3 peer-router` must be enabled immediately afterwards to avoid flapping.
    - `layer3 peer-router` (domain) may be used to enable routing protocol adjacencies over vPCs with both peers. On a technical level, this allows forwarding routing packets with a TTL of 1 across the peer link without decrementing it. PIM adjacencies are not supported while using this. Requires `peer-gateway` to be active. `no layer3 peer-router syslog` (domain) may be set to prevent certain pointless `VPC-2-L3_VPC_UNEQUAL_WEIGHT` syslog messages.
    - `ip arp synchronize` and `ipv6 nd synchronize` (domain) enable ARP and ND synchronization, to reduce convergence times after faults.
- Member port configuration:
    - `vpc <n>` (pc-interface) configures the port-cannel as a member. It must use the same vPC number on both peers. The port-channel ID may be used as the vPC ID for consistency. The port must be configured as switchport.
- Orphan port configuration:
    - `vpc orphan-ports suspend` (interface) brings down the orphan port if the peer link goes down, similar to member ports. Useful e.g. for devices with active-passive uplinks to both peers.
- Operation:
    - `show vpc brief` shows useful info, including status for the keep-alive link, the peer link and the vPC links.

### Virtual Device Contexts (VDC)

- For splitting a single physical switch into multiple logical switches.
- Supported by certain Nexus switches.
- If logged into the VDC physical device, the `switchto vdc <name>` command is used to enter a logical device and `switchback` is used to go back to the physical device. Additionally, the virtual devices are directly available through SSH just like physical devices.

{% include footer.md %}
