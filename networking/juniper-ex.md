---
title: Juniper EX Series Switches
breadcrumbs:
- title: Network
---
{% include header.md %}

**TODO** Clean up, reorganize and add remaining stuff.

### Related Pages
{:.no_toc}

- [Juniper Hardware](/config/network/juniper-hardware/)
- [Juniper Junos OS](/config/network/juniper-junos/)

### Using
{:.no_toc}

- EX3300 w/ Junos 15.1R7

## Resources

- [Juniper EX3300 Fan Mod](/guides/network/juniper-ex3300-fanmod/)

## Basics

- Default credentials: Username `root` without a password (drops you into the shell instead of the CLI).
- Default mgmt. IP address: Using DHCPv4.
- Serial config: RS-232 w/ RJ45, baud 115200, 8 data bits, no parity bits, 1 stop bit, no flow control.
- Native VLAN: 0, aka `default`

## Random Notes (**TODO:** Move Somewhere Appropriate)

- `request system storage cleanup` for cleanup of old files.
- `system auto-snapshot` (already added here)
- `system no-redirects`
- `system arp aging-timer 5` (defaults to 20 minutes (on routers which run ARP), which is crazy) (MAC address timeout on switches however is 5 minutes) (may cause flooding when the router tries to forward traffic but the MAC address is timed out) (use 5 minutes to be compatible with MAC address timeout)
- `system internet-options path-mtu-discovery` (allows BGP to use packets larger than the minimum)
- Syslog:
    - See nLogic slides.
    - `user *` decides what to show in the terminal. `any emergency` shows very few messages.
    - `host <hostname>` is used for remote logging. The DNS lookup is resolved only at commit time, so maybe use an IP address just for clarity.
    - `file <file>` is used for log files (e.g. `messages` and `interactive-commands`).
    - The `local[0-7]` facilities were conventionally used for different types of devices. Nowadays it doesn't normally provide any benefit.
- User AAA:
    - No "enable mode".
    - `authentication-order [ radius ]` (example) (RADIUS timeouts still allow local passwords?)
    - `login class <name> permissions <...>` for custom classes. `super-user` allows everything.
    - Locally defined users are not required if RADIUS/TACACS is setup. Class etc. is fetched from RADIUS.
- Config archival:
    - See `system archival` with `transfer-on-commit` and nLogic slides.
- `default-address-selection` to use loopback address for the source address of e.g. pinging.
- OSPF:
    - Area, router ID, interfaces (with unit).
    - Should fix cost. `metric <n>` on OSPF interface.
    - `interface lo0.0 passive` (no neighbors)
    - Use password (`authentication`) just to prevent accidents when plugging different things together. Doesn't need to be "secure".
    - Always `interface-type p2p` on P2P onterfaces for fast recovery on short link breakages.
    - TL: Missing use of `static-to-ospf`, only direct. Add as terms in same policy. See nLogic slides.
- Enhanced layer 2 software (ELS):
    - Switches from 2018 (e.g. EX2300, EX3400, all QFX, etc.) ELS. Older switches use "standard" (as some call it).
    - Interface port mode: `port-mode` renamed to `interface-mode`.
    - Supports VLAN ranges.
    - Native VLAN: `native-vlan-id` is not outside of units. It must also be specified in the `vlan` list in unit 0.
    - Spanning tree: Must now be specified for each interface to activete for, instead of enabling for all. Supports interface ranges. Now supports multiple spanning tree instances for different interfaces.
    - IGMP snooping: Interfaces must be listed (or `all`).
- Firewalling:
    - TODO
- First hop security:
    - See screenshots fron nLogic course. Custom firewall filters may be required.
    - Example:
        ```
        firewall {
            family ethernet-switching {
                filter RA-guard {
                    term router-solicitation {
                        from {
                            destination-mac-address 33:33:00:00:00:02;
                        }
                        then {
                            discard;
                        }
                    }

                    term router-advertise {
                        from {
                            destination-mac-address 33:33:00:00:00:01;
                        }
                        then {
                            discard;
                        }
                    }

                    term permit-all {
                        then {
                            accept;
                        }
                    }
                }
            }
        }
        ```

## Initial Setup

Example for setting up base system for a simple L2 switch.

1. Connect to the switch using serial:
    - RS-232 w/ RJ45, baud 9600, 8 data bits, no parity, 1 stop bits, no flow control.
1. Login:
    - Username `root` and no password.
    - Logging in as root will always start the shell. Run `cli` to enter the operational CLI.
1. (Optional) Free virtual chassis ports (VCPs) for normal use:
    1. Enter op mode.
    1. Show VCPs: `show virtual-chassis vc-port`
    1. Remove VCPs: `request virtual-chassis vc-port delete pic-slot <pic-slot> port <port-number>`
    1. Show again to make sure they disappear. This may take a few seconds.
