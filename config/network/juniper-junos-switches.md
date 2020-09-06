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

- [Juniper Hardware](../juniper-hardware/)
- [Juniper Junos General](../juniper-junos-general/)

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
1. Enter configuration mode (implicit hereafter, use `exit` to return to CLI): `configure`
1. Set hostname: `set system host-name <hostname>` (conf mode)

**TODO**
1. Setup root authentication.
1. Disable DHCP auto image upgrade: `delete chassis auto-image-upgrade` (conf mode)
1. Disable alarm for mgmt. port link down.
1. Enable auto snapshotting and restoration on corruption: `set system auto-snapshot`
1. Commit.

## Virtual Chassis

Virtual Chassis (VC) is a simple way of connecting multiple close or distant switches into a ring topology and managing them as a single logical device. All devices share a common management IP address. It simplifies loop prevention (otherwise using STP) and improves fault tolerance. A VC has one switch as master routing engine, one switch as backup routing engine and the remaining switches as linecards. The master is elected based on (in order) highest mastership priority, which member was master last time, which switch has been a member the longest, and which member has the lowest MAC address. You typically want to set the mastership priority to 255 for the two switches you want as master and backup routing engines.

- Show status:
    - Show overview: `show virtual-chassis`
    - Show VC ports (VCPs): `show virtual-chassis vc-port`
- Commit on both routing engines (always recommended for committing on VC): `commit synchronize`
- Enable synchronized commit as default commit: `set system commit synchronize`
- Remove virtual chassis ports (VCPs): `request virtual-chassis vc-port delete pic-slot <pic-slot> port <port-number>`
- Set mastership: [Configuring Mastership of a Virtual Chassis (Juniper)](https://www.juniper.net/documentation/en_US/junos/topics/task/configuration/virtual-chassis-ex4200-mastership-cli.html)

### Virtual Chassis Fabric

Virtual Chassis Fabric (VCF) evolves VC into a spine-and-leaf architecture. While VC focuses on simplified management, VCF focuses on improved data center connectivity. Only certain switches (like the QFX5100) support this feature.

## Miscellanea

- Serial:
    - RS-232 w/ RJ45 (Cisco-like).
    - Baud 9600 (default).
    - 8 data bits, no parity, 1 stop bits, no flow control.

## Random Notes (TODO)

- No "unit 0" on LACP slave interfaces.
- `set virtual-chassis no-split-detection` (VC) (recommended for only 2 members) (The split and merge feature is enabled by default on EX Series and QFX Series Virtual Chassis. You can disable the split and merge feature by using the set virtual-chassis no-split-detection command.) (When disabled, both parts remain active after a split.)
- Discard route for supernet.
- `show interfaces`, `show interfaces ae0 extensive`, `show interfaces terse`, `show interfaces terse | match ae`, `show interfaces terse ge-* | match up.*up`
- `show chassis hardware`, `show version`, `show system uptime`
- Config. nav.: `top`, `exit`
- Int. range: `set interfaces interface-range <whatever> [member-range ge-0/0/0 to ge-0/0/1]`
- LACP:
    - (Optional) Create range or do it per phys. int.
    - `set interfaces ge-0/0/0 ether-options 802.3ad ae0`
    - `set interfaces ae0 aggregated-ether-options lacp active`
- Set IP address: `set interfaces ae0 unit 0 family inet address 10.0.0.1/30`
- Static route: `set routing-options static route 10.0.0.0/24 next-hop 10.0.1.1`
- `show configuration [...] | display set`

{% include footer.md %}
