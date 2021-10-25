---
title: FS FSOS Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}

- FS S5860-20SQ (core switch)
- FS S3700-24T4F (access switch)

## Basics

- Default credentials: Username `admin` and password `admin`.
- Default mgmt. IP address: `192.168.1.1/24`
- By default, SSH, Telnet and HTTP servers are accessible using the default mgmt. address and credentials.
- Serial config: RS-232 w/ RJ45, baud 115200, 8 data bits, no parity bits, 1 stop bit, no flow control.
- The default VLAN is VLAN1.

## Initial Setup

### Core Switch

Using an FS S5860-20SQ.

Using an FS S3700-24T4F (access) and an FS S5860-20SQ (core).

1. Connect to the switch using serial.
    - Using RS-232 w/ RJ45, baud 115200, 8 data bits, no parity bits, 1 stop bit, no flow control.
    - Use `Ctrl+H` for backspace.
1. You should already be in the unprivileged exec mode (with `FS>` prompt).
1. Enter privileged exec mode: `enable`
    - The prompt should change from `>` tp `#`.
1. (Optional) Show version: `show version`
    - See the note below on how to upgrade it.
1. Make sure it's running in standalone mode (no stacking): `switch convert mode standalone`
1. Enter config mode: `conf`
    - The prompt should change from `#` tp `(config)#`.
1. Set hostname:
1. Enable password services:
    1. Enable automatic hashing of passwords (using some weak alg.): `service password-encryption`
1. Add user: `username <username> privilege 15 password 0 <password>`
1. Disable admin user: `no username admin`
1. Setup basic authentication (defaults to local):
    1. Enable new model: `aaa new-model`
    1. Disable enable authn: `aaa authentication enable default none`
    1. Enable login authn using local users: `aaa authentication login default local`
1. Enable login for console:
    1. Enter line config: `line con 0` (leave with `exit`)
    1. Use default authentication (e.g. local): `login authentication default`
1. Disable web server and telnet server, enable SSH server:
    1. Disable web server: `no enable service web-server`
    1. Disable telnet server: `no enable service telnet-server`
    1. Enable SSH server: `enable service ssh-server`
    1. Enter VTY lines: `line vty 0 35`
    1. Use default authentication (e.g. local): `login authentication default`
1. (Optional) Disable inactivity timeout:
    1. Note: For prod systems you should keep this disabled, but it's really annoying when labbing.
    1. Enter console line.
    1. Disable timer: `exec-timeout 0`
1. (Optional) Disable management interface:
    1. Enter: `int mgmt 0`
    1. Disable: `shut`
    1. Remove address: `no ip addr`
1. Disable unused interfaces:
    1. Enter physical interface range (e.g. `int range te0/1-20`).
    1. Disable them: `shutdown`
1. (Meta) Setup basic interface:
    1. Note: Applies to most interfaces.
    1. Set description: `description <description>`
    1. Enable or disable: `[no] shutdown`
1. Setup physical L2 interface:
    1. (VLAN/LAG/etc. configured later.)
1. Setup LAGs (LACP):
    1. Enter member interfaces: `int range te0/3-4` (example)
    1. (Optional) Enter some description.
    1. Enable active LACP: `port-group 1 mode active` (for group number `1`)
    1. Set short LACP period: `lacp short-timeout`
    1. Enter LAG interface: `int aggregatePort 1`
    1. Set load balancing method: `aggregate load-balance src-dst-ip`
    1. Configure as normal switch interface.
    1. Verify: `show aggregatePort summary` and `show lacp summary`
1. Setup VLANs:
    1. Define L2 VLAN and enter section: `vlan <VID>`
    1. Set name: `name <name>`
    1. Note: To setup L3 interfaces for VLANs, enter `interface VLAN <VID>`.
1. Add interfaces to VLANs:
    1. Enter the interface(s).
    1. Set the mode: `switchport mode {access|trunk}`
    1. (Access) Set access VLAN: `switch access vlan <VID>`
    1. (Trunk) Set native VLAN (if any): `switch trunk native vlan <VID>`
    1. (Trunk) Set allowed VLANs (defaults to all): `switch trunk allowed only 10,20` (example)
1. Setup L3 interface:
    1. Enter the interface (physical, VLAN, etc.).
    1. Enable L3 mode: `no switchport`
    1. Set IPv4 address: `ip address <address>/<length>`
    1. Set IPv6 address: `ipv6 address <address>/<length>`
    1. Explicitly enable IPv6: `ipv6 enable`
1. Disable default VLAN interface:
    1. Enter VLAN: `int VLAN1`
    1. Disable it: `shutdown`
1. Set default gateway (and other static routes):
    1. Set default gateway (IPv4): `ip route 0.0.0.0 0.0.0.0 <next-hop>`
    1. Set default gateway (IPv6): `ipv6 route ::/0 <next-hop>`
    1. Note: To avoid leakage, you may want to setup a blackhole route for the site prefixes on the topmost routers.
