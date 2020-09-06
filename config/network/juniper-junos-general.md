---
title: Juniper Junos General
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

**TODO** Clean up, reorganize and add remaining stuff.

### Related Pages
{:.no_toc}

- [Juniper Hardware](../juniper-hardware/)
- [Juniper Junos Switches](../juniper-junos-switches/)

## Info

- Based on FreeBSD.
- Used on all Juniper devices.
- Juniper's next-generation OS "Junos OS evolved" (not Junos OS) is based on Linux.

## General

### Usage

- Controlling the CLI:
    - Tab: Auto-complete.
    - Space: Like tab, generally.
    - `?`: Prints the allowed keywords.
    - `|`: Can be used to filter the output.
- Open CLI in operational mode (from shell): `cli`
- Open shell (from oper mode):
    - Local: `start shell`
    - VC: `request session member <vc-member-id>`
- Enter configuration mode (from oper mode): `configure`
- Exit any mode: `exit`
- Show configuration:
    - From oper mode: `show configuration [statement]`
    - From config mode: `show [statement]`
    - Show changes: `show | compare`
- Run oper command in config mode: `run <command>`
- Navigate config mode:
    - The config is structures as nested container statements and leaf statements.
    - Change context to container statement: `edit <path>`
    - Go up in context: `up` or `top`
    - Show configuration for current level: `show`
- Commit config changes: `commit [comment <comment>] [confirmed] [and-quit]`
    - `confirmed` automatically rolls back the commit if it is not confirmed within a time limit.
    - `and-quit` will quit configuration mode after a successful commit.

### Booting

The devices have two partitions; the primary and the backup.
One of them will be designated as active and that choice will be remembered across reboots.
When the active partition is damaged, the device will boot into the other partition.
When the backup partition is the active partition, an alarm will be set and a banner shown.

Change active partition and reboot: `request system reboot slice alternate media internal`

### Shutting It Down

The devices should be shut down gracefully instead of just pulling the power.
This will prevent corrupting the file system.

- Shell: `shutdown -h now` or `halt`
- Op mode: `request system <halt|power-off> [local|all-members|member <member-id>]`

Wait for the "The operating system has halted." text before pulling the power, so that system processess are stopped and disks are synchronized. The system LED turning off and the LCD saying "HALTING..." does *not* mean that the halting process is finished yet.

### Basics

- Shut down or reboot: `request system <halt|reboot> [local|all-members]`
    - For `halt`, it will print "please press any key to reboot" when halted.
- Erase all configuration and data: `request system zeroize`
- Show alarms: `show chassis alarms`
- Show temperatures and fan speeds: `show chassis environment`
- Show routing engine usage: `show chassis routing-engine`

### Interfaces

- Show interfaces:
    - Overview: `show interfaces terse`
    - Simple overview: `show interfaces routing`
    - Some details: `show interfaces brief`
    - Statistics: `show interfaces statistics`
    - All details: `show interfaces detail`
    - Physical details: `show interfaces media`
- Show LLDP neighbors: `show lldp neighbors`

## Tasks

### Mount a USB Drive

Note: USB3 drives may not work properly. Use USB2 drives.

1. Make sure the drive is formatted as FAT32 (MS-DOS) (or something else supported).
1. Don't insert it in the Juniper device yet.
1. Show current storage devices: `ls -l /dev/da*`
1. Insert the drive. It should print a few lines to the console.
1. Show current storage devices again and find the new device.
1. Create a dir to mount it to: `mkdir /var/tmp/usb1`
1. Mount it: `mount_msdosfs <device> /var/tmp/usb1`
1. Do stuff with it.
1. Unmount it: `umount /dev/tmp/usb1`

### Upgrade Junos Using a USB Drive

1. Format the USB drive using FAT32.
1. Copy the software file to the drive.
1. Mount it to `/var/tmp/flash` (see [mount a USB drive](#mount-a-usb-drive)).
1. Verify that the drive contains the software file: `ls -l /var/tmp/flash`
1. (Optional) Copy the file to internal storage (`/var/tmp/`) before installing it.
1. Install (oper mode): `request system software add <file> no-validate no-copy [partition] [reboot]`
    - If installing from internal storage, use the `partition` option.
    - If not using the `reboot` option, manually reboot afterwards to start the install.
1. Wait for the install to finish.
    - It will reboot first.
    - It may produce some insignificant errors in the process (commands not found etc.).
1. Verify that the system is booted from the active partition of the internal media: `show system storage partitions`
1. Unmount and remove the USB drive.
1. Copy to the alternate root partition: `request system snapshot slice alternate`
    - May take several minutes.
1. Verify that the active and backup partitions have the same Junos version: `show system snapshot media internal`
    - If this fails, wait a bit and try again. The copy may still be processing.

If the method above did not work, try this instead to completely format and flash the device.

1. Prepare the USB drive like above.
1. Connect using a serial cable.
1. When the device is booting, press space at the right time.
1. Format and flash: `install --format file:///jinstall-whatever.tgz`

### Copy the Active Root Partition

This procedure clones the active partition to the alternate partition.
This is also how you would clone to and boot from a USB device, but with `media external` instead of both `media internal` and `slice alternate`.

1. Clone the active partition to the alternate partition: `request system snapshot slice alternate`
    - This may not be completely finished when the command returns. If the below commands fail, wait and try again.
1. Validate it:
    - `show system storage partitions`
    - `show system snapshot media internal`

To boot to the alternate partition, use `request system reboot slice alternate media internal`.

### Fix a Corrupt Root Partition

If one of the root partitions get corrupted (e.g. due to sudden power loss),
the device will boot to the alternate root partition.
This can be fixed by cloning the new active partition to the alternate, corrupt partition.

See [Copy the Active Root Partition](#copy-the-active-root-partition) or [[EX] Switch boots from backup root partition after file system corruption occurred on the primary root partition (Juniper)](https://kb.juniper.net/InfoCenter/index?page=content&id=KB23180).

## Miscellanea

### Interface Names

- `lo`: Loopback.
- `ge`: Gigabit Ethernet.
- `xe`: 10G Ethernet.
- `et`: 40G Ethernet.
- `em` and `fxp`: Management, possibly OOB.

## Fusion

**TODO**

{% include footer.md %}
