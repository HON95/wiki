---
title: Cisco Catalyst Switches (IOS)
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Network
---
{% include header.md %}

Using: Cisco Catalyst 2960G and 3750G

## Initial Configuration

1. Connect using serial.
2. Don't enter initial configuration \(it's useless\).
3. Enter privileged exec mode: `enable`
4. Enter configuration mode: `conf t`
5. Set the hostname and domain name:
   1. `hostname <hostname>`
   2. `ip domain-name <domain>` \(the part after the hostname\)
6. Set the time zone \(Norway\):
   1. Time zone: `clock timezone UTC 1 0`
   2. Automatic summer time: `clock summer-time CEST recurring last Sun Mar 2:00 last Sun Oct 3:00`
7. \(Optional\) Configure NTP client:
   1. `ntp server <address>`
   2. Show status:
      1. `sh ntp assoc`
      2. `sh ntp status`
8. Disable unused features/services:
   1. `no service config`
   2. `no service pad`
   3. `no service password-encryption`
   4. `vtp mode off`
   5. `no cdp run`
   6. `no ip source-route`
   7. `no ip domain-lookup`
   8. `no ip http server`
   9. `no ip http secure-server`
9. Setup console:
   1. Enter console config: `line con 0`
   2. Enable synchronous logging: `logging synchronous`
10. Setup user login:
    1. Enable new model AAA: `aaa new-model`
    2. Set the enable secret \(e.g. to "secret"\): `enable algorithm-type scrypt secret <secret>`
    3. Add a user: `username <username> privilege 15 algorithm-type scrypt secret <password>`
    4. Set local login as default: `aaa authentication login default local`
    5. Enable console local login:
       1. `line con 0`
       2. `login authentication default`
11. Configure SSH:
    1. Generate SSH server cert: `crypto key generate rsa modulus 2048`
    2. Set version: `ip ssh version 2`
    3. Set VTY lines to use SSH:
       1. Enter line config: `line vty 0 15`
       2. Set to use SSH: `transport input ssh`
       3. Set the timeout: `exec-timeout <minutes> <seconds>` \(e.g. 10 minutes\)
12. \(Optional\) Add default native vlan and black hole VLAN:
    1. Never use the default native VLAN.
    2. Use the black hole VLAN as the native VLAN for trunks without an untagged VLAN, as it can't be simply disabled on some switches.
    3. Setup default native VLAN: `int vlan 1`, `desc default-native, shut`
    4. Setup black-hole native VLAN: `vlan 2`, `name black-hole`, `shut`, `int vlan 2`, `desc black-hole`, `shut`
13. Configure VLANs and VLAN interfaces:
    1. Enter VLAN config: `vlan <VID>`
    2. Set name: `name <name>`
    3. \(Optional\) Shut down: `shutdown`
    4. Enter VLAN interface config: `interface vlan<vid>`
    5. Set description: `description <description>`
    6. \(Optional\) Shut down: `shutdown`
14. Configure LAGs \(LACP\):
    1. Set load balancing method \(globally\): `port-channel load-balance src-dst-ip`
    2. Enter LAG config: `interface port-channel<id>`
    3. Set description: `description <description>`
    4. Add interfaces \(int config\): `channel-group <id> mode active`
15. Configure ports:
    1. If using LAG:
       1. Connect it: `channel-group <id> mode active`
       2. Configure the LAG, not the interface range.
    2. Add access port:
       1. `switchport access vlan <VID>`
       2. `switchport mode access`
       3. Disable DTP: `switchport nonegotiate`
       4. `spanning-tree portfast`
       5. `spanning-tree bpduguard enable` \(if not enabled globally\)
       6. Setup other security features \(see section below.\)
    3. Add trunk port:
       1. `switchport trunk encapsulation dot1q` \(the default on 2960G and cannot be set manually\)
       2. `switchport trunk native vlan <vid>`
       3. `switchport trunk allowed vlan <vid>[,<vid>]*`
       4. `switchport mode trunk`
       5. Disable DTP: `switchport nonegotiate`
       6. Enable root guard if facing a lower-tier switch: `spanning-tree guard root`
    4. Disable unused ports: `shutdown`
16. Configure spanning tree \(rapid-pvst\):
    1. Mode: `spanning-tree mode rapid-pvst`
    2. `spanning-tree extend system-id`
    3. Configure VLANs:
       1. `spanning-tree vlan <vid-list>`
       2. `spanning-tree vlan <vid-list> priority <priority>`
