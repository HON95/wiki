---
title: Juniper General
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

**TODO** Reorganize and add missing basic stuff.

### Related Pages
{:.no_toc}

- [Juniper EX Series Switches](../juniper-ex/)

### Disclaimer
{:.no_toc}
This page is based mainly on the devices/series I own.
Some content may be specific to those devices and should be moved away from this page.

## General Configuration

### Simple Actions

- Show the configuration: `show configuration [statement]`
    - The optional statement path is space-separated.
- Show alarms: `show chassis alarms`
- Show routing engine usage: `show chassis routing-engine`
- Shut down: `request system <halt|power-off>`
- Open shell: `request session member <vc-member-id>`
- Show interfaces:
    - L2/L3 overview: `show interfaces terse`

### Upgrading Junos Using a USB Drive

1. Format the USB drive using FAT32.
1. Copy the software file to the drive.
1. Mount it to `/var/tmp/flash` (see [mount a USB drive](#mount-a-usb-drive)).
1. Verify that the drive contains the software file: `ls -l /bar/tmp/flash`
1. (Optional) Copy the file to internal storage (`/var/tmp/`) before installing it.
1. Install: `request system software add <path> no-validate no-copy [partition] [reboot]`
    - If installing from internal storage, use the `partition` option.
    - If not using the `reboot` option, manually reboot afterwards.
1. Wait for the install to finish.
    - It may produce some minor errors in the process.
1. Validate it:
    - `show system storage partitions`
    - `show system snapshot media internal`
1. (Optional) Test that it's working.
1. Overwrite the alternate root partition: See [Copy the Active Root Partition](#copy-the-active-root-partition)

#### The Harder Way

If the method above did not work, try this instead to completely format and flash the device.

1. Prepare the USB drive like above.
1. Connect using a serial cable.
1. When the device is booting, press space at the right time.
1. Format and flash: `install --format file:///jinstall-whatever.tgz`

### Copy the Active Root Partition

This procedure clones the active partition to the alternate partition.
This is also how you would clone to and boot from a USB device, but with `media external` instead of `media internal` and `slice alternate`.

1. Clone the active partition to the alternate partition: `request system snapshot slice alternate`
    - This may not be completely finished when the command returns. If the below commands fail, wait and try again.
1. Validate it:
    - `show system storage partitions`
    - `show system snapshot media internal`
1. (Optional) Boot to the alternate partition: `request system reboot slice alternate media internal`

### Fix a Corrupt Root Partition

If one of the root partitions get corrupted (e.g. due to sudden power loss),
the device will boot to the alternate root partition.
This can be fixed by cloning the new active partition to the alternate, corrupt partition.

See [Copy the Active Root Partition](#copy-the-active-root-partition) or [[EX] Switch boots from backup root partition after file system corruption occurred on the primary root partition (Juniper)](https://kb.juniper.net/InfoCenter/index?page=content&id=KB23180).

### Mount a USB Drive

Note: USB3 drives may not work properly. Use USB2 drives.

1. Make sure the drive is formatted as FAT32 (MS-DOS) (or something else supported).
1. Don't insert it in the Juniper device yet.
1. Show current storage devices: `ls -l /dev/da*`
1. Insert the drive. It should print a few lines to the console.
1. Show current storage devices again and find the new device.
1. Create a dir to mount it to: `mkdir /vat/tmp/usb1`
1. Mount it: `mount_msdosfs <device> /var/tmp/usb1`
1. Do stuff with it.
1. Unmount it: `umount /dev/tmp/usb1`

## Theory

### About

- Based on FreeBSD.
- Used on all Juniper devices.
- Juniper's next-generation OS "Junos OS evolved" (not Junos OS) is based on Linux.

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

### The Configuration

- Hierarchical.
- Statements:
    - Container statements: Contains statements. Surround child statements in curly braces.
    - Leaf statements: Terminated with a semicolon.

### CLI Modes

- Shell: A CSH shell. Entered by default when logging in as root.
- CLI operational mode (op mode).
- CLI configuration mode (conf mode).

### Using the CLI

(Not the shell.)

- Space: Like tab, generally.
- Tab: Auto-complete.
- `?`: Prints the allowed keywords.
- `|`: Can be used to filter the output.
- Commit configuration changes: See commit section.

#### Configuration Mode

- Enter configuration mode: `configure`
- Exit configuration mode: `exit`
- Statements can be changed by either entering the container statement and changing it locally, or by specifying the full path for the statement.
- Enter the container statements: `edit <container-statement>`
    - Changes the local position in the hierarchy.
    - Multiple levels can be specified separated by space.
- Go up one level: `up`
- Go to the top: `top`
- Run operational command: `run <command>`
- Show configuration for current level: `show`

### Making Changes

Changes made in configuration mode are added to the candidate configuration and not immediately applied.
To apply the candidate configuration to the active configuration, commit the changes.

**TODO** which modes?

- Show changes: `show | compare`
- Commit the changes: `commit [comment <comment>] [confirmed] [and-quit]` (conf mode)
    - Try to always add a short comment.
    - `confirmed` automatically rolls back the commit if it is not confirmed within a time limit.
    - `and-quit` will quit configuration mode after a successful commit.

**TODO** Confirm how?

### Interface Names

- `lo`: Loopback.
- `ge`: Gigabit Ethernet.
- `xe`: 10G Ethernet.
- `et`: 40G Ethernet.
- `em` and `fxp`: Management, possibly OOB.

### Fusion

**TODO**

{% include footer.md %}
