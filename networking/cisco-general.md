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
    - A domain must have a unique domain ID, to avoid accidental peerings caused by cabling or configuration errors.
    - A pair consists of a primary and standby switch, connected with a *keep-alive* link and a high-speed *peer* link.
        - The keep-alive link is a separate link with a dedicated VRF to isolate it from user traffic and reduce the possibility of a split-brain scenario. It may use the management interface, which already uses its own VRF.
        - The peer link forms a backplane for sharing state and vPC forwarding traffic. It may be of a port channel consisting of multiple physical links for redundancy.
    - Important L2 state information such as MAC address tables are shared within the domain.
    - *Member ports* are ports using vPC, i.e. for servers connected to both peers. VLANs on these ports must also be allowed on the peer link. *Orphan ports* are ports not using vPC.
- Loop avoidance:
    - To prevent duplicate packets, packets received on the peer link destined to a member port will be dropped. Packets destined to orphan ports will however be allowed.
- Protocols:
    - The peers are running dual-active FHRP by default, such that both peers may directly route packets.
    - The LACP systemd ID is based on the domain ID, to make sure it's the same for both peers. The LACP system priority must also match.
    - STP state is shared. By default, only the primary transmits BPDUs. The `peer-switch` vPC domain option may be used to share the virtual bridge ID and send BPDUs from both peers.
- Failure scenarios:
    - If the physical vPC link to one of the peers fails, the other link will handle all traffic (**TODO**: it becomes an orphan?).
    - If a peer fails, all member traffic will be handled by the other peer. All orphan links on the failed peer will go down. The remaining peer will be the new peimary. If the failed peer comes back online, it will become the secondary.
    - If the peer link fails, all member ports of the secondary peer will be suspended and the other peer will handle all member traffic. Orphan ports are kept up. If then the primary fails, the standby takes over as primary and opens the suspended member ports.
    - If the keep-alive link fails, nothing will happen if roles are already decided and no further failures happen. Peers can sense that the peer link is up, such that forwarding can continue to happen. If then the peer link fails (_after_ the keep-alive link), a split brain scenario will happen where both switches become primaries.
- Main configuration:
    - `feature vpc` (global) enables vPC. `feature lacp` is also required.
    - `vpc domain <domain-id>` (global) places the peer into the specified domain.
    - `role priority <pri>` (domain) sets the primary priority for the local peer (0 is highest).
    - `peer-keepalive destination <dst-ip> source <src-ip> vrf <vrf>` configures the keep-alive link for some interface with the given linknet IP address within the given VRF.
    - `vpc peer-link` (interface) configures the peer link for the current interface (e.g. a trunk LAG).
    - `peer-switch` (domain) may be used to share the STP virtual bridge ID and send BPDUs from both peers. This should only be used if the peers together are the roots of all VLAN STP trees.
    - `peer-gateway` (domain) may be used to allow one peer to forward packets on behalf of the other peer, in cases where the destination MAC address of a packet targets one peer but the packet is actually received on the other peer (e.g. caused by a bad host implementation). This avoids connectivity issues caused by packets arriving at the wrong peer and the loop avoidance causing them to be dropped by the other peer (when transferred over the peer link). If the peers are meant to participate in routing protocol adjacencies, then `layer3 peer-router` must be enabled immediately afterwards to avoid flapping.
    - `layer3 peer-router ` (domain) may be used to enable routing protocol adjacencies over vPCs with both peers. On a technical level, this allows forwarding routing packets with a TTL of 1 across the peer link without decrementing it. PIM adjacencies are not supported while using this. Requires `peer-gateway` to be active. `no layer3 peer-router syslog` (domain) may be set to prevent certain pointless `VPC-2-L3_VPC_UNEQUAL_WEIGHT` syslog messages.
    - `ip arp synchronize` (domain) enables ARP synchronization, to reduce convergence times after faults.
- Member port configuration:
    - `vpc <n>` (interface) configures the port-cannel as a member. It must use the same vPC number on both peers. The port-channel ID may be used as the vPC ID for consistency.
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
