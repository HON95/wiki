---
title: Dell PowerEdge Series
breadcrumbs:
- title: Configuration
- title: Machines
---
{% include header.md %}

### Using
{:.no_toc}

- 2950
- R310
- R610
- R710
- R320
- R620
- R720

## Firmware Upgrades

### G11 and lower

There are lots of ways to upgrade the firmware, but most are painful and typically don't even work (e.g. loading firmware files in the Lifecycle Controller, Repository Manager custom ISOs, Repository Manager repositories, Repository Manager firmware files, and the Server Update Utility (SUU)). One way that *does* work is finding a pre-built bootable ISO and booting into it, but finding an ISO is getting harder.

#### Upgrading From Files Using System Services

1. Download the file.
    - The one for Windows.
    - You may need to press "View full driver details" to find it on the Dell download pages.
1. Format a USB drive using the DOS partition table with one FAT32 partition. (**FIXME** Is DOS necessary?)
    - E.g. using `fdisk` and `mkfs.fat`.
1. Copy the file to it.
1. Connect it to the server.
1. Start System Services.
    - Press F10 when booting.
1. Go to Platform Update.
1. Select local drive, select the USB drive and enter the filename on the drive.
1. Success (maybe).

### G12 and higher

Update through iDRAC 7 using HTTP site `downloads.dell.com`.

## Management

- Password:
    - No special symbols and no spaces. Dash should be fine.
    - Case sensitivity is inconsistent, so always use lower-case.

## Memory

### R310

The R310 is super picky about memory and the manuals are (fom my experience) insufficient to figure out which types may be used can be used.
If it doesn't like it, it won't even boot.

Some configurations that work:
- 4x 8GB 4Rx8 PC3-8500R running at 800MHz.
- 2x 8GB 4Rx8 PC3-8500R running at 1067MHz.
- 2x 4GB 2Rx8 PC3-10600E running at 1333MHz.

Some configurations that DOESN'T work:
- 2x 4GB 2Rx4 PC3-10600R.

### R610 and R710

For max performance, use two dual-rank 1333MHz DIMMS in slots 1 and 2 for all channels (12 DIMMS total).
Earlier BIOS versions only supported one DIMM per channel for 1333MHz, as written in some outdated manuals.

## Storage

- PERC 5/i and 6/i do not support disks over 2TB. PERC H200 and similar needs to be flashed to a newer version to support it.
- Some say the PERC H200, H310, H310 mini etc. need to be flashed from IR (the default) to IT mode in order to pass through unconfigured disks directly instead of presenting them as individual RAID volumes and maybe adding proprietary headers on disk. ZFS (e.g.) needs direct access to the disks to work optimally, meaning you should flash it to IT mode if you intend to use the card as an HBA with ZFS or similar. This can cause the cards to no longer be accepted in the R610 and R710 PCIe-like storage slot and needs to use a normal PCIe slot instead. However, some say that IR cards (not flashed to IT mode) with unconfigured disks work as HBAs and pass them through directly. As they're not flashed to IT mode, they should still work in the storage slot too. My own experience with and R610 and R710 with IR mode H200s in the storage slots and seemingly direct disk access seems to agree with this latter statement.

## Power Efficiency

- C-states and C1E: May significantly reduce power usage when idle.

## Theory

### Model Name Convention

#### Generation 9 and Earlier

- Example: `2950`
- First digit: Class of server.
    - `1`: 1U server.
    - `2`: 2U server.
    - `6`: 4U server.
- Second figit: Generation.
- Third digit: Server type.
    - `0`: Tower.
    - `5`: Rack.
- Fourth digit:
    - `0`: Independent box.
    - `5`: Blade.

#### Generation 10 and Later

Includes three-digits model names only.
There are four-digit variants and other exceptions.

- Example: `R710`
- Letter:
    - `C`: Cloud.
    - `F`: Flexible.
    - `M/MX*`: Modular.
    - `R`: Rack.
    - `T`: Tower.
- First digit: Class of server.
    - `1-3`: 1 CPU.
    - `4-7`: Dual CPU.
    - `8`: Dual or quad CPU.
    - `9`: Quad CPU.
- Second digit: Generation, offset by 10.
- Third digit: Make of CPU.
    - `0`: Intel.
    - `5`: AMD.

{% include footer.md %}
