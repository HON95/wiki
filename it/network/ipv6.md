---
title: IPv6 Theory
breadcrumbs:
- title: IT
- title: Network
---
{% include header.md %}

## Advantages over IPv4

- Designed based on experience with the strengths and limitations of IPv4 and other protocols.
- IPv4 is becoming obsolete.
    - An investment in IPv4-only is an investment in EOL technology.
    - Certain services may only be available over IPv6 in the future.
    - IPv4 will be provided as a service in the future, making it less performant than native IPv6.
    - Since you'll need it some day, it's better to get familiar with it early.
    - While still needed for the full internet, internal networks may be IPv6-only.
- Larger address space.
    - Simpler and more structured address plans.
    - All subnets are /64 regardless of the number of hosts/interfaces.
    - Extra information can be embedded in the address.
- No need for NAT.
    - Restores end-to-end princible.
    - Better peer-to-peer support.
- Simpler design and operation.
- Improved protocols like ICMPv6, NDP, MLD and DHCPv6.
    - New features.
    - Security features.
- Native support for IPsec.
- Stateless address autoconfiguration (SLAAC) reduces administrative overhead for simple networks.
- Improved QoS.
- Improved multicast.
- Removed broadcast.
- Interfaces can have multiple addresses.
    - Link-local address.
    - Addresses from multiple prefixes from different routers.
    - Internal addresses in addition to global addresses.
- More efficient routing due to better address aggregation.
- More efficient packet processing:
    - No fragmentation in routers.
    - Streamlined fixed-length header with extension headers.
    - No checksum.

## Addressing

- 128 bit addresses.
- No broadcast.
- Anycast.
    - Shared unicast address.
    - Subnet-router anycast address.
- Multicast:
    - Some scopes:
        - 1: Interface-local.
        - 2: Link-local.
        - 5: Site-local.
        - E: Global.
    - Some well-known addresses:
        - `ff02::1`: All nodes.
        - `ff02::2`: All routers.
        - `ff02:6a`: All snoopers.
        - `ff02::1:ff00/24`: Solicited node.
- Solicited-node multicast address.
    - Solicited-node prefix plus last 64 bits of an IPv6 address.
- Interface addresses:
    - Addresses are assigned to interfaces, not hosts.
    - Interfaces may have multiple addresses.
    - All interfaces have a link-scoped address.
- Permanent and temporary address types.
- Address assignment:
    - Static.
    - Stateless address autoconfiguration (SLAAC).
    - Stateless DHCP.
    - Stateful DHCP.
- SLAAC interface addresses:
    - EUI-64 (permanent): Deterministically based on the MAC address.
    - Privacy extensions (temporary): In addition to the permanent. Preferred for sending.
- The unspecified address: `::`
- The loopback address: `::1`
- The first and last addresses in a subnet are not reserved and can be assigned to hosts, unlike IPv4.
- Neighbor cache.
    - States:
        - Incomplete.
        - Reachable.
        - Stale.
        - Delay.
        - Probe.
- Destination cache.
- Address states:
    - Tenative: Waits for DAD to finish.
    - Preferred: Can be used.
    - Deprecated: About to expire. Can be used for existing connections but not new ones.
    - Valid: Preferred or deprecated.
    - Invalid: Expired valid.
    - Optimistic: Like tenative but for Optimistic DAD. Can be used.

## Address Ranges

|Prefix|Description|
|-|-|
|`::/32`|IPv4-compatible IPv6 address (deprecated)|
|`::ffff/32`|IPv4-mapped IPv6 address|
|`100::/64`|Discard-only|
|`64:ff9b::/96`|IPv4-IPv6 translation|
|`2000::/3`|Global unicast address (GUA)|
|`2001::/32`|Teredo|
|`2001:db8::/32`|Documentation (non-routable)|
|`2002::/16`|6to4|
|`fc00::/7`|Unique local address (ULA)|
|`fd00::/8`|Locally administered ULA|
|`fe80::/10`|Link-scoped unicast|
|`ff00::/8`|Multicast|

## Packet and Transit

