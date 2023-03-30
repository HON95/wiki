---
title: Cisco General
breadcrumbs:
- title: Network
---
{% include header.md %}

General Cisco networking equipment stuff.

## Resources

- [Cisco Config Analysis Tool (CCAT)](https://github.com/cisco-config-analysis-tool/ccat)

## Technologies

### Multi-chassis EtherChannel (MEC)

- Like MC-LAG/MLAG in non-Cisco terminology.
- Allows connecting EtherChannels (LACP/PAgP) to a logical unit consisting of multiple physical units, such that the physical EtherChannel links go to multiple physical units.
- Provides redundancy in case one of the physical units of the logical unit dies.
- Requires that the physical units are configured partially or fully as a logical device, e.g. using StackWise, VSS or vPC.
- The simpler L2 alternative would be separate EtherChannels and STP to make sure only one is active at the time.

### StackWise

- For switch stacking, creating a single, logical switch.
- Supported by certain Catalyst switches.
- Uses special ports and proprietary cables.

### Virtual Switching System (VSS)

- Also called *Stackwise Virtual* as it is an evolution of StackWise.
- Supported by certain Catalyst switches.
- Uses conventional network ports.

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
    - Packets destined to orphan ports will however be allowed.
- Protocols:
    - The peers are running dual-active FHRP by default, such that both peers may directly route packets.
    - The LACP systemd ID is based on the domain ID, to make sure it's the same for both peers. The LACP system priority must also match.
    - STP state is shared. By default, only the primary transmits BPDUs. The `peer-switch` vPC domain option may be used to share the virtual bridge ID and send BPDUs from both peers.
- Failure scenarios:
    - If the physical vPC link to one of the peers fails, the other link will handle all traffic (**TODO**: it becomes an orphan?).
    - If a peer fails, all member traffic will be handled by the other peer. All orphan links on the failed peer will go down. The remaining peer will be the new peimary. If the failed peer comes back online, it will become the secondary.
    - If the peer link fails, all member ports of the secondary peer will be suspended and the other peer will handle all member traffic. Orphan ports are kept up. If then the primary fails, the standby takes over as primary and opens the suspended member ports.
    - If the keep-alive link fails, nothing will happen if roles are already decided and no further failures happen. Peers can sense that the peer link is up, such that forwarding can continue to happen. If then the peer link fails (_after_ the keep-alive link), a split brain scenario will happen where both switches become primaries.
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

## Protocols

### Port Aggregation Protocol (PAgP)

- Cisco-proprietary protocol for link aggregation.
- Use LACP instead.

### Link Aggregation Control Protocol (LACP)

- An IEEE protocol (aka 802.3ad) for link aggregation.
- LACPDU packets are used to transmit control information. Often this can be configured as slow (30s) or fast (1s), where fast is recommended for faster fault detection.
- The hash policy is used to determine which physical link to send packets on, e.g. by hashing layer 2 (MAC) and layer 3 (IP) addresses.
- A unique system ID is used by each device to make sure all links are connected to the same device on the other end.

### UniDirectional Link Detection (UDLD)

- A Cisco-proprietary protocol for detecting unidirectional links.
- Disabled by default.
- This can happen when one fiber strand has been damaged but the other one works, which would make it hard to know that the link is down and it could cause STP loops.
- It's mostly used for fiber ports, but can also be used for copper ports.
- Use aggressive mode to err-disable the port when it stops receiving periodic UDLD messages.
- A partial alternative is to use single member LACP.
- Configuration:
    - Set message interval: `udld message time <seconds>`
    - Enable in normal og aggressive mode globally on all fiber ports: `udld <enable|aggressive>`
    - Enable per-interface: `udld port <enable|aggressive>`

### Cisco Discovery Protocol (CDP)

- A Cisco-proprietary protocol for interchanging device information to neighbor devices.
- Use LLDP instead.
- Disable globally: `no cdp run`

### Link Layer Discovery Protocol (LLDP)

- An IEEE protocol (defined in IEEE 802.1AB) for interchanging device information to neighbor devices.
- **TODO** LLDP and LLDP-MED

## Other Features

### ACL Based Forwarding (ABF)

- Supported by ASR9000 (certain line cards) (Cisco IOS XR).
- Basically policy-based ruting (PBR), implemented using ACLs.
- Supports ingress ACLs only.
- Nexthops:
    - Up to 3 alternative nexthops can be specified for a rule using the `nexthop<n> [vrf <vrf>] [{ipv4|ipv6} <nexthop-ip>]` clause.
    - If multiple nexthops are specified then the first one with an up interface with a connected subnet will be used.
    - If none of the nexthops are "up" then the normal default route is used instead.
    - If the `default` clause is specified then the nexthops will only be used in place of a default route and not if any specific routes in the routing table match.
- VRFs:
    - Egress VRFs can be specified as part of the nexthop clause.
    - If no IP address is specified for the nexthop then the routing table of the VRF is used.
    - If no VRF is specified for a nexthop clause then the default VRF is used.
- If traffic should be dropped if the first next hops are down, then create a `DROP_VRF` VRF with a null default route and use that as the last nexthop.
- **TODO** If all nexthops are down, does ut use the normal routing table or specifically the normal default route? Something about null route not working mentioned.
- An example usage for ABFs is to route RFC 1918 networks heading through a GW toward the Internet into a NAT VRF or separate NAT router.
- Examples:
    - Some rule: `10 permit ipv4 any 100.100.100.0/24 nexthop1 VRF RED ipv4 1.1.1.1 nexthop2 VRF BLUE ipv4 2.2.2.2 nexthop3 ipv4 3.3.3.3`
    - Show that the ABF id programmed correctly in HW: `show access-lists ipv4 abf-1 hardware ingress location 0/1/cpu0`

## Miscellanea

### Version and Image String Notations

- Version 12 notation (e.g. `12.4(24a)T1`):
    - Major release (`12`).
    - Minor release (`4`).
    - Maintenance number (`24`).
    - Rebuild number (alt. 1) (`a`).
    - Train identifier (`T`).
    - Rebuild number (alt. 2) (`1`).
- Version 15 notation (e.g. `15.0(1)M1`):
    - Major release (`15`).
    - Minor release (`0`).
    - Feature release (`1`).
    - Release type (`M`).
    - Rebuild number (`1`).
- If it has `K9` in the image name, it has cryptographic features included. Some images don't because of US export laws.

{% include footer.md %}
