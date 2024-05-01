---
title: Brocade FastIron Switches
breadcrumbs:
- title: Networking
---
{% include header.md %}

### Using
{:.no_toc}

- Brocade/Ruckus ICX 6610 (v08.0.30 router edition).

### Disclaimer
{:.no_toc}

Security features like port security, dynamic ARP inspection, DHCP snooping, IP source guard, DHCPv6 snooping, IPv6 NDP inspection and IPv6 RA guard will not be covered since I mainly use the switch as a core/dist. switch and not an access switch.

## Initial Configuration

1. Connect using serial: 9600bps baud, 8 data bits, no paroty, 1 stop bit, no flow control.
1. Enter privileged exec mode: `enable`
1. Enter configuration mode: `conf t`
1. Shut down all interfaces:
    1. Alternatively, shut down unused interfaces afterwards.
    1. Select range of innterfaces: `int e1/1/1 to 1/1/24` (example)
    1. Shut them down: `disable`
    1. Repeat for other interface ranges.
1. Set the correct boot preference:
    1. Change it: `boot system flash primary`
    1. Check it (priv exec): `sh boot-pref`
1. Set the hostname: `hostname <name>`
1. Disable unused features:
    1. Web management: `no web-management`
    1. VSRP: `no router vsrd`
    1. Telnet: `no telnet server`
1. Set the superuser enable password: `enable super-user-password <password>`
1. Add a user and enable login:
    1. Enable password encryption (requires v8.0.40 or later): `service password-encryption sha256`
    1. Add user: `user <username> privilege 0 create-password <password>`
        - Privilege 0 is the highest.
        - The default password hashing algorithm is MD5.
        - The password can't contain spaces.
    1. Enable remote login: `aaa authentication login default local`
    1. Make remote login enter priv exec mode: `aaa authentication login privilege-mode`
    1. Enable priv exec mode login: `aaa authentication enable default local`
    1. Enable login log messages and traps: `logging enable user-login`
1. Configure time zone (Norway):
    1. Time zone: `clock timezone gmt gmt+01`
    1. Manual summer time: `clock summer-time`
    1. Set the time (priv exec): `clock set <hh:mm:ss> <mm-dd-yyyy>`
1. Setup DNS:
    1. IPv4 DNS servers: `ip dns server-address <address> [...]`
    1. IPv6 DNS servers: `ipv6 dns server-address <address> [...]`
1. Enable SSH:
    1. Delete the old key: `crypto key zeroize [rsa]`
    1. Generate new key: `crypto key generate rsa modulus 2048`
    1. Remove old public keys: `ip ssh pub-key-file remove`
    1. Disable unused authentication methods:
        1. `ip ssh interactive-authentication no`
        1. `ip ssh key-authentication no`
    1. Make it secure:
        1. `ip ssh encryption aes-only`
        1. `ip ssh encryption disable-aes-cbc`
        1. `jitc enable`
    1. Set the idle timer: `ip ssh idle-time <minutes>` (e.g. 15)
    1. Notes:
        - SSH may crash if key-authentication is enabled but not configured.
        - Both password and key based authentication is enabled by default.
        - SCP is enabled by default.
1. (Optional) Enable HTTPS:
    1. Delete the old SSL/TLS certificate: `crypto-ssl certificate zeroize`
    1. Generate new SSL/TLS certificate: `crypto-ssl certificate generate`
    1. Enable HTTPS: `web-management https`
    1. Disable HTTP: `no web-management http`
    1. Use local auth: `aaa authentication web-server default local`
1. Configure physical interfaces (`int eth <unit/slot/port> [to ...]`):
    1. Set the port name: `post-name <name>`
    1. (SFP+ ports) Set the post speed and duplex: `speed-duplex 10g-full`
    1. VLAN configuration: See separate section.
