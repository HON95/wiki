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

- [Juniper Hardware](/config/network/juniper-hardware/)
- [Juniper Junos Switches](/config/network/juniper-junos-switches/)

## Info

### Junos OS

- Based on FreeBSD.
- Used on all Juniper devices.
- Juniper's next-generation OS "Junos OS evolved" (not "Junos OS") is based on Linux.

## General

**TODO** Cleanup.

### Usage

- Controlling the CLI:
    - Auto-complete: Tab or space.
    - Show allowed tokens/help: `?`
    - Pipe output: `<cmd> | <filter>`
    - Regex match output: `<cmd> | match <regex>`
    - Count lines (e.g. after matching): `<cmd> | count`
    - Watch command: `<cmd> | refresh <seconds>` (e.g. `show x | match y | refresh 5`)
    - Supports GNU readline (Emacs-like) keybinds (some examples below).
    - Jump to start or end of line: `Ctrl+A` (start) and `Ctrl+E` (end)
    - Cut or paste entire line: `Ctrl+U` (cut) and `Ctrl+Y` (paste)
    - Search command history: `Ctrl+R` + search
    - Copy last word from last command: `Meta+.` (typically `Alt+.`)
- Long outputs (less/more):
    - Long output is typically showed with less and supports less keybinds (use `h` for help).
    - Show long output without more hold: `<cmd> | no-more`
    - Jump to start or end: `g` (start) or `G` (end)
    - Search: `/` (forwards) or `?` (backwards)
    - Show only matching lines (supports regex): `m`
    - Clear searching etc.: `c`
- Help:
    - Show topic: `help topic <topic>`
    - Show reference: `help reference <reference>`
    - Show syslog symbol description: `help syslog <symbol>`
- Show general information:
    - Show time and uptime: `show system uptime`
    - Show version (and haiku): `show version [and haiku]`
    - Show RE/system resource usage: `show system processes brief`
- Open CLI in operational mode (from shell): `cli`
- Open shell (from op mode):
    - Local: `start shell user root`
    - VC: `request session member <vc-member-id>`
- CLI settings:
    - Show: `show cli`
    - Enable timestamp for commands: `set cli timestamp`
- Enter configuration mode (from op mode): `configure {<omit>|exclusive|private}`
    - By default, a shared config mode session is used where multiple users may edit the same candidate config. Be careful when committing in this mode to avoid accidentally applying changes from the other users.
    - Specify `exclusive` to avoid having other users make changes in config mode at the same time.
    - Specify `private` to start a separate/private config mode session, independent of other users. This is weird and rarely used.
    - **TODO** Certain restrictions of committing for exclusive mode.
- Exit any mode: `exit`
- Show configuration:
    - From (op mode): `show configuration [statement]`
    - From (conf mode): `show [statement]`
    - Show changes (conf mode): `show | compare`
    - Show as set-statements (op mode): `show configuration | display set`
    - Hide secret data: `show configuration | except SECRET-DATA`
    - Show commit log: `show system commit`
    - Show older config: `show system rollback <n>` (1 is the last etc.)
    - Compare active with older version: `show configuration | compare rollback <n>`
    - Compare two older versions: `show system rollback <n> compare <m>`
    - Show details and defaults: `show configuration | display detail` (add `| except "##$"` to omit empty comment lines)
    - Show with inherited properties from apply groups: `show | display inheritance`
- Config files:
    - Revisions: The most recent are stored in `/config/`, the rest (up to some count) are stored in `/var/db/config/`.
    - Configs are gzip-compressed.
    - The active configuration is `/config/juniper.conf.gz`.
- Run op command in config mode: `run <command>`
- Navigate config mode:
    - The config is structures as nested container statements and leaf statements.
    - Change context to container statement: `edit <path>`
    - Go up in context: `up` or `top`
    - Show configuration for current level: `show`
- Perform operation on multiple interfaces or similar: `wildcard range set int ge-0/0/[0-47] unit 0 family ethernet-switching` (example)
- Rename a config element: `rename <a> to <b>`
- Move config element to before another element: `insert <b> before <b>`
- Copy config element: `copy <a> to <b>`
- Delete config element: `delete <element>`
- Search and replace (global): `replace pattern <a> with <b>`
- Add comment to element: `annotate <element> "<comment>"`
- Deactivate element (instead of deleting it): `deactivate <element>`
    - Use `activate <...>` to undo.
- Prevent changes to element: `protect <element>`
    - Use `unprotect` to undo.
    - User privileges may be set such that certain users are not allowed to unprotect, as a sort of access control to certain config sections.
