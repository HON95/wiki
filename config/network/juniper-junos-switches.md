---
title: Juniper EX Series Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

**TODO** Clean up, reorganize and add remaining stuff.

### Related Pages
{:.no_toc}

- [Juniper Hardware](/config/network/juniper-hardware/)
- [Juniper Junos General](/config/network/juniper-junos-general/)

### Using
{:.no_toc}

- EX3300 w/ Junos 15.1R7

### WIP
{:.no_toc}

This page is super not done. Just random notes for now.

## Resources

- [Quieter fans for Juniper EX3300 switch (Jade.WTF)](https://jade.wtf/tech-notes/quiet-ex3300/)

## Initial Setup

1. Connect to the switch using serial (RS-232 w/ RJ45, baud 9600, 8 data bits, no parity, 1 stop bits, no flow control).
1. Login with username `root` and no password. You'll enter the shell.
1. Enter the operation mode: `cli`
1. Enter configuration mode: `configure`
    - Use `exit` to return to CLI.
1. Set root password: `set system root-authentication plain-text-password`
1. Setup a non-root user: `set system login user <user> [full-name <full-name>] class super-user authentication plain-text-password`
1. Disable root login from SSH: `set system services ssh root-login deny`
1. Set host name: `set system host-name <host-name>`
1. Set domain name: `set system domain-name <domain-name>`
1. Set loopback addresses:
    1. `set interfaces lo0.0 family inet address 127.0.0.1/32`
    1. `set interfaces lo0.0 family inet6 address ::1/128`
1. Set DNS: `set system name-server <addr>` (once for each address)
1. Set time:
    1. (Optional) Set time locally: `set date <YYYYMMDDhhmm.ss>`
    1. Set server to use while booting: `set system ntp boot-server <address>`
    1. Set server to use periodically: `set system ntp server <address>`
    1. Set time zone: `set system time-zone Europe/Oslo` (example)
    1. Note: After committing, use `show ntp associations` to verify NTP.
1. Disable default virtual chassis ports (VCPs) if not used:
    1. Enter op mode.
    1. Show VCPs: `show virtual-chassis vc-port`
    1. Remove VCPs: `request virtual-chassis vc-port delete pic-slot <pic-slot> port <port-number>`
    1. Show again to make sure they disappear. This may take a few seconds.
1. Delete default interfaces configs: `wildcard range delete interface ge-0/0/[0-47]` (example, repeat for all FPSc/PICs)
1. Disable unused interfaces: `wildcard range set interface ge-0/0/[0-47] disable` (example, repeat for all FPSc/PICs)
1. Disable dedicated management port and alarm:
    1. Disable: `set int me0 disable`
    1. Delete logical interface: `delete int me0.0`
    1. Disable link-down alarm: `set chassis alarm management-ethernet link-down ignore`
1. Disable default VLAN:
    1. Delete logical interface: `delete vlan.0` (before disabling)
    1. Disable logical interface: `set vlan.0 disable`
1. Setup config groups: **TODO**
1. Setup port-ranges: **TODO**
1. Setup VLANs (not interfaces): `set vlans <name> vlan-id <VID>`
1. Setup LACP:
    1. Note: Make sure you allocate enough LACP interfaces and that the interface numbers are below 512 (empirically discovered on EX3300).
    1. Set number of available LACP interfaces: `set chassis aggregated-devices ethernet device-count <0-64>`
    1. Add individual Ethernet interfaces (not using interface range):
        1. Delete logical units (or the whole interfaces): `wildcard range delete interfaces ge-0/0/[0-1] unit 0` (example)
        1. Set as members: `wildcard range set ge-0/0/[0-1] ether-options 802.3ad ae<n>` (for LACP interface ae\<n\>)
    1. Enter LACP interface: `edit interface ae<n>`
    1. Set description: `desc <desc>`
    1. Set LACP options: `set aggregated-ether-options lacp active`
    1. Setup default logical unit: `edit unit 0`
    1. Setup VLAN/address/etc.
1. Setup VLAN interfaces:
    1. Setup trunk ports:
        1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
        1. Set mode: `set port-mode trunk`
        1. Set non-native VLANs: `set vlan members <vlan-name> [members <VLAN-name>]` (once per VLAN or repeated syntax)
        1. (Optional) Set native VLAN: `set native-vlan-id <VID>`
    1. Setup access ports:
        1. Enter unit 0 and `family ethernet-switching` of the physical/LACP interface.
        1. Set access VLAN: `set vlan members <VLAN-name>`
1. Setup L3 interfaces:
    1. (VLAN) Set L3-interface: `set vlans <name> l3-interface vlan.<VID>`
    1. Enter unit 0 of physical/LACP interface or `vlan.<VID>` for VLAN interfaces.
    1. Set IPv4 address: `set family inet address <address>/<prefix-length>`
    1. Set IPv6 address: `set family inet6 address <address>/<prefix-length>`
1. Setup static IP routes:
    1. IPv4 default gateway: `set routing-options rib inet.0 static route 0.0.0.0/0 next-hop <next-hop>`
    1. IPv6 default gateway: ``set routing-options rib inet6.0 static route ::0/0 next-hop <next-hop>``
1. Configure RSTP: **TODO**
1. Configure SNMP (public RO): `set snmp community public authorization read-only`
1. Enable auto snapshotting and restoration on corruption: `set system auto-snapshot`
1. Disable DHCP auto image upgrade: `delete chassis auto-image-upgrade`
1. Setup event policies: **TODO**
1. Commit configuration: `commit [confirmed]`
1. Backup config to rescue config: `request system configuration rescue save`

## Commands

### Interfaces

- Disable interface or unit: `set disable`
- Perform operation on multiple interfaces: `wildcard range set int ge-0/0/[0-47] unit 0 family ethernet-switching` (example)

## Virtual Chassis

- Virtual Chassis (VC) is a simple way of connecting multiple close or distant switches into a ring topology and managing them as a single logical device. It simplifies loop prevention (otherwise using STP) and improves fault tolerance.
- Roles: A VC has one switch as master routing engine, one switch as backup routing engine and the remaining switches as linecards.
- Mastership election: The master is elected based on (in order) highest mastership priority, which member was master last time, which switch has been a member the longest, and which member has the lowest MAC address. When using a preprovisioned config, the mastership priority is automatically assigned based on the selected role.
- LEDs: The "MST" LED will be solid green on the master, blinking green on the backup and off on the linecards.
- Alarms: Alarms for a specific device will only show on the master and the actual device.
- FPCs: Each switch will show as separate FPCs (Flexible PIC (Physical Interface Cards) Concentrators).

### Best Practices

- Always zeroize before merging.
- Use no-split-detection if using exactly two devices.
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

## Miscellanea

- Serial:
    - RS-232 w/ RJ45 (Cisco-like).
    - Baud 9600 (default).
    - 8 data bits, no parity, 1 stop bits, no flow control.

{% include footer.md %}
