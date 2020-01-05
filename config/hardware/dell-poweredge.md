---
title: Dell PowerEdge Series
breadcrumbs:
- title: Configuration
- title: Hardware
---
{% include header.md %}

### Using
{:.no_toc}
2950 (G9); R310, R610, R710 (G11); R720 (G12)

## Firmware Upgrades

### G11 and lower
There are lots of ways to upgrade the firmware, but most are painful and typically don't even work (e.g. loading firmware files in the Lifecycle Controller, Repository Manager custom ISOs, Repository Manager repositories, Repository Manager firmware files, and the Server Update Utility (SUU)). One way that *does* work is finding a pre-built bootable ISO and booting into it, but finding an ISO is getting harder.

### G12 and higher
Update through iDRAC 7 using HTTP site `downloads.dell.com`.

## Management

- Password: Lower-case, no special symbols, no spaces. Doing so may break stuff.

## Storage

- PERC 5/i and 6/i do not support disks over 2TB. PERC H200 and similar needs to be flashed to a newer version to support it.
- Some say the PERC H200, H310, H310 mini etc. need to be flashed from IR (the default) to IT mode in order to pass through unconfigured disks directly instead of presenting them as individual RAID volumes and maybe adding proprietary headers on disk. ZFS (e.g.) needs direct access to the disks to work optimally, meaning you should flash it to IT mode if you intend to use the card as an HBA with ZFS or similar. This can cause the cards to no longer be accepted in the R610 and R710 PCIe-like storage slot and needs to use a normal PCIe slot instead. However, some say that IR cards (not flashed to IT mode) with unconfigured disks work as HBAs and pass them through directly. As they're not flashed to IT mode, they should still work in the storage slot too. My own experience with and R610 and R710 with IR mode H200s in the storage slots and seemingly direct disk access seems to agree with this latter statement.

{% include footer.md %}
