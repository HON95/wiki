---
title: Dante and AES67
breadcrumbs:
- title: Media
---
{% include header.md %}

## TODO

- PTP stuff: See PTP page.
- QoS:
    - AES67 or ST 2110 mode uses AES67-recommended DSCP values.
    - Try to avoid mixed PTPv1 and PTPv2 in the same domain, it may cause QoS issues where PTPv1 is prioritized. PTPv1 may be disabled using the "PTP V1 Multicast" option in DDM.
- Dante uses unicast streams by default (supports multicast), while AES67 used multicast streams by default.
- Dante in ST 2110 mode requires Dante Domain Manager.
- Other network optimizations:
    - Do not use EEE on switchports, it can cause audio glitches.
    - Enable IGMP snooping on the switch to control multicast traffic. Make sure the switch or another network device acts as IGMP querier.
- Security:
    - Dante/AES67 has no built-in security. An adversary getting access to the network would get full access to routing and streams.

{% include footer.md %}
