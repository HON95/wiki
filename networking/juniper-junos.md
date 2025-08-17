---
title: Juniper Junos OS
breadcrumbs:
- title: Networking
---
{% include header.md %}

**TODO** Clean up, reorganize and add remaining stuff.

## Resources

- [Day One Books (Juniper)](https://www.juniper.net/documentation/jnbooks/us/en/day-one-books)
- [Introduction to Junos – Part 1 (Packet Pushers)](https://packetpushers.net/introduction-to-junos-part-1/)
- [Introduction to Junos – Part 2 (Packet Pushers)](https://packetpushers.net/introduction-to-junos-part-2/)

### Initial Setup

Common setup for MX, SRX, QFX, EX.

1. Connect to the switch using serial:
    - RS-232 w/ RJ45, baud 9600, 8 data bits, no parity, 1 stop bits, no flow control.
1. Log in:
    1. It should say "Amnesiac" above the login prompt as the name of the switch, to show that it's factory reset.
    1. Login as `root` with no password to enter the shell.
    1. Enter the Junos operational CLI by typing `cli`.
1. (EX) (Optional) Free virtual chassis ports (VCPs) for normal use:
    1. Enter op mode.
    1. Show VCPs: `show virtual-chassis vc-port`
    1. Remove VCPs: `request virtual-chassis vc-port delete pic-slot <pic-slot> port <port-number>`
    1. Show again to make sure they disappear. This may take a few seconds.
1. (Note) Enter configuration mode:
    - Enter: `configure`
    - Commit: `commit`
    - Exit: `exit`
1. Set host name:
    1. `set system host-name <host-name>`
    1. `set system domain-name <domain-name>`
1. (Not MX) Enable auto snapshotting and restoration on corruption:
    1. `set system auto-snapshot`
1. Disable DHCP auto image upgrade:
    1. `delete chassis auto-image-upgrade`
1. Set new root password:
    1. `set system root-authentication plain-text-password` (prompts for password)
1. Set idle timeout:
    1. `set system login idle-timeout 60` (60 minutes)
1. (Optional) Commit new config:
    1. `commit`
1. Setup a non-root user:
    1. `set system login user <user> [full-name <full-name>] class super-user authentication plain-text-password` (prompts for password)
1. (SRX) Enable IPv6 forwarding (SRX):
    1. Enable: `set security forwarding-options family inet6 mode flow-based`
    1. (Info) Verify (after commit): `show security flow status`
1. Setup SSH:
    1. Enable server: `set system services ssh`
    1. Disable root login from SSH: `set system services ssh root-login deny-password`
    1. (Note) Do *not* use `ssh root-login deny`, it may cause FPCs to go unresponsive and offline for Junos v21 and later ([link](https://prsearch.juniper.net/problemreport/PR1629943)).
1. (Maybe) Disable licensing and phone-home (for grey-market devices):
    1. `delete system license`
    1. `delete system phone-home`
1. Set DNS servers:
    1. Delete default: `delete system name-server`
    1. Set new (for each one): `set system name-server <addr>`
1. Set time:
    1. Set time zone: `set system time-zone Europe/Oslo` (example)
    1. (Optional) Set time manually (UTC): `run set date <YYYYMMDDhhmm.ss>`
    1. (Deprecated) Set server to use while booting (forces initial time): `set system ntp boot-server <address>`
    1. Set server to use periodically (for tiny, incremental changes): `set system ntp server <address>`
    1. (Info) After committing, use `show ntp associations` to verify NTP.
    1. (Info) After committing, use `set date ntp` to force it to update. This may be required if the delta is too large and the NTP client refuses to update.
1. Set misc system options:
    1. Setup loopback as default address: `set system default-address-selection`
    1. Enable PMTUD: `set system internet-options path-mtu-discovery`
1. Configure LLDP:
    1. (Optional) Enable for all interfaces: `set protocols lldp interface all`
    1. (Optional) Enable for specific interfaces: `set protocols lldp interface xe-0/1/0`
    1. (Optional) Disable for specific interfaces: `set protocols lldp interface xe-0/1/0 disable`
1. Configure SNMP:
    1. (Info) SNMP is extremely slow on the Juniper devices I've tested it on.
    1. Enable public RO access (or generate a secret community string): `set snmp community public authorization read-only`
1. (Optional) Set loopback addresses (if using routing):
    1. `set interfaces lo0.0 family inet address <address>/32`
    1. `set interfaces lo0.0 family inet6 address <address>/32`
1. (Optional) Setup static IP routes (if not using dynamic routing):
    1. IPv4 default gateway: `set routing-options rib inet.0 static route 0.0.0.0/0 next-hop <next-hop>`
    1. IPv6 default gateway: `set routing-options rib inet6.0 static route ::/0 next-hop <next-hop>`
    1. (Optional) Setup null routes for site prefixes.
1. Disable management port link-down alarm:
    1. Disable alarm: `set chassis alarm management-ethernet link-down ignore`
1. Disable management port:
    1. (Note) This port goes by many names: `fxp0`, `me0`, `em0`, `em1`, `vme`, ...
    1. Delete interface: `delete int <port>`
    1. Disable interface: `set int <port> disable`
    1. (If exists) Disable RA: `delete protocols router-advertisement interface <port>.0`
1. (Optional) Set PIC interface speed/mode (if applicable):
    1. (Info) E.g. the device has 40G/100G ports and you need to configure the ports for them to show up in `sh int terse`.
    1. (Info) Some devices have a maximum capacity that can't be oversubscribes, e.g. 400G for the MX204.
    1. Show FPCs and PICs: `run show chassis fpc pic-status`
    1. Set speed (example): `set chassis fpc 0 pic 0 port 0 40g`
1. (EX/QFX/SRX) Create VLANs:
    1. Create: `set vlans <name> vlan-id <VID>`
    1. (Optional) Set RVI: `set vlans <name> l3-interface irb.<VID>`
1. Setup interfaces: See section below.
1. (EX/QFX/SRX) Configure RSTP:
    - (Note) RSTP is enabled for all interfaces by default.
    - Enter config section: `edit protocols rstp`
    - Set interfaces: `set interfaces all` (example)
    - Set priority: `set bridge-priority <priority>` (default 32768/32k, should be a multiple of 4k, use e.g. 32k for access, 8k for distro and 4k for core)
    - (Optional) Set hello time: `set hello-time <seconds>` (default 2s)
    - (Optional) Set maximum age: `set max-age <seconds>` (default 20s)
    - (Optional) Set forward delay: `set forward-delay <seconds>` (default 15s)
    - Set edge ports: `wildcard range set protocols rstp interface ge-0/0/[2-5] edge` (example)
    - Enable BPDU guard on all edge ports: `set protocols rstp bpdu-block-on-edge`
1. (SRX) Setup security stuff (zones, policies, NAT, screens).
    1. `delete security`
    1. Setup as desired.
1. Commit configuration: `commit [confirmed]`
1. Exit config CLI: `exit`
1. Save the rescue config: `request system configuration rescue save`
1. (SRX) Save the autorecovery info: `request system autorecovery state save`
1. (SRX) Reboot the device to change forwarding mode and stuff (if changed): `request system reboot`

#### Interfaces

1. (Optional) Delete default interfaces configs (example):
    1. `wildcard range delete interface ge-0/0/[0-7]`
1. (EX/QFX/SRX) (Optional) Disable default VLAN RVI:
    1. (Note) The interface is called `vlan` for older devices and `irb` for newer ones.
    1. Delete config: `delete int irb.0`
    1. Disable: `set int irb.0 disable`
1. (Optional) Disable unused interfaces (example):
    1. `wildcard range set interface ge-0/0/[0-7] disable`
    1. `set interface cl-1/0/0 disable`
    1. `set interface dl0 disable`
1. Set up port channelization (breakout ports):
    1. Should happen automatically, but not always. Not all quad ports support port channelization.
    1. Manually set breakout ports: `set chassis fpc 0 pic 0 port 48 channel-speed 10g ` (example)
1. (Optional) Setup interface-ranges (apply config to multiple configured interfaces):
    - Declare range: `edit interfaces interface-range <name>`
    - Add member ports: `member-range <begin-if> to <end-if>`
    - Configure it as a normal interface, which will be applied to all members.
1. (Optional) Setup LACP toward upstream/downstream switch:
    1. (Info) Make sure you allocate enough LAG interfaces and that the interface numbers are below some arbitrary power-of-2-limit for the device model. Maybe the CLI auto-complete shows a hint toward the max.
    1. Set number of available LAG interfaces: `set chassis aggregated-devices ethernet device-count <0-64>`
    1. Delete old configs for member interface: `wildcard range delete interfaces ge-0/0/[0-1]` (example)
    1. Add member interfaces: `wildcard range set interfaces ge-0/0/[0-1] ether-options 802.3ad ae<n>`
    1. Add some description to member interfaces: `wildcard range set interfaces ge-0/0/[0-1] description link:switch`
    1. Enter LAG interface: `edit interface ae<n>`
    1. Set description: `set desc link:switch`
    1. Set LACP active: `set aggregated-ether-options lacp active`
    1. Set LACP fast: `set aggregated-ether-options lacp periodic fast`
    1. (Optional) Set minimum links: `aggregated-ether-options minimum-links 1`
1. (EX/QFX/SRX) Setup switch trunk ports:
    1. (Note) `vlan members` supports both numbers and names. Use the `[VLAN1 VLAN2 <...>]` syntax to specify multiple VLANs.
    1. (Note) Instead of specifying which VLANs to add, specify `vlan members all` and `vlan except <excluded-VLANs>`.
    1. (Note) `vlan members` should not include the native VLAN (if any).
    1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
    1. Set mode: `set port-mode trunk`
    1. Set VLANs: `set vlan members <VLANs>`
    1. (Optional) Set native VLAN: `set native-vlan-id <VID>`
1. (EX/QFX/SRX) Setup access ports:
    1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
    1. Set access VLAN: `set vlan members <VLAN-name>`
1. (EX/QFX/SRX) Setup VLAN L3 interfaces:
    1. (VLAN) Set L3-interface: `set vlans <name> l3-interface irb.<VID>`
    1. Enter unit 0 of physical/LACP interface or `irb.<VID>` for VLAN interfaces.
    1. Set IPv4 address: `set family inet address <address>/<prefix-length>`
    1. Set IPv6 address: `set family inet6 address <address>/<prefix-length>`
1. (Optional) Disable/enable Ethernet flow control:
    - (Note) Junos uses the symmetric/bidirectional PAUSE variant of flow control.
    - (Note) This simple PAUSE variant does not take traffic classes (for QoS) into account and will pause _all_ traffic for a short period (no random early detection (RED)) if the receiver detects that it's running out of buffer space, but it will prevent dropping packets _within_ the flow control-enabled section of the L2 network. Enabling it or disabling it boils down to if you prefer to pause (all) traffic or drop (some) traffic during congestion. As a guideline, keep it disabled generally (and use QoS or more sophisticated variants instead), but use it e.g. for dedicated iSCSI networks (which handle delays better than drops). Note that Ethernet and IP don't require guaranteed packet delivery.
    - (Note) It _may_ be enabled by default, so you should probably enable/disable it explicitly (the docs aren't consistent with my observations).
    - (Note) Simple/PAUSE flow control (`flow-control`) is mutually exclusive with priority-based flow control (PFC) and asymmetric flow control (`configured-flow-control`).
    - Disable on Ethernet interface (explicit): `set interface <if> [aggregated-]ether-options no-flow-control`
    - Enable (explicit): `... flow-control`
1. (Optional) Enable EEE (Energy-Efficient Ethernet, IEEE 802.3az):
    - (Note) For reducing power consumption during idle periods. Supported on RJ45 copper ports.
    - (Note) There generally is no reason to not enable this on all ports, however, there may be certain devices or protocols which don't play nice with EEE (due to poor implementations).
    - Enable on RJ45 Ethernet interface: `set interface <if> ether-options ieee-802-3az-eee`

## Commands

**TODO** Cleanup. Combine with SRX- and QFX-setup?

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
    - Show system resource usage: `show system processes brief`
    - Show RE info and usage: `show chassis routing-engine`
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
    - (Note) You can only see config elements and changes you have permissions to see. Chekc the `system login` section to check.
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
- Ping:
    - Basic: `ping <target> [options]`
    - Specify source: `... source <address>`
    - Send rapidly: `... rapid`
    - Set count: `... count <n>`
    - Set payload size: `... size <n>` (might fragment, max ICMPv4 size is MTU minus 28)
    - Avoid fragmentation: `... do-not-fragnent`
    - Change hashing to debug LAG interfaces: `... pattern <something>`
    - Etc.
- Traceroute: `traceroute [monitor] <target>`
- Show stats:
    - Show traffic stats (general): `minitor interface <...>` (use keyboard shortcuts for bits/bytes, rate/delta, etc.)
    - Show stats for all interfaces: `minitor interface traffic`
    - Show stats for specific interfaces: `minitor interface <interface>`
- Dump traffic:
        - Basic: `monitor traffic interface <interface> [...]`
        - Example: `monitor traffic interface ge-0/0/4 no-resolve size 1500 count 20 matching "ip proto ospf"`
        - Only shows "local" traffic (to/from the system, not forwarded).
        - Supports standard tcpdump-like PCAP filtering as the (quoted) `matching` argument.
        - Write to PCAP file: `<...> write-file <file>`
- Files:
    - General file command: `file <...>`
    - The working directory is `/var/home/`.
    - Temporary stuff can be stores in `/var/tmp/` (not `/tmp/`, it's tiny).
- Scripting:
    - Supports events like scheduled actions.
    - Supports XML scripting. And Python for newer devices.
    - Supports commit scripts to e.g. require descriptions on interfaces.

### Port Mirroring (SPAN)

- SRX: [How to do port mirroring on J-series and SRX branch devices](https://supportportal.juniper.net/s/article/How-to-do-port-mirroring-on-J-series-and-SRX-branch-devices?language=en_US)
- EX: [Configuring Port Mirroring and Analyzers](https://www.juniper.net/documentation/us/en/software/junos/network-mgmt/topics/topic-map/port-mirroring-and-analyzers-configuring.html#id-configuring-port-mirroring-to-analyze-traffic-cli-procedure#id-configuring-port-mirroring-to-analyze-traffic-cli-procedure)

### Booting

The devices have two partitions; the primary and the backup.
One of them will be designated as active and that choice will be remembered across reboots.
When the active partition is damaged, the device will boot into the other partition.
When the backup partition is the active partition, an alarm will be set and a banner shown.

Change active partition and reboot: `request system reboot slice alternate media internal`

### Shutting It Down

The devices should be shut down gracefully instead of just pulling the power.
This will prevent corrupting the file system.

- Oper CLI: `request system <halt|power-off> [local|all-members|member <member-id>]`
- Shell: `shutdown -h now` or `halt`

Wait for the "The operating system has halted." text before pulling the power, so that system processess are stopped and disks are synchronized. The system LED turning off and the LCD saying "HALTING..." does *not* mean that the halting process is finished yet.

### Basics

**TODO** Move this.

- Shut down or reboot: `request system <halt|reboot> [local|all-members]`
    - For `halt`, it will print "please press any key to reboot" when halted.
- Erase all data and reboot fresh: `request system zeroize`
- Show system alarms: `show system alarms`
- Show chassis alarms: `show chassis alarms`
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
- Show switching/VLAN details for interface: `show ethernet-switching interface`
- Show LLDP neighbors: `show lldp neighbors`
- Show DHCP client:
    - Show binding: `show dhcp client binding`
    - Show stats: `show dhcp client statistics`

### IPv6 Neighbor Discovery (ND)

- Disallow solicitations from remote prefixes (config): `set protocols neighbor-discovery onlink-subnet-only`

### DHCPv4 Server

- Note that newer Junos versions use a different DHCP setup (JDHCP), with pool settings inside `access address-asignment`.
- Show clients: `show dhcp server binding`
- Show client detauls: `show dhcp server binding <address> detail`
- Show stats: `show dhcp server statistics`

### Events

- Show event type info: `help syslog SNMP_TRAP_LINK_DOWN` (op mode) (example)
- Show available event attributes: Use ?-completion.
- Show log: `run show log escript.log | last`
- From docs: "Do not use the change-configuration statement to modify the configuration on dual Routing Engine devices that have nonstop active routing (NSR) enabled, because both Routing Engines might attempt to acquire a lock on the configuration database, which can cause the commit to fail."

### Rescue Configuration

- The rescue config is a copy of the config, which the system attempts to use if it detects that the main config is corrupted.
- Show rescue config: `show system configuration rescue`
- Save current committed config to rescue config: `request system configuration rescue save`
- Delete rescue config: `request system configuration rescue delete`
- Rollback to rescue config (config CLI): `rollback rescue`

### Autorecovery

- Only supported in some dual-partitioned with newer software.
- Shows an alarm about autorecovery information that needs to be saved if you're configuring a factory reset device.
- Autorecovery stores disk partitioning, configuration and license information, then validates and attempts to recover corruption during bootup.
- Show autorecovery status: `show system autorecovery state`
- Save autorecovery info: `request system autorecovery state save`
- Delete autorecovery info: `request system autorecovery state clear`

### Miscellanea

- Set `system auto-snapshot` on single-flash devices to make them automatically rebuild the alternate partition in case of corruption.

## Tasks

### Reset Config or Root Password

1. Power on the device and prepare for the next step.
1. Wait for the "Hit \[Enter\] to boot immediately, or space bar for command prompt." message to be shown and then press space. You should immediately enter a prompt (typically `loader>`).
1. Run `boot -s` to boot into single-user mode.
1. When prompted for a shell, enter `recovery`.
1. Wait for the device to fully boot.
1. (Alternative 1) Zeroize the system by running `request system zeroize` (this will delete all configuration).
1. (Alternative 2) Set a new root password and commit (there should be instructions before the prompt). Reboot the device afterwards.

### Mount a USB Drive

Note: USB3 drives may not work properly. Use USB2 drives.

1. Make sure the drive is MBR-partitioned and that the partition is formatted as FAT32 (`mkfs.fat -F32`).
1. To make it easier to find the device path in Junos, don't insert the USB drive just yet.
1. Show current storage devices: `ls -l /dev/da*`
1. Insert the drive. It should print a few lines to the console.
1. Show current storage devices again and find the new device. (`df -h` may also be used to see which one is in use.)
1. Mount it: `mkdir /var/tmp/usb0 && mount_msdosfs <device> /var/tmp/usb0` (arbitrary path)
1. Check that it's mounted properly: `ls -l /var/tmp/usb0`
1. Do stuff with it.
1. Unmount it: `umount /var/tmp/usb0 && rmdir /var/tmp/usb0`

### Upgrade Junos

#### Normal Method

This should work in most cases and is the most streamlined version, but may not work for major version hops and stuff.

1. (Info) For virtualized boxes like EX4600 and QFX5100, skip the `request system snapshot` parts as these boxes are built differently wrt. Junos.
1. Cleanup old files: `request system storage cleanup`
    - Do this *before* mounting the USB or downloading the files, as the upgrade files may get wiped.
1. Make sure the alternate partition contains a working copy of the current version: See [Validate the Partitions](#validate-the-partitions).
1. If downloading from a remote location:
    1. Get the file: `file copy <remote-url> /var/tmp/`
        - If it says it ran out of space, add `staging-directory /var/tmp`. By defaults it's buffered on the root partition, which may be tiny.
        - Alternatively, copy the file _into_ the device from the remote device, using SCP.
1. If copying from a USB drive:
    1. Format the USB drive using FAT32 and copy the software file to the drive.
    1. Enter shell mode on the device: `start shell user root`
    1. Mount the USB drive: `mkdir /var/tmp/usb0 && mount_msdosfs /dev/da1s1 /var/tmp/usb0`
        - See [mount a USB drive](#mount-a-usb-drive) for details.
    1. Check the contents (copy the filename for later): `ls -l /var/tmp/usb0`
    1. Copy the file to internal storage: `cp /var/tmp/usb0/jinstall* /var/tmp/`
    1. Unmount and remove the USB drive: `umount /var/tmp/usb0 && rmdir /var/tmp/usb0`
    1. Enter operational CLI again: `exit` (or `cli`)
1. Prepare upgrade: `request system software add /var/tmp/<file> no-copy unlink reboot [no-validate] [force-host]` (supports auto-complete)
    - `no-copy` prevents copying the file first (in this case it's pointless).
    - `unlink` removes the file afterwards.
    - `reboot` reboots the device, so the upgrade can begin when booting.
    - If it complains about certificate problems, consider disabling verification using `no-validate`.
    - For virtualized devices, add `force-host` to upgrade the host too.
    - If the date is significantly wrong on the device and NTP isn't used/synced, set it manually with `set date <YYYYMMDDhhmm>` first so validation doesn't fail.
    - It may produce some insignificant errors in the process (commands not found etc.).
1. See [Validate the Partitions](#validate-the-partitions) to copy the upgraded partition to the other partition.

#### From the Loader

If the normal method did not work, try this instead.

1. Copy the file to the device disk using the "normal" USB method.
1. Connect using a serial cable.
1. Reboot the device and press space at the right time to enter the loader.
    - The message to wait for should look like this: `Hit [Enter] to boot immediately, or space bar for command prompt.`
1. Format and flash: `install --format file:///jinstall-whatever.tgz` (with correct name, no `/var/tmp/`)
1. See [Validate the Partitions](#validate-the-partitions) to copy the upgraded partition to the other partition.

#### Validate the Partitions

Do this before as a check and after to make sure the new image is working and copied to both partitions.

1. Log into the CLI.
1. Verify that the system is booted from the active partition of the internal media: `show system storage partitions` (should show `Currently booted from: active`)
1. Verify that the current Junos version for the *primary* partition is correct: `show system snapshot media internal`
1. Copy to the alternate root partition, so both have the same version (may take several minutes): `request system snapshot slice alternate`
1. Verify that the primary and backup partitions have the same Junos version: `show system snapshot media internal`
    - If the command fails, wait a bit and try again. The copy may still be happening in the background.
1. (Info) To boot from the alternative partition: `request system reboot slice alternate media internal`

#### ISSU and NSSU

Just info, no instructions here.

- ISSU and NSSU may be used for upgrade without downtime, if the hardware supports it.
- If using redundant hardware (multiple REs), ISSU may be use for upgrades without downtime. It may blow up. One RE is upgraded first, then state is transferred to it. Normal upgrade with reboot is more reliable if short downtime is acceptable.
- If using virtual chassis, NSSU is similar to ISSU but doesn't require the same kind of state sync.

### Fix a Corrupt Root Partition

If one of the root partitions get corrupted (e.g. due to sudden power loss),
the device will boot to the alternate root partition.
This can be fixed by cloning the new active partition to the alternate, corrupt partition.

See [Validate the Partitions](#validate-the-partitions) or [[EX] Switch boots from backup root partition after file system corruption occurred on the primary root partition (Juniper)](https://kb.juniper.net/InfoCenter/index?page=content&id=KB23180).

## Info

### Junos OS

- Based on FreeBSD.
- Used on all Juniper devices.
- Juniper's next-generation OS "Junos OS evolved" (not "Junos OS") is based on Linux.

### Versions

- Example: `20.4R3-S1.3`
- Format: `<year>.<quarter>[R1-3][-S...]`
- There is one main release for each quarter of the year. They may be a bit delayed such that they don't perfectly match the quarter.
- There are zero to three extra cumulative bug patches `R1` to `R3` (no suffix for the initial release).
- Each release is supported for exactly three years.

### Interfaces

Interface name structure:

- Physical interfaces:
    - Format: `<type>-<fpc>/<pic>/<port>`
    - Example: `ge-0/0/0`
    - See the table for interface types.
    - The Flexible PIC Concentrator (FPC) is typically 0 for single devices or equal to the member ID if using VC.
    - The Physical Interface Card (PIC) refers to the line card within a physical chassis, and is typically always 0 for fixed-format devices.
- Logical interfaces:
    - Format: `<phys-if>.<unit>`
    - Example: `ge-0/0/0.0`
    - The unit number is a non-negative number, often just 0 for physical interfaces that just need one logical interface, or corresponding to subinterface numbers for VLAN trunks.
- Channelized interfaces (aka breakout interfaces):
    - Format: `<phys-if>:<channel>`
    - Example parent: `et-0/0/0`
    - Example channel: `xe-0/0/0:0` (0-3)
    - Channelized interfaces allows for splitting e.g. a 40G interface into four 10G interfaces using a breakout cable.

Physical interfaces:

| Prefix | Type | Example |
| - | - | - |
| fe | 100M Ethernet | `fe-0/0/0` |
| ge | 1G Ethernet | `ge-0/0/0` |
| xe | 10G Ethernet | `xe-0/0/0` |
| et | 25G/40G/100G Ethernet | `et-0/0/0` |
| mge | Multi-rate Ethernet | |
| fxp | Mgmt. interface on RE (0-1) (SRX) | |
| me | Management Ethernet | |
| em | Management Ethernet | |
| fc | Fibre Channel (FC) | |
| at | ATM | |
| pt | VDSL2 | |
| cl | 3G/LTE | |
| dl | Dialer for LTE (cl) | `dl0.0` |
| se | Serial | |
| e1 | E1 | |
| e3 | E3 | |
| t1 | T1 | |
| t2 | T2 | |
| wx | WXC ISM | |
| reth | Chassis cluster traffic | |

Special interfaces:

| Prefix | Type | Example |
| - | - | - |
| lo | Loopback (some are internal) | `lo0` |
| ae | Aggregated Ethernet (LAG) | `ae0` |
| irb | IRB | `irb.0` |
| dsc | Discard (internal) | `dsc` |
| tap | Tap (internal) | `tap` |
| fti | Flexible Tunnel Interface (FTI) | `fti0` |
| gr | GRE tunnel | `gr-0/0/0` |
| ip | IP-over-IP tunnel | `ip-0/0/0` |
| lsq | Link services queueing interface (MLPPP, MLFR, CRTP) | `lsq-0/0/0` |
| lt | Logical tunnel (SRX) | `lt-0/0/0` |
| mt | Multicast tunnel | `mt-0/0/0` |
| sp | Adaptive services (unit 16383 is internal) | `sp-0/0/0` |

{% include footer.md %}
