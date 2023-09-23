---
title: Cisco Application Centric Infrastructure (ACI)
breadcrumbs:
- title: Network
---
{% include header.md %}

## General

- A zero-trust platform and network fabric for data centers.
- Not part of Cisco DNA, but shares certain applications.
- Uses mainly Nexus switches in a spine-leaf topology.
- Managed by Application Policy Infrastructure Controller (APIC) (not to be confused with APIC-EM).

### Relation to SDA

- ACI is for DC while SDA is for campus/enterprise.
- Both are zero-trust platforms/fabrics with VXLAN-based overlays.
- SDA is part of Cisco DNA, ACI is its own thing.
- SDA is managed by DNA Center, ACI is managed by APIC.
- They're compatible for traffic going to/from datacenters (i.e. they share/translate zero trust info).
- ACI uses mainly Nexus switches while SDA used mainly Catalyst switches.

## Theory



{% include footer.md %}
