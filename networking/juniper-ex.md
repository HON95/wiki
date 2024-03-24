---
title: Juniper EX Series Switches
breadcrumbs:
- title: Network
---
{% include header.md %}

**TODO** Clean up, reorganize and add remaining stuff.

### Related Pages
{:.no_toc}

- [Juniper Hardware](/network/juniper-hardware/)
- [Juniper Junos OS](/network/juniper-junos/)

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
    - **TODO**
- First hop security:
    - **TODO**

## Initial Setup

See the Junos general notes.

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