1. Enter configuration mode:
    - Enter: `configure`
    - Exit: `exit`
1. Set host name:
    - `set system host-name <host-name>`
    - `set system domain-name <domain-name>`
1. Enable auto snapshotting and restoration on corruption:
    - `set system auto-snapshot`
1. Disable DHCP auto image upgrade:
    - `delete chassis auto-image-upgrade`
1. Set new root password:
    - `set system root-authentication plain-text-password` (prompts for password)
1. (Optional) Commit (stop the auto-upgrade spam etc.).
1. Setup a non-root user:
    - `set system login user <user> [full-name "<full-name>"] class super-user authentication plain-text-password` (prompts for password)
1. Setup SSH:
    - Enable server: `set system services ssh`
    - Disable root login from SSH: `set system services ssh root-login deny`
1. Set DNS servers:
    - `set system name-server <addr>` (once for each address)
1. Set time:
    1. (Optional) Set time locally: `run set date <YYYYMMDDhhmm.ss>`
    1. Set server to use while booting (forces initial time): `set system ntp boot-server <address>`
    1. Set server to use periodically (for tiny, incremental changes): `set system ntp server <address>`
    1. Set time zone: `set system time-zone Europe/Oslo` (example)
    1. (Note) After committing, use `show ntp associations` to verify NTP.
    1. (Note) After committing, use `set date ntp` to force it to update. This may be required if the delta is too large and the NTP client refuses to update.
1. Delete default interfaces configs:
    - `wildcard range delete interface ge-0/0/[0-47]` (example, repeat for all FPCs/PICs)
1. Disable dedicated management port and alarm:
    1. Disable: `set int me0 disable`
    1. Delete logical interface: `delete int me0.0`
    1. Disable link-down alarm: `set chassis alarm management-ethernet link-down ignore`
1. Disable default VLAN:
    1. Delete logical interface (before disabling): `delete int vlan.0`
    1. Disable logical interface: `set int vlan.0 disable`
1. Create VLANs:
    - `set vlans <name> vlan-id <VID>`
1. (Optional) Setup interface-ranges (apply config to multiple configured interfaces):
    - Declare range: `edit interfaces interface-range <name>`
    - Add member ports: `member-range <begin-if> to <end-if>`
    - Configure it as a normal interface, which will be applied to all members.
1. (Optional) Setup LACP:
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
    1. Enter logical unit: `edit unit 0`
    1. Setup VLAN/address/etc. (see other examples).
1. (Optional) Setup VLAN interfaces:
    1. Setup trunk ports:
        1. (Note) `vlan members` supports both numbers and names. Use the `[VLAN1 VLAN2 <...>]` syntax to specify multiple VLANs.
        1. (Note) Instead of specifying which VLANs to add, specify `vlan members all` and `vlan except <excluded-VLANs>`.
        1. (Note) `vlan members` should not include the native VLAN (if any).
        1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
        1. Set mode: `set port-mode trunk`
        1. Set VLANs: `set vlan members <VLANs>`
        1. (Optional) Set native VLAN: `set native-vlan-id <VID>`
    1. Setup access ports:
        1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
        1. Set access VLAN: `set vlan members <VLAN-name>`
1. (Optional) Setup L3 interfaces:
    1. (VLAN) Set L3-interface: `set vlans <name> l3-interface vlan.<VID>`
    1. Enter unit 0 of physical/LACP interface or `vlan.<VID>` for VLAN interfaces.
    1. Set IPv4 address: `set family inet address <address>/<prefix-length>`
    1. Set IPv6 address: `set family inet6 address <address>/<prefix-length>`
1. (Optional) Setup static IP routes:
    1. IPv4 default gateway: `set routing-options rib inet.0 static route 0.0.0.0/0 next-hop <next-hop>`
    1. IPv6 default gateway: `set routing-options rib inet6.0 static route ::/0 next-hop <next-hop>`
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
1. (Optional) Configure RSTP:
    - (Note) RSTP is enabled for all interfaces by default.
    - Enter config section: `edit protocols rstp`
    - Set interfaces: `set interfaces all` (example)
    - (Optional) Set priority: `set bridge-priority <priority>` (default 32768, should be a multiple of 4096, use e.g. 32768 for access, 16384 for distro and 8192 for core)
    - (Optional) Set hello time: `set hello-time <seconds>` (default 2s)
    - (Optional) Set maximum age: `set max-age <seconds>` (default 20s)
    - (Optional) Set forward delay: `set forward-delay <seconds>` (default 15s)
    - Set edge ports: `wildcard range set protocols rstp interface ge-0/0/[2-5] edge` (example)
    - Enable BPDU guard on all edge ports: `set protocols rstp bpdu-block-on-edge`
1. Configure SNMP:
    - (Note) SNMP is extremely slow on the Juniper switches I've tested it on.
    - Enable public RO access: `set snmp community public authorization read-only`
