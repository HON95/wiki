---
title: Cisco IOS Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

Software configuration for Cisco switches running IOS or derivatives.

### Related Pages
{:.no_toc}

- [Cisco Hardware](/config/network/cisco-hardware/)
- [Cisco IOS General](/config/network/cisco-ios-general/)
- [Cisco IOS Routers](/config/network/cisco-ios-routers/)

### Using
{:.no_toc}

- Catalyst 2950
- Catalyst 2960G
- Catalyst 3750G

## Initial Configuration

An example of a full configuration.

1. Connect using serial.
1. Don't enter initial configuration (it's useless).
1. Enter privileged exec mode: `enable`
1. Enter configuration mode: `conf t`
1. Set the hostname and domain name:
    1. `hostname <hostname>`
    1. `ip domain-name <domain>` (the part after the hostname)
1. Set the time zone (for Norway) and time:
    1. Time zone: `clock timezone UTC 1 0` (Norway)
    1. Automatic summer time: `clock summer-time CEST recurring last Sun Mar 2:00 last Sun Oct 3:00` (Norway)
    1. Set the time (exec mode): `clock set 10:50:00 Oct 26 2006` (example)
    1. Show the current time (exec mode): `show clock`
1. Disable unused features/services:
    1. `no service config`
    2. `no service pad`
    3. `no service password-encryption`
    4. `vtp mode off`
    5. `no cdp run`
    6. `no ip source-route`
    7. `no ip domain-lookup`
    8. `no ip http server`
    9. `no ip http secure-server`
1. Setup console:
    1. Enter console config: `line con 0`
    2. Enable synchronous logging: `logging synchronous`
1. Setup logging:
    1. Change buffer size and max level: `logging buffered 16384 warnings`
    1. Log important messages to console: `logging console critical`
1. Setup user login:
    1. Enable new model AAA: `aaa new-model`
    2. Set the enable secret (e.g. to "secret"): `enable algorithm-type scrypt secret <secret>`
    3. Add a user: `username <username> privilege 15 algorithm-type scrypt secret <password>`
    4. Set local login as default: `aaa authentication login default local`
    5. Enable console local login:
        1. `line con 0`
        2. `login authentication default`
1. Configure SSH:
    1. Generate SSH server cert: `crypto key generate rsa modulus 2048`
    2. Set version: `ip ssh version 2`
    3. Set VTY lines to use SSH:
        1. Enter line config: `line vty 0 15`
        2. Set to use SSH: `transport input ssh`
        3. Set the timeout: `exec-timeout <minutes> <seconds>` (e.g. 15 minutes)
1. (Optional) Add default native vlan and black hole VLAN:
    1. Never use the default native VLAN.
    2. Use the black hole VLAN as the native VLAN for trunks without an untagged VLAN, as it can't be simply disabled on some switches.
    3. Setup default native VLAN: `int vlan 1`, `desc default-native, shut`
    4. Setup black-hole native VLAN: `vlan 2`, `name black-hole`, `shut`, `int vlan 2`, `desc black-hole`, `shut`
1. Configure VLANs and VLAN interfaces:
    1. Enter VLAN config: `vlan <VID>`
    2. Set name: `name <name>`
    3. (Optional) Shut down: `shutdown`
    4. Enter VLAN interface config: `interface vlan<vid>`
    5. Set description: `description <description>`
    6. (Optional) Shut down: `shutdown`
1. Configure LAGs (LACP):
    1. Set load balancing method (globally): `port-channel load-balance src-dst-ip`
    2. Enter LAG config: `interface port-channel <id>`
    3. Set description: `description <description>`
    4. Add interfaces (int config): `channel-group <id> mode active`
1. Configure ports:
    1. If using LAG:
        1. Connect it: `channel-group <id> mode active`
        2. Configure the LAG, not the interface range.
    2. Add access port:
        1. `switchport access vlan <VID>`
        2. `switchport mode access`
        3. Disable DTP: `switchport nonegotiate`
        4. `spanning-tree portfast`
        5. `spanning-tree bpduguard enable` (if not enabled globally)
        6. Setup other security features (see section below.)
    3. Add trunk port:
        1. `switchport trunk encapsulation dot1q` (the default on 2960G and cannot be set manually)
        2. `switchport trunk native vlan <vid>`
        3. `switchport trunk allowed vlan <vid>[,<vid>]*`
        4. `switchport mode trunk`
        5. Disable DTP: `switchport nonegotiate`
        6. Enable root guard if facing a lower-tier switch: `spanning-tree guard root`
    4. Disable unused ports: `shutdown`
1. Configure spanning tree (rapid-pvst):
    1. Mode: `spanning-tree mode rapid-pvst`
    2. `spanning-tree extend system-id`
    3. Configure VLANs:
        1. `spanning-tree vlan <vid-list>`
        2. `spanning-tree vlan <vid-list> priority <priority>`
1. Set management IP address and default gateway:
    1. Enter the chosen management VLAN.
    2. Set a management IP address: `ip address <address> <subnet-mask>`
    3. Set the default gateway (global config): `ip default-gateway <address>`
1. (Optional) Configure NTP client:
    1. `ntp server <address>`
    2. Show status:
        1. `sh ntp assoc`
        2. `sh ntp status`
