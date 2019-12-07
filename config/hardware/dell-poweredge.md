---
title: Dell PowerEdge Series
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Hardware
---
{% include header.md %}

### Using
2950 (G9); R310, R610, R710 (G11); R720 (G12)

## Firmware Upgrades

- G11: Download and boot into the model-specific firmware upgrade ISO from some box site, I can't remember where exactly. Most other methods are just painful and typically don't even work.
- G12+: Update through iDRAC 7 using HTTP site `downloads.dell.com`.

## Management

- Password: Lower-case, no special symbols, no spaces. Doing so may break stuff.

## Storage

- PERC 5/i and 6/i do not support disks over 2TB. PERC H200 and similar may need to be flashed to support it.
- PERC H200, H310 H310 mini etc. do not need to be flashed \(from IR\) to IT mode. They already function as HBAs. But upgrade the firmware. \(Controversal topic, needs verification.\)

{% include footer.md %}
