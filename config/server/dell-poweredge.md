---
title: Dell PowerEdge Series
breadcrumbs:
- title: Configuration
- title: Server
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

## Firmware Updates

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

- Default credentials: User `root`, password `calvin`.
- Password recommendations:
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

For max performance, use two dual-rank 1333MHz DIMMS in slots 1 and 2 for all channels (12 DIMMS total). Earlier BIOS versions only supported one DIMM per channel for 1333MHz, as written in some outdated manuals.

## Storage

### General

- About flashing custom/non-Dell firmware:
    - Only do it if you know for sure you need it. This is often not required.
    - Many guides suggest installing custom/non-Dell firmware to support better (more direct) IT (HBA) mode and maybe some other features (like increasing queue depth).
    - Typically integrated (non-PCIe) cards don't support it.

### PERC 5 and 6

(Different generations but otherwise pretty similar.)

- The integrated version has the "/i" suffix.
- Does not support disks over 2TB.

### PERC H200

- The integrated version has the "i" suffix.
- Supports disks over 2TB if using newer firmware.
- Supports passthrough.
- May stop working in the storage slot (a special PCIe slot) if using other firmware.

### PERC H310 and H710

- The integrated non-blade version has the "mini mono" suffix.
- H310 supports passthrough while H710 does not.
- The H310 has bad queue depth, but for the PCIe version it can be fixed using other firmware.

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
