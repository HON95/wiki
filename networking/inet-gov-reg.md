---
title: Internet Governance and Registries
breadcrumbs:
- title: Network
---
{% include header.md %}

## Internet Governance

- The Internet is a decentralized network of networks, created through community efforts.
- Scope:
    - Technical infrastructure of the Internet: Managing IP addresses, domain names, protocols etc.
    - Content, use and impact: Policies, privacy, intellectual property, accessibility etc.
- Importance factors (currently):
    - Self-regulation is no longer sufficient: The Internet has grown, external involvement is needed to handle bad actors and egoistic applications.
    - Fragmentation: The Internet is facing fragments with non-neutral user experiences, non-interoperable standards, and non-global connectivity. Examples include China's Great Firewall and Russia's Sovereign Internet Bill.
    - Need for a shared forum: Shareholders must be able to discuss topics that may impact other shareholders and share eachother's viewpoints, instead of working only within their own silos.
- Parties of the multistakeholder approach:
    - Governments, national organizatons and international organizations.
    - The private sector.
    - The technical community.
    - Academia.
    - The civil society and users.
- The IGF has defined [10 themes of topics](https://www.intgovforum.org/en/content/igf-2022-themes-descriptions) covering the Internet governance landscape, each containing a number of subtopics.

## History

- The US created the ARPA agency under DoD leadership in 1958 for Cold War reasons, aimed at improving and strengthening the US communication system (specifically building a decentralized structure).
- ARPANET was created in 1969 by ARPA, consisting of four universities and funded by the DoD.
    - The original four universities were the University of Utah, the Stanford Research Institute, the University of Santa Barbara and the University of California LA, connected with a full mesh topology and no central control. More universities later joined in, even when the Cold War started to wind down.
    - Norway was the first non-US country connected to ARPANET in 1973, through the existing NORSAR link to the US ("Norwegian Seismic Array", also managed by ARPA). NDRE was involved with relevant research efforts. This connection was immediately thereafter extended to London.
- TCP/IP was created by Vint Cerf and Bob Kahn, initially through a 1974 IEEE paper named "A Protocol for Packet Network Intercommunication".
    - The initial versions of TCP/IP consisted of a monolithic "Transmission Control Program" protocol, handling both lower-layer and upper-layer features. This was split in version 3 into the Internet Protocol (IP) and the Transmission Control Protocol (TCP) to give greater flexibility.
    - The TCP/IP protocol contains the first use of the term "internet", referring to an internetwork (a network of networks).
    - Earlier drafts of the protocol included a 128-bit address space, but this was reduced to 32 bits in the final version of IPv4.
    - During the flagday January 1, 1983, ARPANET switched from NCP to TCP/IP.
- The IETF was created in 1986, utilizing consensus-based decision-making to improve the Internet.
- BGP was described in 1989 (the "three-napkin protocol") and has been used on the Internet since 1994. This replaced "EGP" and the even older "GGP" Internet routing protocols.
- IPv6 began standardization in 1995 and became an internet standard (highest level) in 2017. It was the result of the "IPng" IETF area created in 1993 to address mainly the pending exhaustion of the IPv4 address space.
- The World Wide Web (WWW) was invented by Tim Berners-Lee at CERN in 1989 (public in 1991), describing HTTP, hypertext ducoments, hyperlinks etc. for sharing digital content. This application of the Internet caused the number of Internet users to grow exponentially.
- In 1994, Tim Berners-Lee founded the World Wide Web Consortium (W3C) to maintain end develop the WWW.
- In 1995, management of TLDs .com, .net and .org was assigned to the company Network Solutions, giving them monopoly and causing the "DNS War".
- ICANN was established in 1998, taking responsibility for domain names and IP addresses (and other names and numbers) and forcing Network Solutions to separate its services and giving up its registry monopoly. Until 2016, Internet Assigned Numbers Authority (IANA) was part of ICANN.
- In 2003, the UN organized the first phase of the World Summit on Information Society (WSIS) in Geneva, focusing on the growing political issue of the Internet. The second module was held in Tunis in 2005. The Working Group on Internet Governance (WGIG) was created, producing a [report](https://www.wgig.org/docs/WGIGREPORT.doc) regarding Internet governance.
- The Internet Governance Forum (IGF) was first held in 2006 and has taken place every year since.
- The Internet Society (ISOC) was established in 1992, with chapters all around the world. It's mission is "to promote the open development, evolution, and use of the Internet for the benefit of all people throughout the world."
- The International Telecommunication Union (ITU) was established long before the Internet, but also takes special interest in the Internet.
- In 1992, RIPE NCC was establishdd to manage IP address allocations for Europe, becoming the first Regional Internet Registry (RIR). The four other RIRs were soon to folow.
- The The Number Resource Organization (NRO) was established in 2003, consisting of the four (now five) RIRs, to work on common interests.

Source: Mostly RIPE.

## Allocation and Assignment

### Overview

- IANA assigns IP blocks to RIRs.
- RIRs assigns IP blocks to LIRs.
- LIRs have an ASN and can sponsor ASNs for end users.
- LIRs get "aggregatable" IP blocks (/29-/32) that can be used by themselves and/or assigned to end users, called provider aggregatable (PA) addresses. More blocks can be requested.
- Address statuses:
    - Allocation: Blocks assigned from RIRs to LIRs, unused until assigned.
    - Assignment: Blocks assigned from an allocation to LIRs' own infrastructure or to end users.
    - Provider aggregatable (PA) assignment: Space assigned from a LIR to end users. PA space goes back to the LIR if the end user is no longer affiliated with the LIR.
    - Provider independent (PI) assignment: Space assigned from a RIR to end users, through a sponsoring LIR. End users can bring the space with them to other sponsoring LIRs, but they must sign a contract with the RIR to register and maintain it.
    - Sub-allocation: A sub-allocation by a LIR, rarely used.

### Statuses for IPv4 and IPv6 Objects

| Status | IPv4 | IPv6 |
| - | - | - |
| Allocation | `ALLOCATED PA` | `ALLOCATED-BY-RIR` |
| Sub-allocation | `SUB-ALLOCATED PA` | `ALLOCATED-BY-LIR` |
| PA assignment | `ASSIGNED PA` | `ASSIGNED` |
| PA assignment (aggregate)\* | n/a | `AGGREGATED-BY-LIR` |
| PI assignment | `ASSIGNED PI` | `ASSIGNED PI` |

(\*) Requires the `assignment-size` attribute.

### Legacy Space

- Legacy space are allocations made directly by IANA before the creation of RIRs.
- It can optionally be converted to allocated PA or PI through a LIR.

### IPv6 Allocations

- To request an IPv6 allocation, you must be a LIR and must have a plan for making assignments within two years (for internal or customer-facing services).
- The minimum IPv6 allocation size is /32. /29s can be requested without additional justification. /28s and larger require justification.
- Sub-allocations can be used to e.g. allocate part of a LIRs allocation to a downstream ISP (delegation method), or to reserve space for a customer that is expected to grow (reservation method).

### IPv6 Assignments

- /48 is the maximum allocation for PA and PI space without further justification.
- PA assignment:
    - LIRs can assign their PA space as they wish, to both themselves and to end users.
    - Multiple PA assignments of the same size can be registered in a single `AGGREGATED-BY-LIR` `inet6num` object, using the additional `assignment-size` field.
- PI assignment:
    - /48 is the mnimum allocation for PI space.
    - LIRs can request PI for their own infrastructure if they have special routing requirements.
    - LIR PI can not be sub-assigned to end users.
    - LIRs can request PI for end users, thus acting as a "sponsoring LIR".
- According to RIPE policies, all assignments must be registered in the RIPE Database using `inet6num` objetcs with one of the `ASSIGNED`, `AGGREGATED-BY-LIR` or `ASSIGNED PI` statuses.

## IP Blocklisting

- Getting unblocked can take time, so prevent getting blocked in the first place.
- Contacting the blocklisting operator and finding out why your prefix or ASN got blacklisted can be challenging.
- When getting a new prefix, check that it is not blocklisted.
- Prevent getting blocklisted:
    - As an ISP, make clear contracts for your customers to prevent unwanted content.
    - Implement BCP 38: "Network Ingress Filtering: Defeating Denial of Service Attacks which employ IP Source Address Spoofing".
    - Implement BGP security measures.
    - Use RPKI ROAs and keep IRR up to date.
    - Create IRR inet(6)num allocations/assignments for customers with proper descriptions, so blocklisting can hopefully be contained to problematic customers.
    - Implement automated blocklist monitoring to quickly find problems before customers complain.
    - If appropriate, monitor traffic from customers and automatically block them before they can become a public problem.
- How RIPE quatantines prefixes:
    1. Delist all objects.
    1. Put in quarantene for 6 months or as long as publicly routed.
    1. Assign to LIR in waitlist.

{% include footer.md %}