17. Set management IP address and default gateway:
    1. Enter the chosen management VLAN.
    2. Set a management IP address: `ip address <address> <subnet-mask>`
    3. Set the default gateway \(global config\): `ip default-gateway <address>`
18. Configure access port security features:
    1. Storm control:
       1. Enter the interface config.
       2. `storm-control broadcast level bps 3m` \(3Mbps broadcast\)
       3. `storm-control multicast level bps 3m` \(3Mbps multicast\)
       4. By default it will only filter excess packets.
    2. DHCP snooping:
       1. DHCP snooping keeps a database DHCP leases. It can provide certain DHCP protection features, like rate limiting. It is used by some other security features.
       2. `ip dhcp snooping`
       3. `ip dhcp snooping vlan <vid-list>` \(for user VLANs\)
       4. `ip dhcp snooping verify mac-address` \(applies to DHCP packets\)
       5. Set trusted interfaces \(if config\): `ip dhcp snooping trust`
       6. Limit DHCP packets \(if config\): `ip dhcp snooping limit rate 25` \(25/s\)
       7. Verify that it's enabled: `sh ip dhcp snooping`
    3. Port security:
       1. Port security limites the amount of MAC addresses that may be used by a single port.
       2. TL;DR, it validates MAC-to-port bindings.
       3. Enter the interface config.
       4. `switch port-sec`
       5. `switch port-sec max 1` \(1 MAC address\)
       6. `switch port-sec violation restrict` \(don't shut down port\)
       7. `switch port-sec aging type inactivity`
       8. `switch port-sec aging time 1` \(1 minute\)
    4. IP source guard \(IPSG\) \(IPv4\):
       1. IPSG verifies that packets from a port match the IP addresses and optionally MAC adresses in the DHCP snooping DB.
       2. TL;DR, it validates IP-to-port bindings.
       3. Enter interface config.
       4. `ip verify source`
       5. An extra argument `port-security` can be specified which specified that MAC addresses should also be checked. If not specified, it only checks IP addresses. It requires that the server supports option 82.
    5. Dynamic ARP inspection \(DAI\) \(IPv4\):
       1. DAI uses the DHCP snooping DB and is similar to IPSG, but only applies to ARP packets.
       2. TL;DR, it validates IP-to-MAC bindings.
       3. `ip arp inspection vlan <vid-list>`
       4. Enter the interface config.
       5. On trusted interfaces: `ip arp inspection trust`
       6. Verify configuration: `sh ip arp inspection`
    6. **TODO:** DHCPv6 snooping and other IPv6 security mechanisms.
19. Configure remote syslog delivery:
    1. `logging host <address>`
    2. `logging facility syslog`
20. Configure SNMP daemon:
    1. `snmp-server community public RO`
    2. **TODO**
21. Configure SNMP traps:
    1. **TODO**
22. Save the config: `copy run start`

## Notes

#### Management

- Reset the configuration:
  - Delete the config: `erase startup-config`
  - Delete the VLAN DB: `delete flash:vlan.dat`
  - Show files: `sh flash:`
  - Delete `.renamed` files too.
  - Reload: `reload`

#### AAA

- Disable the `password-encryption` service, use encrypted passwords instead.
- Use type 9 \(scrypt\) secrets.

#### Ports and VLANs

- Show interfaces:
  - Overview: `sh ip int br`
  - Details: `sh int`
- Use trunks between switches. Avoid using native VLANs with trunks if possible.
- Select range of interfaces: `int range g1/0/1-52` \(example\)
- Reset interface\(s\): `default int [range] <if>[-<end>]`
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
  - Avoid using VLAN 1 \(the default VLAN\).
  - Consider adding a new VLAN \(e.g. VLAN 2\) and shutting it down, then using it as the native VLAN of trunks. This effectively disables the native VLAN for those trunks.
  - User VLANs should never be a native VLAN on any trunk. It can enable VLAN hopping through double tagging.

#### Services and Features

- CDP:
  - It may leak information.
  - Disable globally: `no cdp run`
- VTP:
  - It may cause BTP bombs.
  - Disable globally: `vtp mode (off | transparent)`
- DTP:
  - It may enable switch spoofing and VLAN hopping.
  - Disable it for each switch port: `switchport nonegotiate`
- UDLD:
  - Generally only useful for fiber.
  - Disable globally: **TODO**

#### Spanning Tree

- Enable BPDU guard globally to automatically enable it om ports with portfast.
- Only enable loop guard for links which may become uni-directional and which have UDLD enabled.

## Resources

- [https://github.com/cisco-config-analysis-tool/ccat](https://github.com/cisco-config-analysis-tool/ccat)

{% include footer.md %}