1. Configure access port security features:
    1. Storm control:
        1. Enter the interface config.
        2. `storm-control broadcast level bps 3m` (3Mbps broadcast)
        3. `storm-control multicast level bps 3m` (3Mbps multicast)
        4. By default it will only filter excess packets.
    1. DHCP snooping:
        1. DHCP snooping keeps a database DHCP leases. It can provide certain DHCP protection features, like rate limiting. It is used by some other security features.
        2. `ip dhcp snooping`
        3. `ip dhcp snooping vlan <vid-list>` (for user VLANs)
        4. `ip dhcp snooping verify mac-address` (applies to DHCP packets)
        5. Set trusted interfaces (if config): `ip dhcp snooping trust`
        6. Limit DHCP packets (if config): `ip dhcp snooping limit rate 25` (25/s)
        7. Verify that it's enabled: `sh ip dhcp snooping`
    1. Port security:
        1. Port security limites the amount of MAC addresses that may be used by a single port.
        2. TL;DR, it validates MAC-to-port bindings.
        3. Enter the interface config.
        4. `switch port-sec`
        5. `switch port-sec max 1` (1 MAC address)
        6. `switch port-sec violation restrict` (don't shut down port)
        7. `switch port-sec aging type inactivity`
        8. `switch port-sec aging time 1` (1 minute)
    1. IP source guard (IPSG) (IPv4):
        1. IPSG verifies that packets from a port match the IP addresses and optionally MAC adresses in the DHCP snooping DB.
        2. TL;DR, it validates IP-to-port bindings.
        3. Enter interface config.
        4. `ip verify source`
        5. An extra argument `port-security` can be specified which specified that MAC addresses should also be checked. If not specified, it only checks IP addresses. It requires that the server supports option 82.
    1. Dynamic ARP inspection (DAI) (IPv4):
        1. DAI uses the DHCP snooping DB and is similar to IPSG, but only applies to ARP packets.
        2. TL;DR, it validates IP-to-MAC bindings.
        3. `ip arp inspection vlan <vid-list>`
        4. Enter the interface config.
        5. On trusted interfaces: `ip arp inspection trust`
        6. Verify configuration: `sh ip arp inspection`
    1. **TODO:** DHCPv6 snooping and other IPv6 security mechanisms.
1. Configure remote syslog delivery:
    1. `logging host <address>`
    1. `logging facility syslog`
1. Configure SNMP daemon:
    1. `snmp-server community public RO`
    1. **TODO**
1. Configure SNMP traps:
    1. **TODO**
1. Save the config: `copy run start`
1. (Optional) Copy the config to a TFTP server: `copy start tftp://<host>/<path>`

## General Configuration

### Basics

- Show statuses:
    - L3 port overview: `sh ip int br`
    - L2 port overview: `sh int status`
    - Port statistics: `sh int <if>`
    - Err-disable: `sh int status err-disabled`
    - STP blocked ports: `sh span blockedports`
    - STP blocked VLANS: `sh span summary`
- Show/search log: `sh log | i <search-text>`

### Spanning Tree

- Enable BPDU guard globally to automatically enable it om ports with portfast. Or don't.
- Only enable loop guard for links which may become uni-directional and which have UDLD enabled.
- Show err-disabled ports: `sh int status err-disabled`
- Show blocked ports: `sh span blockedports`
- Show blocked VLANS: `sh span summary`
- Show STP neighbors: `` **TODO**

## Features

### VLAN Trunking Protocol (VTP)

- Cisco-proprietary.
- It may fuck up the trunks when an out-of-sync VTP switch joins.
- Disable globally: `vtp mode (off | transparent)`

### Dynamic Trunking Protocol (DTP)

- Cisco-proprietary.
- It may facilitate switch spoofing and VLAN hopping.
- Disable it for each switch port: `switchport nonegotiate`

## Tasks

### Reset the Configuration

1. Show files: `sh flash:`
1. Delete the config files:
    ```
    delete flash:config.text
    delete flash:private-config.text
    delete flash:vlan.dat
    ```
1. Delete any `.backup` and `.renamed` files too.
1. Reload: `reload`
    - Not required if the "mode" button was used to reset the device.

#### Without CLI Access

Hold the "mode" button for 30 seconds or until it says in the console that it's restarting and clearing the configuration.

## Information

### Ports and VLANs

- Use trunks between switches. Avoid using native VLANs with trunks if possible.
- User ports:
    - Untrusted.
    - Generally, configure it as an access port.
    - Disable services/protocols like CDP, VTP, DTP, etc.
    - Disable automatic PaGP/LACP.
    - Enable portfast.
    - Enable BPDU guard, unless configured globally.
    - Enable port security to limit the amount of MAC addresses using that port. MAC flooding can result in full MAC tables, which causes all frames to be flooded.
    - Enable ARP inspection to prevent ARP spoofing.
- Ports to switches:
    - Generally, configure it as a trunk port without a native VLAN.
    - Enable root guard if facing switches on lower topological tiers.
- Unused ports:
    - Shut them down.
- Native VLAN:
    - Be careful not to have a native VLAN spanning the entire area.
    - Avoid using VLAN 1 (the default VLAN).
    - Consider adding a new VLAN (e.g. VLAN 2) and shutting it down, then using it as the native VLAN of trunks. This effectively disables the native VLAN for those trunks.
    - User VLANs should never be a native VLAN on any trunk. It can enable VLAN hopping through double tagging.

### Port Lights

- Status mode:
    - Off: No link or administratively down.
    - Green: Link present.
    - Blinking green: Activity.
    - Alternating green-amber: Link fault. Could be caused by hardware errors or mismatched speed or duplex.
    - Amber and blinking amber: Blocked by STP.

{% include footer.md %}
