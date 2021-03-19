---
title: FS FSOS Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}

- FS S3700-24T4F

## Info

- Default credentials: Username `admin` and password `admin`.
- Default mgmt. IP address: `192.168.1.1/24`
- By default, SSH, Telnet and HTTP servers are accessible using the default mgmt. address and credentials.
- The default VLAN is VLAN1.

## Initial Setup

1. Connect to the switch using serial.
    - Using RS-232 w/ RJ45, baud 115200, 8 data bits, no parity bits, 1 stop bit, no flow control.
    - Use `Ctrl+H` for backspace.
1. Login with username `admin` and password `admin`.
1. Enter exec mode: `enable`
1. (Optional) Show version: `show version`
    - See the note below on how to upgrade it.
1. Enable password services:
    1. Enable prompting for password after command: `service password-hidden`
    1. Enable automatic hashing of passwords (using some weak alg.): `service password-encryption`
1. Add user: `username <username> password 0 <password>`
1. Disable admin user: `no username admin`
1. (Optional) Setup authentication (defaults to local):
    1. Disable enable authn: `aaa authentication enable default none`
    1. Enable login authn using local users: `aaa authentication login default local`
1. Disable HTTP server:
    1. `no ip http server`
    1. `no ip http language`
1. Enable SSH and disable Telnet:
    1. Enable SSH server (enabled by default): `ip sshd enable`
    1. Set SSH version: `ip sshd version 2`
    1. Disable SSH RC4 cipher: `ip sshd disable-rc4`
    1. Save the current key pair to flash to avoid regenerating it: `ip sshd save`
    1. (Optional) Enable SFTP: `ip sshd sftp`
    1. Disable Telnet: `no ip telnet enable`
1. Disable unused interfaces:
    1. Enter physical interface range (e.g. `int range g0/25-28`).
    1. Disable them: `shutdown`
1. Setup physical interface (applies motsly to other interfaces too):
    1. Set description: `description <description>`
    1. Enable or disable: `[no] shutdown`
1. Setup LAGs:
    1. Enter port agg. interface: `interface port-aggregator <n>`
    1. Set load balancing/hashing method: `aggregator-group load-balance both-ip`
    1. Change LACP timeout to fast (1s) or slow (30s): `agg-period <seconds>`
    1. Enter a physical interface range.
    1. Set agg. group and mode: `aggregator-group <n> mode lacp`
    1. Show LACP status: `show aggregator-group brief`
1. Setup VLANs:
    1. Define VLAN: `vlan <VID>`
    1. Enter VLAN interface: `interface VLAN<VID>`
    1. **TODO** Member interfaces etc.
1. Setup L3 interface:
    1. Enter the interface (physical, VLAN, etc.).
    1. Set the IPv4 address: `ip address <address> <subnet>`
    1. Set the IPv6 address: `ipv6 address <address>/<prefix-length>`
    1. Explicitly enable IPv6: `ipv6 enable`
    1. Disable directed broadcasts: `no ip directed-broadcast`
    1. **TODO** Test IPv6.
1. Disable default VLAN:
    1. Enter VLAN: `int VLAN1`
    1. Disable it: `shutdown`
    1. **TODO** Needs testing.
1. Set hostname: **TODO**
1. Set mgmt. addresses: **TODO**
1. Set default and static routes: **TODO**
1. Set DNS servers: **TODO**
1. Set time and NTP servers: **TODO**
1. (Optional) Add MOTD: `greeting <text-line>` (for each line, no quotes required)
1. Enable LLDP: `lldp run`
1. Enable SNMP:
    1. Enable RO for `public` community: `snmp-server community 0 public ro`
    1. **TODO** Filter slow OIDs.
1. Setup STP (802.1W/RSTP): **TODO**
1. Enable flow control:
    1. Enter a physical interface range.
    1. Enable auto mode: `flow-control auto`
1. Enable storm control:
    1. Enter an interface range.
    1. Enable for broadcast: `storm-control broadcast threashold <n>` (units of 64kb/s)
    1. Enable for unknown-destination unicast: `storm-control unicast threashold <n>` (units of 64kb/s)
    1. (Optional) Enable for multicast: `storm-control multicast threashold <n>` (units of 64kb/s)
    1. **TODO** Test.
1. Enable port security:
    1. Enter an interface range.
    1. Enable dynamic mode: `switchport port-security mode dynamic`
    1. Enable maximum addresses: `switchport port-security dynamic maximum <1>`
    1. **TODO** Test timeout etc.
1. Setup IGMP and MLD snooping: **TODO**
1. Setup security mechanisms (DHCP snooping, IPSG, DAI, IPv6 stuff, etc.): **TODO**
1. (Optional) Setup RADIUS: **TODO**
1. (Optional) Setup TACACS+:
    1. Enable and set server: `tacacs-server host <server> key 0 <key-or-prompt>`
    1. Set login authn to use TACACS+ and fallback to local: `aaa authentication login default group tacacs+ local`
    1. **TODO** Set authz too?
    1. **TODO** Add accounting too?
    1. **TODO** Test.
1. Set terminal idle timer:
    1. Enter console line: `line console 0`
    1. Set timeout: `exec-timeout <seconds>`
    1. Enter VTY lines: `line vty 0 31`
    1. Set timeout (again).
1. Save the config: `write all`

## Commands

- Configuration:
    - Show startup config: `show configuration`
    - Show running config: `show running-config`
    - Show interface config: `show {conf | run} <interface>`
    - Save configuration: `write all`
    - Format system: `format` (**TODO**: Does it keep the software image?)
- Interfaces:
    - Show L2 brief: `show int brief`
    - Show L3 brief: `show ip int brief`
- LACP:
    - Show semi-detailed overview: `show aggregator-group [n] brief`
    - Show member ports: `show aggregator-group [n] summary`
- Reboot: `reboot`

### Configuration Mode

- Enter interface range: `interface range <type><slot>/<port-range>[,<port-range>]*` (e.g. `interface range g0/1-3,5`)

## Tasks

### Configure With ZTP

**TODO**

### Upgrade Firmware

#### Via Web Panel

1. Log into the Web panel.
1. Go to "System Mgr.", "System Software".
1. Select the software image (`FS-something.bin`) and check automatic reboot.
1. Start the upgrade and do *not* leave the webpage until it tells you to.
1. Verify.

#### Via CLI

1. Put the image file on a TFTP server.
1. Download it to the switch: `copy tftp:<file> flash:<file> <host>`
    - Make sure it has a descriptive name like `S3700-24T4F_V63289.bin`.
1. Set to boot the new image (conf mode): `boot system flash <file>`
1. Reboot: `reboot`
1. Verify: `show version`

{% include footer.md %}
