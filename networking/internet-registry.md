---
title: Internet Registry
breadcrumbs:
- title: Network
---
{% include header.md %}

## Allocation and Assignment Overview

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

## Statuses for IPv4 and IPv6 Objects

| Status | IPv4 | IPv6 |
| - | - | - |
| Allocation | `ALLOCATED PA` | `ALLOCATED-BY-RIR` |
| Sub-allocation | `SUB-ALLOCATED PA` | `ALLOCATED-BY-LIR` |
| PA assignment | `ASSIGNED PA` | `ASSIGNED` |
| PA assignment (aggregate)\* | n/a | `AGGREGATED-BY-LIR` |
| PI assignment | `ASSIGNED PI` | `ASSIGNED PI` |

(\*) Requires the `assignment-size` attribute.

## Legacy Space

- Legacy space are allocations made directly by IANA before the creation of RIRs.
- It can optionally be converted to allocated PA or PI through a LIR.

## IPv6 Allocations

- To request an IPv6 allocation, you must be a LIR and must have a plan for making assignments within two years (for internal or customer-facing services).
- The minimum IPv6 allocation size is /32. /29s can be requested without additional justification. /28s and larger require justification.
- Sub-allocations can be used to e.g. allocate part of a LIRs allocation to a downstream ISP (delegation method), or to reserve space for a customer that is expected to grow (reservation method).

## IPv6 Assignments

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

{% include footer.md %}