- Streamlined header.
    - 40 bytes base.
- Extension headers:
    - Hop-by-hop options header.
    - Routing header.
    - Fragment header.
    - Destination options header.
    - Authentication header.
    - Encapsulating security payload header.
- No checksum.
- Fragmentation.
    - Routers don't fragment.
    - Path MTU discovery.
    - Not allowed for some NDP messages.
    - The first fragment must contain all headers.

## Protocols

### Neighbor Discovery (ND)

- Uses ICMPv6.
- Link-layer address resolution.
- Neighbor unreachability detection (NUD).
- Duplicate IP address detection (DAD).
    - Determines if the address is unique before it can be used.
    - Opportunistic DAD allows using the address before DAD finishes.
- Redirect.
- Router advertisements.
    - SLAAC.
- Neighbor advertisements.
- Uses a hop limit of 255 and received request with lower hop limits are ignored.
- Suggests using IPsec for ND messages.
- Identification of ND messages:
    - All-zero to all-routers: SLAAC.
    - All-zero to solicited-node: DAD.
    - Unicast to solicited-node: Link-layer address resolution.
    - Unicast to unicast: Unreachability detection.
- Inverse neighbor discovery (IND).
- Secure neighbor discovery (SEND):
    - Router authentication.
    - Cryptographically generated address (CGA).
    - Some security options.
- NDP is vulnerable to the same attacks as for ARP and DHCP.
    - First hop security mechanisms for NDP include ICMP guard.
    - IPsec and SEND may also prevent certain attacks.

### Multicast Listener Discovery (MLD)

- Uses ICMPv6.
- For registration of multicast listeners within a subnet.
- Handled by IGMP in IPv4.
- Version 1:
    - Based on IGMPv2.
    - Any-source multicast (ASM).
- Version 2:
    - Based on IGMPv3.
    - Source-specific multicast (SSM).
- PIM can be used for routing.
- MLD snooping can be used by switches.
- Multicast router discovery (MRD):
    - Based on MLD.
    - For discovery of multicast routers.

### Dynamic Host Configuration Protocol for IPv6 (DHCPv6)

- Relies on routing advertisements.
- Stateless or stateful.
- Reconfiguration message send by server to indicate changes (lacking in DHCPv4).
- DHCP Unique Identifier (DUID).
- Identity Association (IA).
    - One per interface.
    - Contains IPv6 addresses plus timers.
- Clients must perform DAD after being allocated an address by the server.
- Rapid commit option (only two messages).
- Renew and rebind.
- Prefix delegation with prefix exclusion.
- IPsec can be used.
- E.g. Android currently does not support DHCPv6, only SLAAC.
    - To help with traceability, Netflow or periodic NDP cache scans with SNMP can be used.

### Domain Name System (DNS)

- A6 and AAAA type records.
- Dual stack hosts need two entries.
- IP6.ARPA. Originally IP6.INT.
- Dual stack clients query for both a A and an AAAA record for each domain name to resolve.
- The transport used is independent of the record type being queried for.
- Native IPv6 is generally preferred over IPv4.
- DNS whitelisting: Only respond with AAAA records to ISPs with good IPv6 performance.
- Happy eyeballs:
    - Clients will attempt to connect using both IPv4 and IPv6 and use the faster one.
    - IPv6 is preferred.
    - Different implementations exist.
- Name space fragmentation:
    - Every name server from the root (for a certain domain name) must be accessable by the resolver.
    - IPv4 should always be supported.

### Routing Protocols Summary

- Using one shared instance VS two instances (ships in the night).
- RIPng:
    - Limited diameter.
    - Long routing loop convergence (count to infinity).
    - Too simple metric.
- OSPFv3:
    - Only for IPv6, IPv4 must still use OSPFv2.
    - Differences from OSPFv2:
        - Routes to links, not subnets.
        - Uses link-local addresses for neighbors.
        - Multiple instances per link.
        - Removal of addressing semantics. IPv6 addresses are not present in OSPF headers.
        - Flooding scope.
        - Authentication.
- IS-IS:
    - Single instance for both IPv4 and IPv6.
