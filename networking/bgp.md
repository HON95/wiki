---
title: Border Gateway Protocol (BGP)
breadcrumbs:
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Routing Theory](/networking/routing/)

## General

- A path vector protocol and the only EGP currently used on the Internet.
- Version 4 (BGP-4) with multiprotocol extensions (MBGP) is the most common version, which supports CIDR, route aggregation and _address families_ such as multicast IPv4, unicast IPv6 and VPN information for MPLS.
- Uses a set of attributes to describe a route (see subsection).
- Route filtering and RPKI are methods commonly used to prevent accidental or malicious misconfiguration where prefixes are routed a place they should not.
- Redistributing between BGP and an IGP should in most cases be avoided. BGP has huge routing tables. IGP is dumber than BGP. IGP flapping should not leak onto EGPs, this may also be penalized by _route flap dampening_ (RFD).
- Unlike typical IGPs, it does not support any kind of auto discovery of other BGP peers, but peers must instead be statically configured. It uses TCP port 179.
- Exterior BGP (eBGP) is used to advertise and receive routes from peers in other ASes, while interior BGP (iBGP) is used to distribute routes between all eBGP routers in the same AS. iBGP is used instead of an IGP because an IGP would lose BGP information.
- The iBGP split horizon rule: Routers are not allowed to adversise a route learned from one iBGP peering to another iBGP peering. This prevents loops in iBGP, but requires that peers must be connected in a full mesh. To reduce the complexity of the iBGP full mesh, techniques like route reflectors (RRs) (dividing the AS into clusters) and confederations (dividing the AS into sub-ASes) may be used.
- eBGP peers are generally required to be directly connected, which is enforced by using an IP TTL of 1. This limit may be relaxed by using multihop sessions. iBGP however is not subject to thus requirement.
- Both multihop sessions and TTL security are mutually exclusive features for increasing the number of allowed hops between eBGP peers, which is limited to 1 by default. TTL security (aka Generalized TTL Security Mechanism (GTSM), RFC 5082) inverts the TTL check for a value of minimum 255 minus the configured number of hops. This prevents remote attackers from spoofing the number of hops, as the TTL is limited by it's maximum value of 255.
- The synchronization rule: When a router receives a new route to announce from iBGP, it must first wait until it can validate the route from the IGP (in case iBGP is faster). This prevents announcing over eBGP a route that can't yet be routed within the AS.
- Full BGP tables are exchanged only during the start of peer sessions. Thereafter, only new announcements or withdrawals are exchanged.
- Network layer reachability information (NLRI) is basically what BGP calls prefixes. It does not include path attributes and other routing stuff.
- Message types:
    - Open: The first message sent when starting a session, for identifying eachother's capabilities and exchange basic information (not routes).
    - Update: Exchanges new route advertisements and withdrawals (NLRI and path attributes).
    - Keepalive: Shows it's still alive in the absence of update messages. Both keepalives and updates reset the hold timer.
    - Notification: Signals errors and/or closes the session.
