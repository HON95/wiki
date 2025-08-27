---
title: Dell PowerEdge Series
breadcrumbs:
- title: Computers
---
{% include header.md %}

## Management

- Default credentials: User `root`, password `calvin`.
- Password recommendations (mainly for older gens):
    - No special symbols and no spaces. Dash should be fine.
    - Case sensitivity is inconsistent, so always use lower-case.

## Tasks

### Firmware Updates

#### G11 and lower

There are lots of ways to upgrade the firmware, but most are painful and typically don't even work (e.g. loading firmware files in the Lifecycle Controller, Repository Manager custom ISOs, Repository Manager repositories, Repository Manager firmware files, and the Server Update Utility (SUU)). One way that *does* work is finding a pre-built bootable ISO and booting into it, but finding an ISO is getting harder.

##### Upgrading From Files Using System Services

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

#### G12 and Later

Update through iDRAC 7 using HTTP site `downloads.dell.com`.

### Reset iDRAC

In case you entered the wrong password to many times in the web GUI or something.

1. Log into the iDRAC using SSH (same credentials as web).
1. Enter RACADM: `racadm`
1. Reset iDRAC: `racadm racreset soft`
1. Wait.

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

## Fans

Mostly based on empirical evidence.

- Generally, the servers will attempt to adapt the fan speed to whatever hardware is used. To make is more silent, try to remove hardware you don't need.
- The number of DIMMs doesn't seem to affect the fan speed.
- For the R720, using 1600MHz DIMMs makes the server much louder than 1333MHz DIMMs.
- For the R620 and R720, using a 10G SFP+ NIC module makes it louder than using a 1G copper module.
- For the R320, using hard drives (non-Dell?) in the bays makes it much louder.

### Disable 3rd-party Device Fan Response (G13 and later?)

- This feature causes the fans to spin a bit faster when using 3rd-party PCIe devices, HDDs etc. It's annoying for homelabs. It can be disabled using IPMI.
- Check status: `ipmitool -I lanplus -H <IPADDRESS> -U <USERNAME> -P <PASSWORD> raw 0x30 0xce 0x01 0x16 0x05 0x00 0x00 0x00` (`... 01 00 00` means disabled)
- Enable fan response (default): `ipmitool -I lanplus -H <IPADDRESS> -U <USERNAME> -P <PASSWORD> raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00`
- Disable fan response (quiet): `ipmitool -I lanplus -H <IPADDRESS> -U <USERNAME> -P <PASSWORD> raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00`

## GPUs

### GPGPUs in R730

- Mounting GPUs requires GPU risers with power outlets (EPS-12V) and fan shroud with GPU airflow openings.
- Certain GPGPUs like K80, M40, M60, P100, V100 uses EPS-12V inlets instead of PCIe inlets like normal GPUs. This requires a special EPS-12V GPU cable and not one that converts the pinout to PCIe. This cable also needs to be mounted the correct way to avoid short-circuiting and probably melting/burning the cable. If your cable has the black wires on the "clip side" of the connector, it's probably a PCIe pinout and won't work. The end with all-yellows on one side of the connector and all-blacks on the other side goes into the GPU, while the connector with one black on the yellow side goes into the riser.

## Miscellanea

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
