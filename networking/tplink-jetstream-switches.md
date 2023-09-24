---
title: TP-Link JetStream Switches
breadcrumbs:
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}

- TP-Link T2600G-28TS (24+4-port L2 managed switch)

### TODO
{:.no_toc}

- Auto install.
- IGMP and MLD snooping.
- RSTP.
- Centralized logging.
- Fast LACP.
- QoS.
- Inactivity timer.

## Info

- Supports (T2600G):
    - Access security features for both IPv4 and IPv6, like storm control, DHCPv4/v6 snooping, ARP snooping, ND snooping, etc.
    - RADIUS and TACACS+.
    - SNMP and sFlow.
    - DHCP/BOOTP client.
- Default mgmt. address: `192.168.0.1`
- Default admin user: Username `admin` and password `admin`.
- Console port (micro-USB or RS232 RJ45):
    - Baud rate: 38400bps
    - Data bits: 8
    - Parity: None
    - Stop bits: 1
    - Flow control: None
- As it uses some outdates SSH algorithms, you may need to enable some older algorithms: `ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss -c aes128-cbc <user>@<host>`

### LED Statuses

- Power/PWR:
    - Off: Powered off.
    - On: Powered on.
    - Flashing: PSU problem.
- System/SYS:
    - Flashing: OK.
    - On or off: Problem.

## Initial Setup

**Warning**: These steps are incomplete as we decided not to use these switches when we found out they can't run IPv4 and IPv6 source guard simultaneously.

1. Connect to the switch using serial (see info about for details).
    - Note that you may need to use `Ctrl+H` for backspace.
1. Login with username `admin` and password `admin` and set a new admin password when asked.
1. Enter privileged exec mode: `enable`
1. (Optional) Show version: `show system-info`
    - See the note below on how to upgrade it.
1. Enter config mode: `configure`
    - Use `exit` to exit.
    - Use `no <...>` to negate a command.
1. Add new admin user: `user name <username> privilege admin secret 0 <password>`
    - `secret 0` will automatically hash the password using MD5.
    - The `password-encryption` service is not used for `secret`, only `password`.
    - As I don't know which hashing algorithm `password-encryption` (or `password 7`) uses, I trust it even less than MD5.
1. Disable old admin user: `no user name admin`
    - You need to re-log as the new admin first.
1. (Optional) Disable HTTP server:
    1. `no ip http server`
    1. `no ip http secure-server`
1. Enable SSH and disable Telnet:
    1. Set version: `no ip ssh version v1`
    1. Enable server: `ip ssh server`
    1. Disable Telnet: `telnet disable`
1. Change Switch Database Management (SDM) template:
    1. (Note) Show SDM template info: `show sdm prefer {used|default|...}`
    1. (Note) Show actual usage: `ipv6 source binding`
    1. (Note) `enterpriseV6` is required for enabling IPv6 ND inspection.
    1. Allocate more resources to IPv6: `sdm prefer enterpriseV6`
    1. **TODO** Check how many entries are actually used. The max count seems low.
1. Setup physical interfaces (basics):
    1. Enter one or multiple interfaces: `int g 1/0/1` or `int range g 1/0/25-28`
    1. Set description: `desc <desc>`
    1. Disable (if unused): `shutdown`
1. Setup LAGs (LACP):
    1. Set load balancing method (global): `port-channel load-balance src-dst-ip`
    1. Enter the member interfaces: `int range g 1/0/23-24` (example)
    1. Make them members of the LAG and use LACP: `channel-group <n> mode active`
    1. Enter port channel interface: `interface port-channel <n>`
    1. Configure it as an interface (applies when the LACP interface is up).
    1. Show the status: `show etherchannel detail`
1. Define VLANs (L2):
    1. Enter the VLAN config: `vlan <VID>`
    1. Name it: `name <name>`
1. Setup VLAN trunk ports:
    1. Enter the member interface configs.
    1. Allow only tagged frames: `switchport acceptable frame tagged`
    1. Set allowed tagged VLANs: `switchport general allowed vlan <VID-list> tagged`
1. Setup VLAN access ports:
    1. Enter the member interface configs.
    1. Set allowed PVID VLAN: `switchport general allowed vlan <VID> untagged`
    1. Set the PVID VLAN: `switchport pvid <VID>`
1. Setup VLAN mixed ports:
    1. Enter the member interface configs.
    1. Set allowed tagged VLANs: `switchport general allowed vlan <VID-list> tagged`
    1. Set allowed PVID VLAN: `switchport general allowed vlan <VID> untagged`
    1. Set the PVID VLAN: `switchport pvid <VID>`