1. Enable router advertisements (RAs) for IPv6 L3 interfaces:
    1. Note: This is required for IPv6 autoconfiguration. Set the two flags for DHCPv6 or unset them for SLAAC.
    1. Enter the interface.
    1. (DHCPv6) Set the ND managed flag: `ipv6 nd managed-config-flag`
    1. (DHCPv6) Set the ND other flag: `ipv6 nd other-config-flag`
    1. Set DNS servers (RDNSS): `ipv6 nd ra dns server <ipv6-server> infinite sequence 0` (only supports IPv6 addresses) (use sequence 1 for the next server)
    1. Set DNS search list (DNSSL): `ipv6 nd ra dns search-list <domain> infinite sequence 0`
    1. (Optional) Disable sending RAs: `suppress-ra` (**TODO** Does this suppress sending or receiving??)
    1. **TODO** Requires testing.
1. Set DNS servers:
    1. Add server (for each one): `ip name-server <ip-address>`
1. Set time and NTP servers:
    1. Set time zone: `clock timezone UTC 1 0` (Norway)
    1. Enable automatic summer time: `clock summer-time CEST start March last Sunday 2:00 end October last Sun 3:00` (Norway)
    1. Enable SNTP: `sntp enable`
    1. Set NTP server: `sntp server <hostname>`
1. (Optional) Add MOTD:
    1. Start input for login banner: `banner login $` (for delimiter `$` to end input with)
1. Setup LLDP:
    1. Enable: `lldp enable`
1. Setup SNMP:
    1. **TODO**
    1. Enable RO for `public` community: `snmp-server community 0 public ro`
1. Setup STP (802.1W/RSTP):
    1. **TODO**
    1. `spanning-tree`
    1. `errdisable recovery interval 300`
1. Enable/disable flow control:
    1. Enter a physical interface range.
    1. (Optional) Enable auto mode: `flow-control auto`
    1. (Optional) Disable auto mode: `flow-control off`
1. (Optional) Setup VRF:
    1. Create: `vrf definition <name>`
    1. (Optional) Set a description.
    1. Enable IPv4: `address-family ipv4`
    1. Enable IPv6: `address-family ipv6`
    1. Bind interface to VRF (interface config): `vrf forwarding <vrf-name>` (removes existing IP addresses)
    1. **TODO** Test
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
1. (Optional) Split 40G-interface (QSFP+) into 4x 10G (SFP+): `split interface <if>`
1. Save the config: `write mem`

Random notes (**TODO**):

1. Configure RSTP:
    - Set protocol: `spanning-tree mode rstp` (default MSTP)
    - Set priority: `spanning-tree priority <priority>` (default 32768, should be a multiple of 4096, use e.g. 32768 for access, 16384 for distro and 8192 for core)
    - Set hello time: `spanning-tree hello-time <seconds>` (default 2s)
    - Set maximum age: `spanning-tree max-age <seconds>` (default 20s)
    - Set forward delay: `spanning-tree forward-time <seconds>` (default 15s)
    - Enable: `spanning-tree`
    - **TODO** Enabled on all interfaces and VLANs by default?
    - **TODO** Portfast for access ports? `spanning-treelink-type ...`
    - **TODO** Guards.
    - `errdisable recovery interval 300`
- VRF (avoid DHCP relay on VyOS?)
- Access lists for SSH etc.
- Disable mgmt. LAN
- URPF.

### Access Switch

Using an FS S3700-24T4F.

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
    1. (Optional) Explicitly enable IPv6 (not required if an address is specified): `ipv6 enable`
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
1. Enable/disable flow control:
    1. Enter a physical interface range.
    1. (Optional) Enable auto mode: `flow-control auto`
    1. (Optional) Disable auto mode: `flow-control off`
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
    - (Core) Show L2 brief: `show int status`
    - (Access) Show L2 brief: `show int brief`
    - Show L3 brief: `show ip int brief`
- STP:
    - Show details: `show spanning-tree`
    - Show overview and interfaces: `show spanning-tree summary`
- (Core) LACP:
    - Show LAG interfaces: `show aggregatePort summary`
    - Show LACP status: `show lacp summary`
- (Access) LACP:
    - Show semi-detailed overview: `show aggregator-group [n] brief`
    - Show member ports: `show aggregator-group [n] summary`
- Reboot: `reboot`

### Configuration Mode

- Enter interface range: `interface range <type><slot>/<port-range>[,<port-range>]*` (e.g. `interface range g0/1-3,5`)

## Tasks

### Reset the Configuration

1. Check that the startup config `config.txt` actually exists yet: `dir`
1. Delete startup config: `delete config.text`
1. Restart: `reload`

### Provision with ZTP

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
