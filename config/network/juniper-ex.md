---
title: Juniper EX Series Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Juniper Junos OS](../juniper-junos/)

### Using
{:.no_toc}

- EX3300 w/ Junos 15.1R7

### WIP
{:.no_toc}

This page is super not done.

## Initial Setup

Enter configuration mode as necessary in the steps below with `configure` and `exit`.

1. Connect to the switch using serial.
1. Login with username `root` and no password. You'll enter the shell.
1. Enter the operation mode: `cli`
1. Set hostname (conf mode): `set system host-name <hostname>`

**TODO**
1. Setup root authentication.
1. Disable DHCP auto image upgrade: `delete chassis auto-image-upgrade` (conf mode)
1. Disable alarm for mgmt. port link down.
1. Commit.

## More Random Notes (TODO)

- `show lldp neighbours`
- No "unit 0" on LACP slave interfaces.
- `show | compare`
- `set virtual-chassis no-split-detection` (VC) (recommended for only 2 members) (The split and merge feature is enabled by default on EX Series and QFX Series Virtual Chassis. You can disable the split and merge feature by using the set virtual-chassis no-split-detection command.) (When disabled, both parts remain active after a split.)
- `request system zeroize`
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

## Theory

### Virtual Chassis

**TODO**

{% include footer.md %}