- EIGRP.
- BGP-4:
    - Uses implicit support for protocols other than IPv4 (multiprotocol NLRI).
    - BGP-4 routers still require (local) IPv4 addresses because of the BGP identifier.

## Transition Technologies

- Dual-stack:
    - The best option for clients.
    - Requires running two separate protocol stacks, which may be extra operationally expensive.
- Tunneling:
    - Should use source address verification and ingress filtering.
    - May bypass firewalls.
    - Manual or automatic.
    - Loopback encapsulation and routing-loop nested encapsulation. Partially avoided using the encapsulation limit option.
- Translation:
    - Stateless or stateful.
    - May use the well-known prefix `64:ff9b::/96`.
    - May need to (re)calculate checksums both at multiple layers.
    - Differing features (e.g. fragmentation and extension headers) may break.
    - While NAT44 is required in IPv4 to counteract address depletion, NAT66 is not recommended for IPv6.

### Tunneling Mechanisms

- 6to4:
    - Deprecated.
    - Only 6to4 routers/gateways need to be 6to4 aware.
- IPv6 Rapid Deployment (6rd):
    - Widely used.
    - Based on 6to4.
    - Uses the ISPs own IPv6 range for customers.
    - Stateless.
    - Changing the customer IPv4 address also changes the IPv6 prefix.
- Intra-Site AUtomatic Tunnel Adressing Protocol (ISATAP):
    - Must be supported by all nodes in the network.
- Teredo:
    - May traverse NAT.
    - Vulnerable if not configured properly.
    - Should generally be avoided.
    - May be enabled by default on some OSes. Disable it if not explicitly needed.
- Tunnel brokers:
    - E.g. Hurricane Electrics and SixXS.
    - Requires a public IPv4 address.
- MPLS.
- Locator ID Separation Protocol (LISP):
    - General architecture not purely designed for IPv6 support.
    - Separates IP addresses into two namespaces: Endpoint identifiers (EIDs) and routing locators (RLOCs).
- Generic Routing Encapsulation (GRE):
    - Manual.
    - Can't traverse NAT.
- Proto 41 forwarding:
    - Allows nodes behind NAT to connect to tunnel servers on the internet.
- SSH.

### Tanslation Mechanisms

- NAT44 (IPv4 only).
- Carrier grade NAT (CGN) aka NAT444 (IPv4 only).
- NAT464:
    - IPv6-only between the customer edge and the privider network.
    - Uses NAT46 and NAT64 at the two sides.
- DS-lite:
    - IPv6-only between customer edge and CGN.
    - IPv4 traffic is tunneled, not translated.
    - Uses a DS-Lite basic bridging broadband element (B4) within or directly connected to the CPE.
    - Uses a DS-Lite address family translation router (AFTR) within the provider network.
    - The B4 creates a tunnel to the AFTR.
    - The AFTR also functions as a NAT44.
    - There is a DHCPv6 option for DS-Lite.
    - Uses the range `192.0.0.0/29`, where `192.0.0.1` is used by the AFTR and `192.0.0.2` is used by the B4.
- Stateless NAT64:
    - Appropriate for IPv4-only servers so they can be reached by IPv6 clients.
    - Uses prefix `64:ff9b::/96` or a custom prefix.
    - 1:1 mapping between IPv4 and IPv6 addresses.
    - Sessions can be initiated from both sides.
- Stateful NAT64 and DNS64:
    - Appropriate for IPv6-only edge networks to connect to the IPv4 internet.
    - Uses prefix `64:ff9b::/96` or a custom prefix.
    - 1:N mapping between IPv4 and IPv6 addresses.
    - Sessions can generally only be initiated from the IPv6 side.
    - No changes are required in the IPv6 client in order to support it.
    - If the DNS64 server does not find an AAAA record, it synthesizes a AAAA record within the NAT64 prefix.
    - Limitations:
        - All clients must be configured to use the the DNS64 server (e.g. through DHCP).
        - Synthesized AAAA records break DNSSEC.
        - Connections can't be initiated from the IPv4 side (like NAT masquerading).
        - Some applications don't support IPv6 or may have IPv4 literals hardcoded.
        - Users may attempt to enter IPv4 literals instead of using the DNS64 server.