- RFC 4271 recommends a 90 second hold timer and a 30 second keepalive timer (1/3 of hold timer).
- Internet Routing Registry (IRR) and Resource Public Key Infrastructure (RPKI) are methods to secure BGP in order to prevent route leaks/hijacks. While all routes should use IRR and RPKI (for providing valid bindings of prefixes to ASNs).
- Letter of Agency (aka Letter of Authorization) (LOA) required in certain countries to be allowed to announce a prefix.
- The "default-free zone" (DFZ) is the set of ASes which have full-ish BGP tables instead of default routes.
- Communities are used to exchange arbitrary policy information for announcements between peers. See [BGP Well-known Communities (IANA)](https://www.iana.org/assignments/bgp-well-known-communities/bgp-well-known-communities.xhtml).
- "Soft reconfiguration" (IOS: `neighbor <ip> soft-reconfiguration inbound`) is a feature to cache all incoming raw announcements from peers, such that the BGP table can be quickly rebuilt if it needs to be cleared. This reduces the impact of clearing the table and is recommended, but does increase memory usage.
- Peer arrangements:
    - Transit provider: The peer provides routes and traffic across their own AS in order to reach "the rest" of the Internet. The peer would typically be considered an upstream. May use single-homing with a single transit provider or multi-homing with multiple transit providers.
    - Peer-to-peer: Two or peers exchange their own routes to eachother and often allows traffic to flow free of charage between themselves. Peerings happening at IXPs would are called public peerings and peerings happening directly between the peers (outside an IXP) would be called private peerings.

## Attributes

Classification:

- Mandatory/descretionary: If the attribute must be included in all updates.
- Well-knon/optional: If all implementations are required to recognize the attribute.
- Transitive/non-transitive: If an AS should be advertise an attribute it received from one AS to other ASes or if it is only of significance between pairs of ASes/peers.

Some important attributes:

- Origin (well-known, mandatory): How the prefix entered BGP. 0/"i" means from IGP, 1/"e" means from EGP, 2/"?" means redistributed from other sources or static routes.
- AS path (well-known, mandatory): The path of ASes to pass through in order to reach the destination. An eBGP peer prepends its own ASN before advertising it to other peers. ASes are free to append their ASN multiple times in series to artificially make the path longer (BGP prefers the shortest AS path during the path selection algorithm). If an AS aggregates prefixes from other ASes, it may use AS sets to indicate all ASes from which it aggregated the prefixes, giving an AS path like e.g. `100, {200, 201}`. The AS path is also used for loop avoidance, by checking for its own AS in the path.
- Next hop (well-known, mandatory): The address of the nex hop towards the destination. eBGP peers will always change this to their own address but iBGP peers will never alter it.
- Multi-exit discriminator (MED) (optional, non-transitive): When two ASes peer with multiple eBGP peerings, this number signals which of the two eBGP peerings should be used for incoming traffic (lower is preferred). This is only of significance between friendly ASes as ASes are selfish and free to ignore it (other alternatives for steering incoming traffic are AS path prepending, special communities and (as a very last resort) advertising more specific prefixes).
- Local preference (well-known, discretionary, non-transitive): A number used to prioritise outgoing paths to another AS (higher is preferred).
- Weight (Cisco-proprietary): Like local pref., but not exchanged between iBGP peers.
- Community (optional, transitive): A bit of extra information used to group routes that should be treated similarly within or between ASes.

## Path Selection

The path selection algorithm is used to select a single best path for a prefix. The following shows an ordered list of decisions for which route to use, based on Cisco routers:

1. Longest prefix match (before path selection).
1. Resolvable next-hop address (hidden).
1. Highest weight (Cisco).
1. Highest local pref.
1. Locally originated ("network" or "aggregate" command).
1. Shortest AS path.
1. Lowest origin (IGP then EGP then other).
1. Lowest MED (typically ignored).
1. eBGP over iBGP.
1. Lowest IGP metric.
1. Lowest BGP router ID.

## Internet Routing Registry (IRR)

- IRR is a mechanism for BGP route origin validation (ROV) using a set of routing registries.
- It consists of IRR routing policy records which are hosted in one of the multiple IRR registries.
- Records are typically created for the route (`route`), the ASN (`aut-num`) and the upstream ISP AS-SET (`as-set`).
- IRR is out-of-band, meaning it does not affect how originating routers are configured. It should however be able to source filtering policies for peering ASNs somehow.
- IRR uses the Routing Policy Specification Language (RPSL) for describing routing policies.
- Due to outdated, inaccurate or missing data, IRR has not seen global deployment.
- The RIPE Database is tightly couples with it's IRR.
- Setting up route objects in the RIPE Database:
    - See [Managing Route Objects in the IRR (RIPE)](https://www.ripe.net/manage-ips-and-asns/db/support/managing-route-objects-in-the-irr).
    - IRR policies are handled by `route(6)` objects, containing the ASN and IPv4/IPv6 prefix.
    - Authorization for managing `route(6)` objects can be a little complicated. Generally, the LIR is always allowed to manage it.
- For more info, see [Internet Governance and Registries](/networking/inet-gov-reg/).

## Resource Public Key Infrastructure (RPKI)

- RPKI is a mechanism for BGP route origin validation using cryptographic methods.
- Like IRR, it validates the route origin only instead of the full path. Since routes typically use the shortest path due to both economical and operational incentives, this is generally not a big problem. It's also typically the case that route leaks are misconfigurations rather than malicious attacks, which origin validation would mostly prevent.
- It's certificate authority (CA)-based, but RPKI calls the CAs "trust anchors" (TAs). The fire RIRs act as root CAs, which are also the entities allocating the ASN and IP prefixes which RPKI attempts to secure. This also simplifies RPKI management, as it's managed the same place as ASNs and IP prefixes. This also helps lock down access control for which orgs may create ROAs for which resources.
- The main component are route origin authorization (ROA) records, which are certificates containing a prefix and an ASN.
- ROAs are X.509 certificates. See RFCs 5280 and 3779.
- IANA maintains lists for which ASNs, IPv4 prefixes and IPv6 prefixes are assigned to which RIR, which is also used to determine which RIR to use for RPKI.
- Unlike DNSSEC where IANA is the single CA root (and IANA reporting to the US government), RPKI uses separate trees/TAs for each RIR, slightly more similar to web CAs (with arguably _too many_ CAs). There are some legal/political issues when the RIRs operate as TAs too, though.
- RPKI is typically running out-of-band on servers called "validators" paired with the routers. For routers supporting it, the RPKI router protocol (RTR) may be used to feed the list of validated ROAs (aka VRPs or the validated cache, see other notes). It's recommended to use multiple validators for each router for redundancy. To reduce the number of validators, many routers may access common, remote validators over some secure transport link. The validators must periodidcally update their local databases from the RIRs' ones. It the route validator are running in parallel with the routers, it has a negligible impact on convergence speed.
- RPKI Repository Delta Protocol (RRDP) (RFC 8182) is designed to fetch RPKI data from TAs and is based on HTTPS. It has replaced rsync due to rsync being inefficient and not scalable for the purpose.
- If all validators become unavailable or all ROAs expire, RPKI will fall back to accepting all routes (the standard policy when a ROA is not found).
- Trust anchor locators (TALs) are used to retrieve the RIRs' TAs and consists of the URL to retrieve it as well as a public key to verify its authenticity. This allows TAs to be rotated more easily.
- RIPE, APNIC, AFRNIC and LACNIC distribute their TALs publicly, but for ARIN you have to explicitly agree to their terms before you can get it.
- All RIRs offer hosted RPKI managed through the RIR portal, but it can also be hosted internally for large organizations, called delegated RPKI.
- ROAs contain a max prefix length field, which limits how long prefixes the AS is allowed to advertise. This limits segmentation and helps prevent longer-prefix attacks.
- Validation of a ROA results in a validated ROA payload (VRP), consisting of the IP prefix (same length or shorter), the maximum length and the origin ASN. Comparing router advertisements with VRPs has one of three possible outcomes:
    - Valid: At least one VRP (maybe multiple) contains the prefix with the correct origin ASN and allowed prefix length. The route should be accepted.
    - Invalid: A VRP for the prefix exists, but the ASN doesn't match or the length is longer than the maximum. The route should be rejected.
    - Not found: No VRP with a matching prefix was found. The route should be accepted (until RPKI is globally deployed, at least).
- ROAs are fetched and processed periodically (30-60 minutes preferably) to produce a list of VRPs, aka a validated cache. ROAs that are expired or are otherwise cryptographically erraneous are discarded and thus will not be used to validate route announcements.
- Local overrides may be used for VRPs, e.g. for cases where a temporarily invalid announcement must be accepted. See Simplified Local Internet Number Resource Management with the RPKI (SLURM) (RFC 8416)
- Setting up RPKI ROAs in the RIPE Database:
    - See [Managing ROAs (Ripe)](https://www.ripe.net/manage-ips-and-asns/resource-management/rpki/resource-certification-roa-management).
    - For PA space, only the LIR is authorized to manage ROAs.

### Resources

- [RPKI Documentation (NLnet Labs)](https://rpki.readthedocs.io)
- [RPKI Test (RIPE)](http://www.ripe.net/s/rpki-test)

## Security

- BGP comes from a period when the Internet was built on trust. It therefore lacks built-in security mechanisms for route authentication and similar. This leads to both misconfiguration accidents and attacks.
- Use the TCP Authentication Option (TCP-AO) for peering authentication. MD5 is also widely used, but is weak and deprecated.
- Use route origin validation (ROV), based on manual route filters, IRR policies or RPKI ROAs.
- Use prefix filtering:
    - Use bogon filtering. See RFC 5156, [IANA](https://www.iana.org/assignments/iana-ipv6-special-registry/iana-ipv6-special-registry.xhtml) and [Cymru](https://www.team-cymru.com/bogon-networks).
    - Use RPKI filtering, by preferring RPKI-valid routes and dropping RPKI-invalid routes.
    - Allow end users and peers to only advertise agreed-upon routes, typically sourced automatically from IRR.
- Some attack categories:
    - TCP/IP protocol attacks (spoofing, session hijacks, connection resets, SYN flooding).
    - BGP router attacks (message flooding, route flapping etc.).
    - Route manipulation attacks (origin or path hijacks).
    - Protocol manipulation attacks (attribute modifications, timer exploitations).

### BGPsec

- Uses PKI for authentication and integrity for routes.
- Too computationally heavy for current Internet routers, therefore not widely used.

### Threats

- No peer encryption or authentication:
    - Peers can pretend to be any AS they want (in theory).
    - Messages are vulnerable to e.g. MITM attacks, replay attacks and connection reset attacks.
    - BGP limiting the amount of hops between peers (default 1 hop) limits the range of the attack.
    - **TODO** Mitigation.
- No route origin validation (ROV):
    - Peers/AS-es may advertise any route they want, legitimate or not.
    - This leads to route hijack attacks, causing DoS and/or MITM attacks.
    - A simple way to get a better route than the legitimate one is to simply advertise a more specific route (or multiple), causing a hijack attack.
    - **TODO** Mitigation.
- No path attribute authentication:
    - Path attributes like e.g. the AS path list may be altered along the way, either by legitimate peers or by MITM attacks.
    - By shortening the AS path for some route, an adversary could create a better route going through itself, causing a hijack attack.
    - **TODO** Mitigation.
- Route hijacking:
    - A route is hijacked through route origin spoofing (origin hijack) or through path modifications (path hijack), yielding a DoS attack (simple) or a MITM attack (complex).
    - A simpler way to hijack traffic is to advertise a more specific prefix (sub-prefix hijack) instead of the original prefix (prefix hijack). Since a prefix hijack would be competing against the legitimate route, it would be considered a _local hijack_ as it would be the best route for nearby AS-es but probably not for remote AS-es. A sub-prefix hijack, however, would be consideres a _global hijack_ as it would always be considered better and would affect the whole Internet.
    - Prefix and sub-prefix hijacks typically only work for allocated address space, where routes legitimate would be advertised. Hijacked routes for unallocated address space, however, is unlikely to affect any services as it's by definition not in use, but may cause harm to the victim's reputation. Advanced bogon filtering may be used to reject all unallocated address space, or just address space not allocated to LIRs and end users.
    - A MITM attack must still be able to deliver the traffic toward the legitimate destination, which may be difficult if you're holding the "best route" toward the origin.
    - The hijack may also be used to divert traffic toward a peer that can't handle the traffic load, yielding another DoS.
- Route leaks:
    - Related to ROV. Accidentally advertising a more specific route for some third-party AS' prefixes is an easy way to DoS them.
    - This is also a simple way to DoS yourself with a large traffic load.
    - Like ROV, use proper ingress and egress route filtering to avoid this.
- Route flapping:
    - Causes unnecessary ripples in the Internet, potentially causing performance problems.
    - Route flap dampening (RFD) dynamically rate limits route flapping until the route becomes more stable.
    - Minimum route advertisement interval (MRAI) statically rate limits route advertisements.
    - Manipulation of these timers can be used for DoS attacks where third-party routes are dampened and made unavailable.
- DNS hijacking:
    - Just hijack the prefix the DNS server(s) reside in.
    - Taking control over DNS can make it trivial to hijack other services.
    - As e.g. Let's Encrypt gives signed certificates based on DNS (directly or through the server a name points to), having control over DNS also gives you valid public certificates.
    - For DNS servers without DNSSEC.

## Best Practices

- Announced prefix lengths (max /24 and /48): Generally, use a maximum length of 24 for IPv4 and 48 for IPv6, due to longer prefixes being commonly filtered. See [Visibility of IPv4 and IPv6 Prefix Lengths in 2019 (RIPE)](https://labs.ripe.net/Members/stephen_strowes/visibility-of-prefix-lengths-in-ipv4-and-ipv6).
- IRR and RPKI: Add `route(6)` objects (for IRR) and ROAs (for RPKI) for all prefixes, both to avoid having your prefixes hijacked and to reduce the risk of getting filtered.
- Explicit import & export policies: Always explicitly define the input and output policies to avoid route leakage. Certain routers defaults to announcing everything if no policy is defined, but RFC 8212 defines a safe default policy of filtering all routes if no policy is explicitly defined.
- Enable large communities: 2-byte communities are outdated, enable 12-byte communities to allow for more advanced policies and to keep up up to date with 4-byte ASNs. See RFCs 8092 and 8195.
- Administrative shutdown message: When administratively shutting down a session (due to maintenance or something), set a message to explain why to the other peer. Peers should log received shutdown messages. See RFC 9003, which adds support for this free-form 128-byte UTF-8 message in the BGP notification message.
- Voluntary shutdown (for BGP-speaking routers): Before maintenance where the router is unable to route traffic, shutdown BGP peering sessions and wait for BGP convergence around the router to avoid/reduce temporary blackholing. Aka voluntary session culling and voluntary session teradown. See RFC 8327.
- Involuntary shutdown (for IXPs): Before maintenance which will prevent connected routers from forwarding traffic through the IXP, apply an ACL or similar to filter all BGP communication (TCP/179) between directly connected routers and wait for BGP convergence around the IXP to avoid/reduce temporary blackholing. Multihop sessions may be allowed. This is as an alternative to or in addition to voluntary shutdown, as the routers are generally managed by orgs other than the one managing the IXP. Related to voluntary shutdown and described by the same RFC.
- Use and support the graceful shutdown community: The well-known community GRACEFUL_SHUTDOWN (65535:0) is used to signal graceful shutdown of announced routes. Peers should support this community by adding a policy matching the community, which reduces the LOCAL_PREF to 0 or similar such that other paths are preferred and installed in the routing table, to eliminate the impact when the router finally shuts down the session. See RFC 8326.
- Use and support the blackhole community: The well-known community BLACKHOLE (65535:666) is used to signal that the peer should discard traffic destined toward the prefix. This is mainly intended to stop DDoS attacks targeting the certain prefix before reaching the router advertising it, such that other non-targeted traffic may continue to use the link. While announced prefixes should generally avoid exceeding a certain max length, announcements with the blackhole community are typically allowed to be as specific as possible to narrow down the blackhole addresses (e.g. /32 for IPv4 and /128 for IPv6). See RFC 7999.
- Add reject-by-default policies to avoid leaking routes when no policies have been explicitly defined.
- Use Soft reconfiguration (IOS: `neighbor <ip> soft-reconfiguration inbound`) to avoid temporary downtime if the BGP process is restarted or the table is cleared.
- Which neighbor IP address to normally use:
    - eBGP: Use the linknet address to avoid having to setup routing for the neighbor loopback address, except for special HA/LB setups.
    - iBGP: Use the loopback address, which should be learned from an IGP. Set `neighbor <ip> update-source Loopback0` (IOS) to use the loopback address for routing.

{% include footer.md %}
