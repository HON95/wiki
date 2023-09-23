---
title: Cisco Software-Defined Access (SDA)
breadcrumbs:
- title: Network
---
{% include header.md %}

## General

- A full zero-trust network solution for campus/enterprise networks (not DC), part of Cisco DNA (often called DNA/SDA).
- Relation to Cisco Application Centric Infrastructure (ACI): [Cisco ACI: Relation to SDA](../cisco-aci/#relation-to-sda)

## Links

- [Cisco: Cisco SD-Access Solution Design Guide (CVD)](https://www.cisco.com/c/en/us/td/docs/solutions/CVD/Campus/cisco-sda-design-guide.html)
- [Cisco: Cisco SD-Access Multicast](https://community.cisco.com/t5/networking-knowledge-base/cisco-sd-access-multicast/ta-p/4068110)

## Useful Commands

### Wireless

- Show AP tunnels for edge: `show access-tunnel summary`

## Theory

- SDA consists of Cisco DNA Center (DNAC) and a campus fabric of DNAC-managed switches. Cisco ISE is also used for policy design and operation.
- Segmentation:
    - Virtual networks (VNs) (using VRFs) are used for macro-segmentation and secure/scalable group tags (SGTs) (using VXLAN tagging) are used for micro-segmentation.
    - SGACLs are used to control traffic flows between SGTs. By default, all SGTs within a VN are allowed to communicate with eachother.
    - Traffic flows between VNs, as well as to/from external services, should go through a firewall appliance for greater visibility and control. Alternatively, a core *fusion router* may be used to leak select traffic between VNs and to/from external services.
- Underlay:
    - Mainly Catalyst 9000 series switches running standard IOS-XE, managed by DNAC.
    - Catalyst WLCs and APs are integrated for wireless access, with direct traffic handoff from APs to switches for unified wired and wireless access.
    - Fully routed, using IS-IS routing and PaGP port channels.
    - Only fully supports IPv4, IPv6 support is still lacking.
    - StackWise or StackWise Virtual (SVL) may be used in some appropriate cases, mainly to facilitate multichassis EtherChannel.
- Overlay:
    - Planes:
        - Control plane: Uses LISP for locating client MAC and IPv4/IPv6 addresses, with control nodes as LISP map servers.
        - Data plane: Uses VXLAN for tunneling overlay traffic between fabric nodes.
        - Policy plane: Uses Cisco TrustSec (CTS) for policy decisions, like SGTs and SGACLs (using Cisco ISE).
    - Supports IPv4-only, dual-stack and (partially?) IPv6-only.
    - Anycast gateways are used at all edge nodes for all VNs.
- Sites:
    - The fabric domain is divided into one or more fabric sites.
    - Each site has internal and/or external border nodes to allow traffic to other sites (internal) or to external domains.
    - Each site must have one or more control plane nodes, which hosts the LISP map server (control plane). The control plane nodes are typically colocated on the same device as internal borders.
    - Edge nodes are the switches that clients connect to.
    - Extended nodes (EN) and policy extended nodes (PEN) are switches that connect to edges to extend their reach and port capacity.
    - Access points connect to edges or extended nodes, with CAPWAP tunnels to the site's WLC(s) and optionally traffic tunneled directly to the connected edge.
    - Wireless controllers (WLCs) are connected "outside" the fabric, e.g. in a central DC or connected to TCNs.
    - Intermediate nodes may be used in the underlay between borders and edges to allow for more physical flexibility.
    - "Fabric in a box" is special site design where all functions (border, control plane, edge, maybe WLC) is colocated on one device containing the whole site.
- Transits (between sites):
    - SDA transit:
        - Requires the transit intrastructure to be part of the fabric domain.
        - Uses inline tagging, where SGTs are preserved in the packets when transiting between sites.
    - IP transit:
        - Allows using external, non-SDA infrastructure between sites, e.g. for WAN circuits between sites.
        - Requires use of the SGT Exchange Protocol (SXP) to reapply SGTs to packets after transiting.
    - For LISP location data across sites, a transit control node (TCN) is required. The TCN is queried by control plane nodes when a resource is not found within the site.
- Multicast:
    - For IPv4, it supports head-end replication and native multicast.
    - For IPv6, it only supports head-end replication. (TODO: Does enabling native multicast for a site kill IPv6 multicast or will it continue to use head-end replication?)
    - *Head-end replication* runs completely in the overlay and makes edge devices duplicate multicast streams into unicast streams to each edge device with subscribers. This causes increased overhead.
    - *Native multicast* tunnels multicast streams inside underlay multicast packets and avoids head-end replication.
    - Supports sources both inside and outside the fabric.
    - Protocol Independent Multicast (PIM) with both any-source multicast (ASM) and any-source multicast (ASM) is supported in both the underlay and overlay.
    - For details around rendezvous points (RPs) and stuff, see the design guide.
- Layer 2 flooding:
    - Traffic that is normally flooded in traditionally networks, like ARP, is often handled differently and more efficiently in overlay technologies like SDA.
    - Certain applications and protocols requires layer 2 flooding to work. To address this, *layer 2 flooding* may be enabled for a VN/site (if really needed).
    - Examples of applications/protocols/devices requiring layer 2 flooding:
        - Dumb clients requiring broadcast ARP to wake up.
        - Local Wake-on-LAN (WoL).
        - Certain building management systems.
        - ???
    - This will reduce scalability of the VN/site, so it should only be used for /24 subnets and smaller.
    - The L2 flooding is mapped to a dedicated multicast group in the underlay, using PIM-ASM. All edge nodes active for the VN must listen to this group.
- ARP:
    - When a client sends an ARP request, the edge looks up the RLOC/address for the edge the target resides at and then the ARP is unicasted to that edge.
- DHCP relays:
    - Edge nodes function as DHCP relays for all their active VLANs.
    - The anycast gateway address is used as source/giaddr withing the overlay.
    - Option 82 is used to identify the specific edge switch and port.
    - For the reply to reach the correct edge switch (as the anycast gateway may be active on multiple edges), the site border uses the option 82 value to find the correct edge node.
- mDNS and Bonjour:
    - **TODO**
    - https://www.cisco.com/c/en/us/solutions/collateral/enterprise-networks/sd-access-wired-wireless-dg.html
    - https://www.cisco.com/c/en/us/td/docs/cloud-systems-management/network-automation-and-management/dna-center/1-3-1-0/user_guide/cisco_dna_service_for_bonjour/b_cisco-dna-service-for-bonjour_user_guide_2-1-2/m_deploying-wide-area-bonjour-for-cisco-sd-access-network.html

### Locator ID Separation Protocol (LISP)

- LISP is used for overlay routing in SDA, mapping overlay host overlay addresses (*endpoint identifiers* (EIDs) or informally "IDs") to underlay edge addresses (*record locator* (RLOC) or informally "locations").
- LISP is also an encapsulation protocol, however, SDA uses VXLAN instead for that purpose.
- The *control plane node* within a site is one or more nodes running a LISP mapping server, which the other site fabric nodes update and query. It may e.g. be colocated with the border node(s).
- It uses on-demand mapping for when a node needs to know where an ID is located, which works well for roaming hosts while keeping routing tables just as big as needed.

### Virtual Extensible LAN (VXLAN)

- VXLAN is used as the overlay encapsulation method in SDA, with LISP as the control plane.
- A VXLAN extension called *Group Policy Option* (VXLAN-GPO) is used to carry the SGT within the VXLAN header, thus allowing inline VN and SGT tagging of all traffic within the fabric.

{% include footer.md %}