- XLAT464:
    - Uses stateful translation in the core and statekess translaton at the edge.
    - Uses a customer-side translator (CLAT) which translated between 1:1 private IPv4 addresses and global IPv6 addresses.
    - Uses a provider-side translator (PLAT) which translates between N:1 global IPv6 addresses and global IPv4 addresses.
    - The NAT64 prefix can be aquired by querying the configured DNS server for `ipv4only.arpa`.
    - It does not support inbound IPv4 connections or peer-to-peer.
    - Implemented in Android.
- MAP.
- NPTv6 (IPv6 only):
    - Statelessly translated between two equal-length IPv6 prefixes.
    - Provides address independence: The internal network does not need to be renumbered when the public/external IPv6 prefix changes.
    - May be used for multihoming.
    - Does not need to rewrite port numbers in packets, but may break e.g. IPssec.
    - May require split DNS since the external and internal addresses differ.
- NAT66 (IPv6 only):
    - Like NAT44, including all its problems.
    - Stateful.

## Address Planning and Implementation

- It should support both IPv4 and IPv6.
- IPv6 should be native.
- IPv4 may be provided through dual stack or as a service using translation or tunneling mechanisms.
    - IPv4 may can be tunneled both over internal core networks and through the internet edge.
    - If tunneling is appropriate, use 6rd, tunnel brokering or proto 41 forwarding, not ISATAP, 6to4 or Teredo. Prefer stateless.
    - Try to avoid NAT.
- For ISPs, native IPv6 with CGN for IPv4 is appropriate since IPv6 is proprotised and will offload IPv4.
- Internal addresses:
    - Should be IPv6-only.
    - May use either GUAs or ULAs.
    - Interfaces with ULAs which need internet access may:
        - Be assigned a GUA in addition to the ULA.
        - Use NPTv6 to translate the ULA prefix to a GUA prefix.
    - NAT66 is not required for ULAs and should not be used.
    - ULAs provide global address independence.
    - ULAs without NPTv6 provide an extra layer of protection for systems that should not be accessible externally.
- Sites should get a prefix long enough for multiple subnets.
    - Typically around 48.
    - Find out how much space you need before requesting it.
    - If you didn't get enough, ask for more.
- All subnets should be /64.
    - Event point-to-point links.
    - Does not focus on address conservation.
    - Does not require any VLSM.
    - Required by SLAAC and many other mechanisms and protocols.
- Topology aggregation VS policy/service aggregation.
- Suggested information to include in the prefix:
    - Region.
    - Location.
    - Service type.
    - Application.
    - Subnet.
    - VLAN ID (12 bits) (if the address plan is closely tied to the VLAN plan).
- Use provisioning tools (IPAM).
- Don't mirror the IPv4 address plan with all of its legacy problems.
- Plan both for now and for the future.
- Try to subnet on nibble boundaries since a nibble is one hex digit.
- GUA VS ULA.
- SLAAC VS DHCP.
    - Android does not support SLAAC.
    - DHCP provides more accountability.
- Implement appropriate first-hop security mechanisms, such as ICMP guard and DHCPv6 guard.
- Consider blocking certain multicast addresses, especially with site scope, to prevent attackers from identifying certain important resources on the network.
- Deploy both perimeter and host-based firewalls.
- Consider identity-based firewalls.
- Implement IPv6 in existing IPv4-only networks step by step. Either in phase with equipment lifecycles or as part of a needed redesign.
- Make sure Teredo is disabled on all clients not explicitly needing it.
- GUAs should use the privacy option to prevent tracking. This includes ULAs using NPTv6.
- PI space (provider independent) can be aquired to prevent network renumbering.
- Consider multihoming:
    - Redundancy and load balancing.
    - Potentally lower costs if the ISPs offer different prices for different services.
    - IPv6 supports native multihoming since interfaces can be assigned multiple prefixes from different routers.

{% include footer.md %}