1. Configure link aggregation:
    1. Create it: `lag <name> dynamic`
        - The "dynamic" can be omitted once created.
    1. Add ports to it: `ports ethernet <if> [to <if>]`
        - Use `no` to remove ports.
    1. Set the primary port: `primary-port <if>`
        - All other ports will inherit the config for the primary port.
    1. Use frequent LACPDUs: `lacp-timeout short`
    1. Deploy/enable it: `deploy`
1. Configure VLANs:
    1. Create VLAN: `vlan <VID> name <name>`
        - The name can be omitted once created.
    1. Create untagged og tagged ports: `<untagged | tagged> <if> [<if>*]`
    1. (Optional) Set a dual mode VLAN (aka native VLAN):
        1. Add the port as tagged.
        1. Enter the physical interface configuration.
        1. Set it for the current interface: `dual-mode <VID>`
    1. Enable spanning tree (same type as global): `spanning-tree`
1. Enable IPv6 forwarding: `ipv6 unicast-routing`
1. Configure in-band management interface and disable out-of-band interface:
    1. Disable the OOB mgmt. interface:
        1. Enter: `int man 1`
        1. Disable: `disable`
    1. Enter management VLAN config: `vlan <VID>`
    1. Add router interface to the VLAN: `router-interface ve <VID>`
    1. Exit VLAN config.
    1. Enter router interface: `int ve <VID>`
    1. Set IPv4 address for it: `ip address <address>/length`
    1. Set IPv6 address for it: `ipv6 address <address>/length`
    1. Exit router interface.
    1. Add a default IPv4 route: `ip route 0.0.0.0/0 <gateway>`
    1. Add a default IPv6 route: `ipv6 route ::/0 <gateway>`
    1. Disable sending IPv6 RAs: `ipv6 nd suppress-ra`
1. Enable LLDP: `lldp run`
1. Configure spanning tree (802-1w):
    1. Enable globally: `spanning-tree single 802-1w`
    1. Set priority: `spanning-tree single 802-1w priority 0` (0 for root)
    1. Set a port as edge port (aka portfast): `spanning-tree 802-1w admin-edge-port`
    1. Enable root guard on a port: `spanning-tree root-protect`
    1. Enable BPDU guard on a port: `stp-bpdu-guard`
    1. Enable BPDU filter on a port: `stp-protect`
    1. Show status: `show 802-1w`
1. (Optional) Configure NTP client:
    1. Enter config: `ntp`
    1. Enable with server: `server <address>`
    1. Show status:
        - `sh ntp assoc`
        - `sh ntp status`
1. Save the config: `write memory`

## General Configuration

### Basics

- Console:
    - Enable logging to the serial console: `logging console`
    - Enable logging to SSH/Telnet: `terminal monitor`(in privileged exec mode)
- Hardware:
    - Reboot: `boot system`
    - Show hardware: `sh chassis`
    - Log: `sh log`
    - CPU usage: `sh cpu`
- Interfaces:
    - Interface list: `sh int br`
    - Interface stats: `sh int`
- Spanning tree:
    - Show: `sh span`
- Link aggregation (LAG):
    - Show info: `sh lag`
- File management:
    - Show directory contents: `sh dir`
    - Show file contents: `copy flash console`
- Config management:
    - Save running config: `write memory`
    - Restore the startup config: `reload`
- Transceivers:
    - Show transceivers: `show media validation`
- LLDP:
    - Enable (config): `lldp run`
    - Show status: `show lldp`
    - Show neighbors overview: `show lldp neigh`
    - Show neighbor details: `show lldp neigh ports <port>`

### Ports

- Enable SFP+ ports: `speed-duplex 10g-full`

## Tasks

### Reset Configuration

Run `erase startup-config` and then `reload`. Don't `write mem` as it will recreate the startup config.

## Features

### Virtual Switch Redundancy Protocol (VSRP)

- A Ruckus-proprietary protocol for L2/L3 redundancy and failover.
- Enabled by default.

## Theory

### Using the CLI

- Backspace: `Ctrl+H`

### Miscellaneous
- Brocade devices operate in cut-through switching mode instead of store-and-forward by default.

{% include footer.md %}