1. Configure sFlow:
    - **TODO**
1. Commit configuration: `commit [confirmed]`
1. Exit config mode: `exit`
1. Backup config to rescue config: `request system configuration rescue save`

## Commands

### Interfaces

- Disable interface or unit: `set disable`
- Show transceiver info:
    - `show interfaces diagnostics optics [if]`
    - `show interfaces media [if]` (less info, only works if interface is up)

### VLAN

- Show VLANs and member interfaces (`*` means active/up): `show vlans [vlan]`
- Show useful info for specific interface: `show vlans interface <interface>`

### STP

- Show interface status: `show spanning-tree interface`

## Virtual Chassis

(Although other series also support some form of virtual chassis, this section is targetet at EX switches.)

### Info

- Virtual Chassis (VC) is a simple way of connecting multiple close or distant switches into a ring topology and managing them as a single logical device. It simplifies loop prevention (otherwise using STP) and improves fault tolerance.
- Juniper don't like calling it a VC "stack" since it's more than just that.
- The internal routing is based on IS-IS with MAC addresses.
- Mode: Always use the preprovisioned mode with member IDs, roles and serial numbers specified, never automagic mode (if possible). It's also possible to start with automagic mode and then change to preprovisioned mode after it's up to avoid finding and writing in serial numbers and stuff.
- Roles: A VC has one switch as master routing engine, one switch as backup routing engine and the remaining switches as linecards.
- Primary-role election: The master is elected based on (in order) highest mastership priority, which member was master last time, which switch has been a member the longest, and which member has the lowest MAC address. When using a preprovisioned config, the mastership priority is automatically assigned based on the selected role.
- LEDs: The "MST" LED will be solid green on the master, blinking green on the backup and off on the linecards.
- Alarms: Alarms for a specific device will only show on the master and the actual device.
- FPCs: Each switch will show as separate FPCs (Flexible PIC (Physical Interface Cards) Concentrators).
- Split-and-merge: In case the VC gets partitioned, having all partitions elect a new master while running the same configuration would cause logical resource conflicts and inconsistencies in the network. The split and merge is a quorum-like mechanism where only the "largest" (according to certain specific rules) partition continues to function and the other partitions become inactive (all their switches aquire the line-card role). A VC partition becomes active if it contains both the stable (pre-split) primary and backup; if it contains the stable backup and at least half the VC size; or if it contains the stable primary and more than half the VC size. This "merge" part of the feature allows the partitions to merge back together when the partitioning is resolved (if the configurations adhere to certain specific rules). For VCs of size two where both switches would become inactive (i.e. line cards) if a partition were to happen (since none of the rules are satisfied), use `no-split-detection` to disable split-and-merge such that both switches may become primaries (although, one would likely be dead and avoid causing inconsistencies). But make sure to use preprovisioned mode with member IDs and serial numbers to avoid duplicate IDs when merging again. Make sure that the link doesn't fail as that would leave two primaries.

### Best Practices

- Always zeroize before merging.
- Use `no-split-detection` if using exactly two devices.
- When removing a device, recycle its old ID in the VC.
- If not preprovisioning the VC, explicitly set the mastership priority to 255 for the devices which should be routing engines.
- Enable synchronized commit to ensure commits are always applied to all members.

### Commands and Configuration

- Show status:
    - Show overview and nodes: `show virtual-chassis`
    - Show utilization of nodes: `show chassis fpc`
- Configuration changes:
    - Commit on both routing engines (always recommended for committing on VC): `commit synchronize`
    - Enable synchronized commit as default commit: `set system commit synchronize`
- Virtual chassis ports (VCPs):
    - Show: `show virtual-chassis vc-port`
    - Remove: `request virtual-chassis vc-port delete pic-slot <pic-slot> port <port-number>`
- Change assigned member ID: `request virtual-chassis renumber`
- Recycle an old member ID: `request virtual-chassis recycle`

### Setup

1. (Optional) Prepare preprovisioned setup:
    1. Only accept preprovisioned members: `set virtual-chassis preprovisioned`
    1. Add members:
        1. `set member 0 serial-number xxx role routing-engine`
        1. `set member 1 serial-number xxx role routing-engine`
        1. `set member 2 serial-number xxx role line-card`
1. If using only two devices, disable split and merge: `set virtual-chassis no-split-detection`
1. Enable implicit synchronized commit to all devices: `set system commit synchronize`
1. Enable graceful routing engine switchover: `set chassis redundancy graceful-switchover`

### Virtual Chassis Fabric

Virtual Chassis Fabric (VCF) evolves VC into a spine-and-leaf architecture. While VC focuses on simplified management, VCF focuses on improved data center connectivity. Only certain switches (like the QFX5100) support this feature.

{% include footer.md %}
