---
title: IPv6 Theory
breadcrumbs:
- title: Network
---
{% include header.md %}

### Resources
{:.no_toc}

- [IETF RFC 7381: Enterprise IPv6 Deployment Guidelines](https://datatracker.ietf.org/doc/html/rfc7381)
- [IETF RFC 7755: SIIT-DC: Stateless IP/ICMP Translation for IPv6 Data Center Environments](https://www.rfc-editor.org/rfc/rfc7755.html)
- [IETF RFC 7934 (BCP 204): Host Address Availability Recommendations](https://datatracker.ietf.org/doc/html/rfc7934)
- [IETF RFC 8200 (STD 86): Internet Protocol, Version 6 (IPv6) Specification](https://datatracker.ietf.org/doc/html/rfc8200)
- [APNIC: IPv6 Best Current Practices](https://www.apnic.net/community/ipv6-program/ipv6-bcp/)

## Special Prefixes

| Prefix | Scope | Description |
| - | - | - |
| `::/0` | | Default route |
| `::/128` | | Unspecified |
| `::1/128` | Host | Localhost |
| `::/96` | | IPv4-compatible IPv6 address (deprecated) |
| `::ffff:0:0/96` | | IPv4-mapped IPv6 address |
| `::ffff:0:0:0/96` | | IPv4-translated IPv6 address |
| `64:ff9b::/96` | | IPv4-embedded (e.g. NAT64) |
| `100::/64` | | Discard-only (RTBH) |
| `2000::/3` | Global | Global unicast address (GUA) |
| `2001::/32` | | Teredo |
| `2001:20::/28` | | ORCHIDv2 |
| `2001:db8::/32` | | Documentation (non-routable) |
| `2002::/16` | | 6to4 (deprecated) |
| `3ffe::/16` | | IPv6 Testing Address Allocation (6bone) (reverted) |
| `fc00::/7` | Global | Unique local address (ULA) |
| `fd00::/8` | Site | Locally administered ULA |
| `fe80::/10` | Link-local | Link-local unicast (non-routable) |
| `ff00::/8` | Variable | Multicast |

### Multicasst addresses

| Prefix | Scope | Description |
| - | - | - |
| `ffx2::/16` | Link | Link-local scope |
| `ffx5::/16` | Site | Site-local scope |
| `ffxe::/16` | Global | Global scope |
| `ff02::1` | Link | All-nodes |
| `ff02::2` | Link | All-routers |
| `ff02::6a` | Link | All-snoopers (multicast router discovery) |
| `ff02::fb` | Link | mDNSv6 (link-local) |
| `ff05::fb` | Site | mDNSv6 (site-local) |
| `ff02::1:2` | Link | All-DHCP-relay-agents-and-servers |
| `ff05::1:3` | Site | All-DHCP-servers |
| `ff02::6b` | Link | PTPv2 messages |
| `ff02:0:0:0:0:1:ff00::/104` | Link | Solicited-node |

### Special Subnet Addresses

- Subnet-router anycast address: The first interface ID in every subnet (RFC 4291). (Does not apply to /127 and /128 addresses.)
- Subnet anycast addresses: The last 128 interface IDs in every subnet (RFC 2526). (Does not apply to /127 and /128 addresses.)

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
    - All subnets are (shoul be) /64 regardless of the number of hosts/interfaces (excluding e.g. /127 linknets).
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
- Interfaces can (and typically do) have multiple addresses.
    - One link-local address.
    - One or more addresses for each different advertised prefix from each local router.
- More efficient routing due to better address aggregation (potentially).
- More efficient packet processing:
    - Streamlined fixed-length header with extension headers.
    - No fragmentation in routers.
    - No checksum.

## Addressing

- 128 bit addresses.
- No broadcast.
- Anycast:
    - Explicitly supported.
    - May use any unicast address.
    - Treated like unicast except by the last routers toward the hosts using the anycast address.
    - Some important addresses:
        - Subnet-router anycast: The first interface ID in every subnet. All routers are required to listen to it. (RFC 4291)
        - Reserved: The last 128 interface IDs in every subnet. (RFC 2526)
    - Shared unicast address approach:
        - An alternative approach to anycast.
        - Same as for IPv4, based purely on unicast and routing and no explicit anycast mechanisms.
        - Multiple hosts using is as their unicast address and letting routing protocols route towards the closest one.
- Multicast:
    - Some scopes:
        - 1: Interface-local.
        - 2: Link-local.
        - 5: Site-local.
        - E: Global.
    - Some important addresses:
        - `ff02::1`: All-nodes (link-local).
        - `ff02::2`: All-routers (link-local).
        - `ff02::3`: All-hosts (link-local).
        - `ff02:6a`: All-snoopers (link-local).
        - `ff02::1:ff00/24`: Solicited-node (link-local).
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
- DHCP:
    - See the section below.
    - Similar to DHCPv6, but with some important changes.
    - Generally used when indicated by router advertisements that DHCP should be used (stateful or stateless).
    - Stateless DHCP instructs devices to use address autoconfiguration, but get additional data (e.g. DNS servers) from the DHCP server.
- SLAAC interface ID generation methods:
    - Modified EUI-64 addresses:
        - The first method of autoconfiguring an address, giving a single interface ID deterministically based on the MAC address (using the modified EUI-64 method).
        - Useful for servers with autoconfigured addresses due to its stability, unlike temporary addresses that change over time.
    - Privacy/temporary addresses (RFCs 3041, 4941, 8981):
        - A set of extensions adding temporary, randomized addresses in order to preserve privacy by not revealing the MAC address (visble from the EUI-64) and also to periodically change the address.
        - When a new address is generated, the existing ones are marked as deprecated and not used for new connections, but are kept to keep existing connections alive.
        - While earlier RFCs called this "privacy extensions", newer RFCs refer to this as "temporary address extensions".
    - Stable and Opaque addresses (RFCs 7217 and 8064):
        - Uses a single, deterministic address based on the host and the subnet.
        - This avoids having to change the address as in temporary address extensions and avoids MAC-trackable addresses as in modified EUI-64 addressing.
        - This is now the default in RFC-compliant IPv6 stacks.
    - ... and other methods.
- Reserved subnet addresses:
    - The first and last addresses in a subnet are not reserved and it's *possible* be assigned to hosts, unlike IPv4 (i.e. the network and broadcast addresses).
    - However, address zero is reserved for the subnet-router anycast address and the last 128 addresses are reserved for other subnet anycast addresses.
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

## Packet

- Overall, IPv6 replaced the variable-length IPv4 header with options and stuff (20 bytes or more) with a streamlined, constant-length bases header (40 bytes) and an optional chain of extension headers.
- Changes in header fields from IPv4 to IPv6:
    - Changed the value of the "version" field from 4 to 6.
    - Removed the "internet header length" (IHL) field, the base header is constant-length now.
    - Removed the "identification", "flags" and "fragment offset" fields, fragmentation is handled by the fragmentation header now.
    - Removed the "header checksum" field, since checksumming is often done by both lower-level and higher-level protocols.
    - Removed the "options" field and its padding, options are now replaced by extension headers.
    - Replaced the "type of service" (ToS) with the "traffic class", used for the same purpose. Actually split into a DiffServ field and an ECN field for both protocols.
    - Replaced the "total length" field (size of header and payload) with the "payload length" field (size of payload, including extension headers).
    - Replaced the "time to live" (TTL) field with the "hop limit" field. Whereas the IPv4 TTL was meant to represent time in seconds, the IPv6 hop limit now specifies the number of hops instead, which is generally how TTL was implementet anyways.
    - Replaced the "protocol" field with "next header" field, giving the type of the next extension header or the upper-layer protocol if no extension headers (like the last extension header).
    - Added the "flow label" field, allowing the use of explicit flows instead of the implicit 5-tuple flow definition. A zero value means no flow classification. The flow label indicates to intermediate hops that the packets in the flow should travel along the same path, preventing reordering and stuff.
- Extension headers:
    - Each extension header, as well as the base header, specifies the protocol of the next header. The very last header (base or extension) specifies the protocol of the upper-layer PDU.
    - IPv6 allows an arbitrary amount of extension headers, unlike the limited size of the IPv4 options field.
    - Extension headers should appear in a certain order, see RFC 8200.
    - While the base header was made more "streamlined" by making it constant-length, it can maybe be argued that the chain of extension headers makes the whole IPv6 packet less streamlined as each header must be examined to find the start of the upper-layer PDU, where e.g. the TCP/UDP port numbers may be found (e.g. for filtering or NAT/PAT purposes).
- Current extension headers (in recommended order):
    - Hop-by-hop options: For intermediate nodes, containing suboptions in the TLV format. Should be immediately after the base header.
    - Routing: For source routing.
    - Fragment: For fragmentation, which must be done by the sender.
    - Authentication header (AH): For IPsec.
    - Encapsulating security payload (ESP): For IPsec. May be followed by either a destination options header or the upper-layer PDU.
    - Destination options: Similar to hop-by-hop options, but for the destination. May be used twice if used together with a routing header, in which the first one should be immediately before the routing header.
- Fragmentation:
    - Routers no longer fragment, is't not its job.
    - Path MTU discovery.
    - Not allowed for some NDP messages.
    - The first fragment must contain all headers.

## Protocols and Techniques

### Neighbor Discovery (ND)

- Uses ICMPv6.
- Link-layer address resolution.
- Neighbor unreachability detection (NUD).
- Duplicate IP address detection (DAD).
    - Determines if the address is unique before it can be used.
    - Opportunistic DAD allows using the address before DAD finishes.
- Redirect.
- Router advertisements.
    - SLAAC or DHCPv6.
    - M-bit (managed address configuration flag): If DHCPv6 is used to assign host addresses.
    - O-bit (other configuration flag): If DHCPv6 can be used to obtain more information (e.g. DNS servers). Ignored if M-bit is set.
    - L-bit (on-link flag) (for prefix): If the prefixes are directly reachable on the link, so the host can reach them without going through the router.
    - A-bit (address configuration flag) (for prefix): If the host can generate a SLAAC address using this prefix. Can be set together with M-bit for fun results.
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
    - Messages:
        - Query: Sent by routers to query the subnet for listeners for all groups (general) or a specific group (specific).
        - Report: Sent by hosts to join a group or to respond to queries.
        - Done: Sent by hosts to leave a group.
- Version 2:
    - Based on IGMPv3.
    - Source-specific multicast (SSM).
    - Messages:
        - Query: Same as MLDv1, but adds the source-specific query type.
        - Report: Same as MLDv1, but also takes the role of MLDv1 Done for hosts leaving a group.
- PIM can be used for routing between subnet.
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
- Android and Chrome OS does not support DHCPv6, by design.
    - To help with traceability without DHCPv6, Netflow or periodic NDP cache scans with SNMP can be used.

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

### Path MTU Discovery (PMTUD)

- Since IPv6 does not fragment along the path, knowing the path MTU is important.
- ICMPv6 error type 2 ("packet too big") are send by routers along the path if the packet is too big, so the host can retry using a smaller packet.
- The minimum MTU for IPv6 is 1280 octets. 1500 octets is generally the default.
- `tracepath` on Linux can be used to troubleshoot path MTUs.

### Routing Protocols (Summary)

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

- IP masquerading aka NAT44 (IPv4 only).
    - Limitations (apply to many other NAT approaches as well):
        - Port exhaustion: Some applications use a lot of connections, making port exhaustion a real threat when many users share the same port range.
        - Violates end-to-end connectivity: A core Internet principle.
          The external hosts can't address and connect to the internal host.
          For layer 4 and higher protocols, like UDP and TCP, port forwarding or hole punching must be used to connect to the internal host.
          Layer 3 protocols, like ICMP, won't be able to traverse the NAT router.
          Protocols that embed the address in the payload, like IPsec, will generally not work without special handling.
        - Prevents unique identities: Host can not be identified with unique IP addresses, which may cause multiple problems.
          Service providers will not be able to identify hosts doing participating in illegal activities, like attacking some server or downloading illegal content.
          IP blocking (as a result of offensive activities) and throttling will affect all hosts sharing the same public IP address, which may be accidental or intentional DoS.
          Service providers (like game platforms) may flag and block the IP address when many users are concurrently using the same services, because it thinks it's a bot.
- Carrier grade NAT (CGN) aka NAT444 (IPv4 only).
    - Preserves even more IPv4 address space than NAT44.
    - May be a good approach for providing native IPv4 as a service when most traffic is using IPv6.
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
        - See NAT44 limitations.
        - All clients must be configured to use the the DNS64 server (e.g. through DHCP). Clients with statically configured public servers will not work.
        - All IPv4 addresses must have an associated domain name which must be used in place of the address literal.
          This may not always be the case, e.g. when people host stuff from home and use the IPv4 address directly.
        - Some applications just don't support IPv6, or may use IPv4 literals (hardcoded or acquired dynamically). They won't work, period.
        - Synthesized DNS records break DNSSEC. I'm not sure if typical clients validate DNSSEC, though.
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

*Might be outdated, best practices change over time ...*

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
        - Use NPTv6 to translate the ULA prefix to a GUA prefix (avoid if possible, use GUA instead).
    - NAT66 is not required for ULAs and should not be used.
    - ULAs provide global address independence.
    - ULAs without NPTv6 provide an extra layer of protection for systems that should not be accessible externally.
- Sites should get a prefix long enough for multiple subnets.
    - Typically around 48.
    - Find out how much space you need before requesting it.
    - If you didn't get enough, ask for more.
- All subnets should be /64.
    - Convention where all networks are of the same length, making "/64" synonymous with "network" and makes all networks addressable with exactly 64 bits or 16 hexadecimals (ignoring zero compression).
    - Address conservation should not be taken into account, there's enough /64 prefixes.
    - Avoids pointless VLSM, a thing of the past.
    - Required by e.g. SLAAC and unicast-prefix-based IPv6 multicast addresses (RFC 3306).
    - Even for point-to-point links (/127) and loopbacks (/128), such that uplinks always use ":0", downlinks always use ":1" and loopbacks always use in ":0".
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
- Subnet on nibble boundaries.
    - Makes the address plan clearer since one nibble is one hexadecimal digit, so you avoid ranges within a digit and so you probably won't need a subnet calculator with a little bit of practice.
    - Can *roughly* be compared with subnetting on bit boundaries for IPv4, since the address space is four times larger.
    - Makes the address plan much more uniform while only sacrificing a small bit of granularity.
    - Allows for DNS reverse zones that match exactly the prefixes.
- Leave space for future expansion within prefixes. Avoid having to create multiple prefixes for the same purpose due to lack of space.
- GUA VS ULA.
- SLAAC VS DHCP.
    - Android and Chrome OS does not support SLAAC, by design.
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

### Philip Smith: IPv6 Address Planning (2012)

*IPv6 BCP according to APNIC.*

- Focus on scalability and ease of use/application of security policies and network management.
- IPv6 allows creating a more flexible address plan.
- Always segment on nibble boundaries. Makes it simpler.
- Allocate:
    - One /48 for the infrastructure and other "units". Allocate separate ones for customer links at each PoP.
    - Use the first /48 for infrastructure, to keep important addresses short.
    - Within each /48, allocate all loopbacks within the first /64.
    - Allocate linknets as separate /64s but address as /127.
    - Allocate /64s for each LAN.
- Customers generally get a /48.
- Design a scheme to keep some structure.

{% include footer.md %}