- Hide section for `show configuration`: Set `apply-flags omit` inside the section
    - Use `show configuration | display omit` to override and show omitted sections too.
- Commit config changes:
    - Commit candidate to active: `commit [comment <comment>] [confirmed <minutes>] [synchronize]`
    - `confirmed` automatically rolls back the commit if it is not confirmed within a time limit. Run `commit check` (or `commit` to also create a new commit) to confirm changes and prevent rollback.
    - `and-quit` will quit configuration mode after a successful commit.
    - `synchronize` will apply the change to all REs. It can be configured as the default.
    - Check without committing: `commit check`
    - Use `at <time>` to commit at a later time. Use `commit check` first to avoid config errors when it happens.
    - Rollback changes: Go to top level, `rollback <n>` (use `?` to show log), then commit
    - Discard changes in candidate config: `rollback 0`
- Apply groups:
    - Apply groups are a form of object-oriented templating.
    - The template/group are set under `groups <name>`.
    - They may use wildcards like `<ge-*>` instead of `ge-0/0/0` etc.
    - Apply the group to some section: `apply-groups <name>`
    - Avoid inheriting the group in some child section: `apply-groups-except <name>`
    - Local elements override the template.
    - Show config with inherited properties: `show | display inheritance`
- Apply path:
    - Used to reference a value from another element, e.g. to reference a singly defined IP address instead of specifying it every time.
    - Example: `set policy-options prefix-list RADIUS_SERVERS apply-path "system radius-server <*>"`
- Load changes (from terminal typically):
    - Load config section from terminal: `load merge terminal [relative]`, paste, `Ctrl+D` (`relative` for relative path)
    - Load set format (`set`'s and `delete`'s etc.): `load set terminal`, etc.
    - Load diff format (with config section, `+`'es and `-`'es etc.): `load patch terminal`, etc.
    - Delete all existing configuration while in config mode: `load override terminal`, then `Ctrl+D` without typing anything.
- Typical show command granularities (suffix):
    - `terse` (very brief)
    - `brief`
    - `detail`
    - `extensive` (very verbose)
- Send command output to remote (SCP or FTP, no TFTP): `<cmd> | save <destination>`
- Log:
    - Most stuff is logged in `/var/log/messages`
    - Some hardware stuff is logged in `/var/log/chassisd`.
    - Show other file: `show log <log>` (for file `/var/log/<log>`)
    - Show entered commands (if configured for syslog): `show log interactive-commands`
    - Show commit log: `show system commit`
    - Print log to console (tail-like): `monitor start` (stop with `monitor stop`)
- Show stats or monitor traffic:
    - Show traffic stats (general): `minotir interface <...>` (use keyboard shortcuts for bits/bytes, rate/delta, etc.)
    - Show stats for all interfaces: `minitor interface traffic`
    - Show stats for specific interfaces: `minitor interface <interface>`
    - Dump traffic: `monitor traffic interface <interface> <...>`
        - Example: `monitor traffic interface ge-0/0/4 no-resolve size 1500 matching "ip proto ospf"`
        - Only shows "local" traffic (to/from the system, not forwarded).
        - Supports standard tcpdump-like PCAP filtering as the (quoted) `matching` argument.
        - Write to PCAP file: `<...> write-file <file>`
