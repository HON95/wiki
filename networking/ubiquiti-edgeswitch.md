---
title: Ubiquiti EdgeSwitch
breadcrumbs:
- title: Server
---
{% include header.md %}

## General

- Default credentials: Username `ubnt`, password `ubnt`.
- Serial settings: Baud 115200, 8 data bits, 0 parity bits, 1 stop bit, no flow control.

## Initial Setup

Tested with an EdgeSwitch 16 XG, configured as a L2 core/distro switch (homelab).

1. Basics (use where appropriate):
    - Log in: Username `ubnt`, password `ubnt`.
    - Enter enable mode (aka. privileged exec mode) from unprivileged mode: `en`
    - Enter config mode from enable mode: `conf`
    - Exit any mode: `exit`
    - Save config: `write mem`
    - Assume config commands are in config mode, unless stated otherwise.
1. Add new user and remove the default:
    1. Add new user (config mode): `username <username> level 15 override-complexity-check password` (prompts for password)
    1. Relog as the new user.
    1. Delete the default user (config mode): `no username ubnt`
1. Setup basics:
    1. Set hostname (enable mode): `hostname <hostname>`
    1. Set pre-login banner: `set clibanner "Hello"`
    1. Set timezone (Norway example):
        1. `clock timezone +1`
        1. `clock summer-time recurring EU`
        1. **TODO**: Verify this.
    1. Set SNTP server: `sntp server <server>`
1. Setup STP:
    1. Set mode: `spanning-tree mode rstp`
    1. Set priority: `spanning-tree mst priority 0 8192`
    1. Enable STP on all ports by default: `spanning-tree port mode all` (default)
    1. Enable BPDU guard on all edge ports: `spanning-tree bpduguard`
1. Setup VLANs:
    1. Enter VLAN mode (enable mode): `vlan database`
    1. Create VLAN (VLAN mode):
        1. Define: `vlan <vid>`
        1. Name: `vlan name <vid> <name>`
1. Setup management interface:
    1. Set management VLAN (enable mode): `network mgmt_vlan <vid>`
    1. **TODO**
1. Setup access ports (untagged edge):
    1. Enter interface config: `int <range>` (e.g. `int 0/8-0/12`)
    1. Description: `desc host:pve`
    1. Disable flow control: `no flowcontrol` (default)
    1. Configure LLDP:
        1. `lldp receive` (default)
        1. `lldp transmit` (default)
        1. `lldp transmit-tlv port-desc`
        1. `lldp transmit-tlv sys-name`
        1. `lldp transmit-tlv sys-desc`
    1. Configure VLAN (example: VLAN 10):
        1. **TODO**
        1. `switchport mode access`
        1. `switchport access vlan 10`
        1. `vlan acceptframe admituntaggedonly`
        1. `vlan participation include 10`
        1. `vlan pvid 10`
    1. Configure STP:
        1. Set as edge port: `spanning-tree edgeport`
        1. (Optional) Enable BPDU filter: `spanning-tree bpdufilter`
    1. Configure storm control:
        1. `storm-control unicast level 5`
        1. `storm-control broadcast level 5`
        1. `storm-control multicast level 75`
1. Setup L2 link ports (trunk link):
    1. Repeat relevant access port config.
    1. Configure VLAN trunk (example: VLANs 10+50):
        1. **TODO**
        1. `switchport mode trunk`
        1. `switchport trunk allowed vlan all`
        1. `vlan acceptframe vlanonly`
        1. `vlan participation include 10,50`
        1. `vlan participation include 10,50`
    1. Configure STP:
        1. Enable root guard: `spanning-tree guard root`
1. Setup AAA:
    1. Setup (better) local auth:
        1. Remove any custom AAA commands.
        1. Avoid enable password: `aaa authorization exec default local`
    1. Setup console:
        1. Enter line config: `line console`
        1. Set timeout: `serial timeout 60` (mintes)
    1. Setup SSH:
        1. **TODO**
    1. Set SSH timeout (enable mode): `sshcon timeout 60` (mintes)
    1. **TODO** Line enable/authn/authz
1. **TODO**:
    1. SNMP
    1. Syslog
    1. IGMP/MLD snooping.
    1. MTU

## Commands

- System:
    - Show hardware and versions: `show version`
    - Show active and backup firmware: `show bootvar`
- L2 interfaces:
    - Notice the difference between the `show interface` and `show interfaces` commands.
    - Show status: `show interfaces status all`
    - Show traffic counters: `show interface counters`
    - Show switchport config: `show interfaces switchport [port]`
- L3 interfaces:
    - Show brief: `show ip int brief`
- STP:
    - Show summary: `show spanning-tree`

## Tasks

### Reset

1. Wait until fully booted.
1. Press and hold the reset button for 30 seconds (exact duration is unclear). Holding it for a too short duration will simply reboot the device instead.

### Upgrade Software

1. Consider whether to use the lite version (limited to 255 VLANS for lower memory utilization).
1. Download the new version from the downloads page: `https://ui.com/download/edgemax`
1. Download the firmware to the backup partition: `copy tftp://<ip-address>/<filename> backup` (example)
1. Select the backup partition for the next boot: `boot system backup`
1. Reboot: `reload`
1. Verify that the new firmware is booted into: `show bootvar`
1. Copy the backup firmware to the active partition: `copy backup active`

{% include footer.md %}