1. Setup L3 interface:
    1. Enter the interface (physical, VLAN, etc.).
    1. Set the IPv4 address: `ip address <address> <subnet>`
    1. Enable IPv6: `ipv6 enable`
    1. Set the IPv6 address: `ipv6 address <address>/<prefix-length>`
1. Disable default VLAN:
    1. Enter VLAN: `int vlan 1`
    1. Disable it: `shutdown`
    1. Remove the address: `no ip address`
    1. Disable IPv6: `no ipv6 enable`
1. Set hostname: `hostname`
1. Set default routes:
    - IPv4: `ip route 0.0.0.0 0.0.0.0 <next-hop>`
    - IPv6: `ipv6 route ::/0 <next-hop>`
1. Set DNS servers: **TODO** Not possible?
1. Set time and NTP servers:
    1. Set recurring DST: `system-time dst recurring last Sun Mar 2:00 last Sun Oct 3:00` (Norway)
    1. (Optional) Set time and NTP servers: `system-time ntp UTC+01:00 <ip-1> <ip-2> <update-hours>`
    1. (Note) Both NTP servers must be IP addresses and using the same IP version, but they may be the same address.
1. Enable LLDP:
    1. Enable globally: `lldp`
    1. Enter physical interface configs.
    1. (Optional) Disable transmit: `no lldp transmit`
    1. (Optional) Disable receive: `no lldp receive`
    1. (Optional) Enable LLDP-MED: `lldp med-status`
1. (Optional) Enable flow control:
    1. (Note) Flow control requires that the connected devices support it in order for it to work. As it pauses all traffic when "triggered", setting up QoS _instead_ of flow control is a much better option if possible.
    1. Enter the interface configs (physical or LAG).
    1. Enable: `flow-control`
    1. Show status: `show int status`
1. Enable Enerfy Efficient Ethernet (EEE):
    1. (Note) EEE is safe to enable on all ports and does not require that the connected devices are compatible in any way.
    1. Enter the physical interfaces (preferably all ports).
    1. Enable: `eee`
    1. Show status: `show int eee`
1. Enable storm control:
    1. Enter an interface range.
    1. Set to drop on exceed: `storm-control exceed drop`
    1. Set rate mode: `storm-control rate-mode {kbps|ratio|pps}` (e.g. ratio)
    1. Enable for broadcast: `storm-control broadcast <threshold>` (e.g. 1%)
    1. Enable for multicast: `storm-control multicast <threshold>` (e.g. 1%)
    1. Enable for unknown unicast: `storm-control unicast <threshold>` (e.g. 1%)
1. Enable DHCPv4/DHCPv6/ND snooping:
    1. (Note) Snooping by itself doesn't do anything but is used by other protection mechanisms.
    1. Enable globally (global): `{ip|ipv6} {dhcp|nd} snooping`
    1. Enable for VLAN (global): `{ip|ipv6} {dhcp|nd} snooping vlan <vid-range>`
    1. Set max number of bindings per port (interface): `{ip|ipv6} {dhcp|nd} snooping max-entries <n>` (e.g. 2)
    1. Show bindings: `show {ip|ipv6} source binding`
1. Enable ARP (IPv4) inspection/detection:
    1. (Note) ARP detection prevents ARP spoofing and flooding.
    1. Enable globally: `ip arp inspection`
    1. Enable for VLAN (global): `ip arp inspection vlan <vid-range>`
    1. (Debug) Enable logging (global): `ip arp inspection vlan <vid-range> logging`
    1. Validate source MAC address (global): `ip arp inspection validate src-mac`
    1. Validate destination MAC address (global): `ip arp inspection validate dst-mac`
    1. Validate sender/target IP address (global): `ip arp inspection validate ip`
    1. Set trusted interface (interface): `ip arp inspection trust`
    1. **TODO** Rate limiting interfaces.
    1. (Note) To restore an interface that has exceeded the rate limit, run `ip arp inspection recover` on it.
1. Enable ND (IPv6) detection:
    1. (Note) ND detection will validate the source IPv6 and MAC addresses for ND packets and will discard router adversisements and router redirects on untrusted ports.
    1. Enable globally (global): `ipv6 nd detection`
    1. Enable for VLAN (global): `ipv6 nd detection vlan <vid-range>`
    1. (Debug) Enable logging (global): `ipv6 nd detection vlan <vid-range> logging`
    1. Set trusted interface (interface): `ipv6 nd detection trust`
    1. **TODO** Fix, seems to fail to learn link local addresses from newly connected devices and then drops RSes and NAs from them due to IMPB mismatch.