- Files:
    - General file command: `file <...>`
    - The working directory is `/var/home/`.
    - Temporary stuff can be stores in `/var/tmp/` (not `/tmp/`, it's tiny).

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
- Show effective configuration (with inheritance): `show <configuration> | display inheritance`

### Move Config

- Copy config from host to device over SCP:
    1. Copy (host): `scp <config> <device>:/config/juniper.conf.new`
    1. Load (conf mode): `load override /config/juniper.conf.new`
    1. Show changes and commit.
    1. Delete tmp config (op mode): `file delete /config/juniper.conf.new`

### Interfaces

- Show interfaces:
    - Overview: `show interfaces terse`
    - Simple overview: `show interfaces routing`
    - Some details: `show interfaces brief`
    - Statistics: `show interfaces statistics`
    - All details: `show interfaces detail`
    - Physical details: `show interfaces media`
- Show LLDP neighbors: `show lldp neighbors`

### Events

- Show event type info: `help syslog SNMP_TRAP_LINK_DOWN` (op mode) (example)
- Show available event attributes: Use ?-completion.
- Show log: `run show log escript.log | last`

#### Info

- "Do not use the change-configuration statement to modify the configuration on dual Routing Engine devices that have nonstop active routing (NSR) enabled, because both Routing Engines might attempt to acquire a lock on the configuration database, which can cause the commit to fail." (From docs.)

### Version Names

- Example: `20.4R3-S1.3`
- Format: `<year>.<quarter>[R1-3][-S...]`
- There is one main release for each quarter of the year. They may be a bit delayed such that they don't perfectly match the quarter.
- There are zero to three extra cumulative bug patches `R1` to `R3` (no suffix for the initial release).
- Each release is supported for exactly three years.

### Miscellanea

- Set `system auto-snapshot` on single-flash devices to make them automatically rebuild the alternate partition in case of corruption.

## Tasks

### Reset Root Password

1. Power on the device and prepare for the next step.
1. Press space quickly as the "Hit \[Enter\] to boot immediately, or space bar for command prompt." message is shown (right before the kernel is loaded). You should immediately enter a `loader>` prompt.
1. Run `boot -s` to boot into single-user mode.
1. When prompted for a shell, enter `recovery`.
1. Wait for the device to fully boot.
1. (Alternative 1) Zeroize the system by running `request system zeroize` (this will delete all configuration).
1. (Alternative 2) Set a new root password and commit (there should be instructions before the prompt). Reboot the device afterwards.

### Mount a USB Drive

Note: USB3 drives may not work properly. Use USB2 drives.

1. Make sure the drive is formatted as FAT32 (MS-DOS) (or something else supported).
1. Don't insert it in the Juniper device yet.
1. Show current storage devices: `ls -l /dev/da*`
1. Insert the drive. It should print a few lines to the console.
1. Show current storage devices again and find the new device.
1. Mount it: `mkdir /var/tmp/usb0 && mount_msdosfs <device> /var/tmp/usb0` (arbitrary path)
1. Check that it's mounted properly: `ls -l /var/tmp/usb0`
1. Do stuff with it.
1. Unmount it: `umount /var/tmp/usb0 && rmdir /var/tmp/usb0`

### Upgrade Junos

#### Normal Method

1. Backup and clean system:
    1. Remove old files: `request system storage cleanup [dry-run]` (`dry-run` to show only)
    1. Create a system backup first (unless virtualized boxes like EX4600 and QFX5100): `request system snapshot` (maybe with `slice alternate`, depending on the box)
    1. Show system backups: `show system snapshot [media internal]`
1. Get the file: `file copy <remote-url> /var/tmp/`
        - If it says it ran out of space, add `staging-directory /var/tmp`. By defaults it's buffered on the root partition, which may be tiny.
        - Alternatively, copy the file _into_ the device from the remote device.
1. Prepare upgrade: `request system software add <file>`
    - Add `no-copy unlink` to remove the file afterwards, typically for systems with little free space.
    - Add `reboot` to automatically reboot and begin upgrade.
1. Reboot and start upgrade (may take around 5 minutes): `request system reboot`
1. **TODO** See further instructions in USB drive method section for verification and copying to alternate partition.


#### ISSU and NSSU

- ISSU and NSSU may be used for upgrade without downtime, if the hardware supports it.
- If using redundant hardware (multiple REs), ISSU may be use for upgrades without downtime. It may blow up. One RE is upgraded first, then state is transferred to it. Normal upgrade with reboot is more reliable if short downtime is acceptable.
- If using virtual chassis, NSSU is similar to ISSU but doesn't require the same kind of state sync.

#### Using a USB Drive

1. Format the USB drive using FAT32.
1. Copy the software file to the drive.
1. Mount the USB drive:
    - TL;DR: `mkdir /var/tmp/usb0 && mount_msdosfs <device> /var/tmp/usb0`
    - See [mount a USB drive](#mount-a-usb-drive).
1. Check the contents: `ls -l /var/tmp/usb0`
1. Copy the file to internal storage: `cp /var/tmp/usb0/jinstall* /var/tmp/`
1. Unmount and remove the USB drive: `umount /var/tmp/usb0 && rmdir /var/tmp/usb0`
1. Enter op CLI: `cli`
1. Install: `request system software add <file> no-copy reboot`
    - If it complains about certificate problems, consider disabling verification using `no-validate`.
    - It will reboot before and after.
    - It may produce some insignificant errors in the process (commands not found etc.).
1. Verify that the system is booted from the active partition of the internal media: `show system storage partitions`
1. Verify that the current Junos version for the primary partition is correct: `show system snapshot media internal`
1. Copy to the alternate root partition (may take several minutes): `request system snapshot slice alternate`
1. Verify that the primary and backup partitions have the same Junos version: `show system snapshot media internal`
    - If it fails, wait a bit and try again. The copy may still be happening.

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