1. Enable IPv4/IPv6 source guard:
    1. (Note) IP source guard validates the source IP and MAC addresses for normal traffic.
    1. Enable DHCPv4/DHCPv6/ND snooping (see above).
    1. **TODO** Enable globally?
    1. Enable for IP and MAC (interface): `{ip|ipv6} verify source sip[v6]-mac`
    1. (Debug) Enable logging (global): `ip verify source logging` **TODO** IPv4 only?
    1. **TODO** Fix, enabling for IPv6 drops all traffic for both IPv4 and IPv6.
    1. **WARNING**: These switches don't have enough resources to run _both_ IPv4 and IPv6 source guard. On one switch I tested, it caused it to drop all traffic for both protocols. On another switch, it simply denied me from activating IPv4 source guard when using the "enterpriseV6" SDM template.
1. Enable DoS prevention:
    1. Enable globally: `ip dos-prevent`
    1. Prevent scan-synfin: `ip dos-prevent type scan-synfin`
    1. Prevent xma-scan: `ip dos-prevent type xma-scan`
1. Setup IGMP (IPv4) snooping: **TODO**
1. Setup MLD (IPv6) snooping: **TODO**
1. (Optional) Setup TACACS+: **TODO**
1. Enable SNMP: **TODO**
1. Setup RSTP:
    - Set variant: `spanning-tree mode rstp`
    - Enable globally: `spanning-tree`
    - Enable on all ports (interface): `spanning-tree`
    - Enable portfast for edge ports (interface): `spanning-tree common-config portfast enable`
    - Enable BPDU guard for edge ports (interface): `spanning-tree bpduguard`
    - Enable loop guard for uplink ports (interface): `spanning-tree guard loop`
1. (Optional) Setup sFlow: **TODO**
1. Set terminal idle timer: **TODO**
1. Save the config (exec mode): `copy run start`

## Commands

#### Basics

- System info:
    - Systrem info: `show system-info`
    - Image info: `show image-info`
    - CPU utilization: `show cpu-utilization`
    - Memory utilization: `show memory-utilization`
- Configuration:
    - Show startup config: `show startup-config`
    - Show running config: `show running-config`
    - Save configuration: `copy run start`
- Interfaces:
    - Show short operational L2 status: `show int status`
    - Show short configured L2 status: `show int conf`
    - Show short L3 status: `show ip int brief`

### Configuration Mode

- Enter interface range: `int range <type> <full-start>-<end>` (e.g. `int range g 1/0/1-24`)

### Miscellanea

- Reset config and restart: `reset`
- Restart: `reboot`

## Tasks

### Setup Netboot

- See: [How to configure DHCP Auto Install to let Switch get configuration file and image file from TFTP server? (TP-Link)](https://www.tp-link.com/us/support/faq/2065/)
- Show status (enable mode): `show boot autoinstall`
    - When autoinstall is enabled, mode should show `Start` (not `Stop`) and state should show something like `Waiting for boot options` (not `Stopped`).
- Configuration:
    - Set autoinstall to begin on boot (as well as now): `boot autoinstall persistent-mode`
    - Save the autoinstall config as the startup config: `boot autoinstall auto-save`
    - Reboot after autoinstalling (used with `auto-save`): `boot autoinstall auto-reboot`
    - Set the retry count: `boot autoinstall retry-count <count>` (e.g. 3)
    - Enable autoinstall (now!): `boot autoinstall start`
    - Note that only certain autoboot options are saved in the config.
- Enabling autoinstall will _immediately_ change to DHCP client mode for whichever interface/VLAN has an IP address (which exactly?).
- The config does not need to be saved before rebooting the device, since persistent mode and enablement isn't stored in it.
- When persistent mode is enabled, it's only enabled for the next boot (not permanently, disables itself on reboot).
- Since autoinstall can't be enabled permanently, it may be required to SSH/telnet into the device and run `boot autoinstall start` in config mode to kickstart it? (**TODO** Needs more testing.)
- The loaded configuration file is just like any saved/exported configuration file from the switch.
- Some things need to be set at boot time, like setting the SDM template (required for enabling IPv6 ND inspection). Since the autoinstall config is loaded _after_ boot, either the autoinstall config must be saved and the switch rebooted, or the startup config must have it already set.

**TODO** IPv6?
**TODO** NTP broken (`show system-time ntp`).
**TODO** It seems to get merged with the existing config. Add explicit "no" statements to override startup?

### Upgrade Firmware

**TODO**

{% include footer.md %}
