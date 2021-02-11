---
title: Cisco IOS Routers
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

Software configuration for Cisco routers running IOS or derivatives.

### Related Pages
{:.no_toc}

- [Cisco Hardware](/config/network/cisco-hardware/)
- [Cisco IOS General](/config/network/cisco-ios-general/)
- [Cisco IOS Switches](/config/network/cisco-ios-switches/)

### Using
{:.no_toc}

- ASR 920 (IOS XE 16.9)

## Initial Configuration

An example of a full configuration.

1. Connect using serial.
1. Don't enter initial configuration (it's useless).
1. Enter privileged exec mode: `enable`
1. Enter configuration mode: `conf t`
1. Disable zero touch provisioning (ZTP): `ztp disable`
1. Disable unused features/services:
    1. `no service config`
    1. `no service pad`
    1. `no service password-encryption`
    1. `no cdp run`
    1. `no ip source-route`
    1. `no ipv6 source-route`
    1. `no ip domain-lookup` (optional)
    1. `no ip http server`
    1. `no ip http secure-server`
1. Set the hostname and domain name:
    1. `hostname <hostname>`
    1. `ip domain-name <domain>` (the part after the hostname)
1. Set the time zone (for Norway) and time:
    1. Time zone: `clock timezone UTC 1 0` (Norway)
    1. Automatic summer time: `clock summer-time CEST recurring last Sun Mar 2:00 last Sun Oct 3:00` (Norway)
    1. Set the time (exec mode): `clock set 10:50:00 Oct 26 2006` (example)
    1. Show the current time (exec mode): `show clock`
1. Setup console:
    1. Enter console config: `line con 0`
    1. Enable synchronous logging: `logging synchronous`
1. Setup logging:
    1. Change buffer size and max level: `logging buffered 16384 warnings`
    1. Log important messages to console: `logging console critical`
1. Setup user login:
    1. Enable new model AAA: `aaa new-model`
    1. Set the enable secret (e.g. to "secret"): `enable algorithm-type scrypt secret <secret>`
        - While this seems pointless, it's required to enter priv exec mode from VTY.
    1. Add a user: `username <username> privilege 15 algorithm-type scrypt secret <password>`
    1. Set local login as default: `aaa authentication login default local`
    1. Enable console local login:
        1. `line con 0`
        1. `login authentication default`
1. Configure SSH:
    1. Set hostname and domain name (see above).
    1. Generate SSH server cert: `crypto key generate rsa modulus <2048|4096>`
    1. Set version: `ip ssh version 2`
    1. Set VTY lines to use SSH:
        1. Enter line config: `line vty 0 15`
        1. Set to use SSH: `transport input ssh`
        1. Set the timeout: `exec-timeout <minutes> <seconds>` (e.g. 60 minutes)
        1. Enter priv exec mode after login: `privilege level 15`
1. Configure DNS: `ip name-server <addr1> <addr2> [...]`
1. Enable IPv6 forwarding: `ipv6 unicast-routing`
1. Enable Cisco Express Forwarding (CEF):
    1. Note: This may be enabled by default and the commands below to enable it may not work.
    1. Enable for IPv4: `ip cef`
    1. Enable for IPv6: `ipv6 cef`
    1. Show status: `sh cef state` (should show "enabled/running" for both IPv4 and IPv6)
1. (Optional) Add black hole route for the site prefixes:
    1. Note: To avoid leakage of local traffic without a route.
    1. IPv4 prefix: `ip route <address> <mask> Null 0`
    1. IPv6 prefix: `ipv6 route <prefix> Null 0`
1. (Optional) Configure management interface:
    1. Note: The management interface is out-of-band by being contained in the special management interface VRF "Mgmt-intf".
    1. Enter the mgmt interface config: `interface GigabitEthernet 0` (example)
    1. Set an IPv4 and IPv6 address: See "configure interface".
    1. Set a default IPv4 route: `ip route vrf Mgmt-intf 0.0.0.0 0.0.0.0 <gateway>`
    1. Set a default IPv6 route: `ip route vrf Mgmt-intf ::/0 <gateway>`
    1. Set other interface stuff: See "configure interface".
1. Configure interface:
    1. Set description: `desc <desc>`
    1. (Optional) Set IPv4 address: `ip address <address> <mask>`
    1. (Optional) Set IPv6 address: `ipv6 address <address>/<prefix-length>`
    1. (Optional) Disable sending IPv6 RAs: `ipv6 nd ra suppress all`
    1. Enable strict uRPF for IPv4 (downlinks only): `ip verify unicast source reachable-via rx`
    1. Enable strict uRPF for IPv6 (downlinks only): `ipv6 verify unicast source reachable-via rx`
    1. VLAN subinterfaces: See separate section.
    1. IPv6 router advertisements: See separate section.
1. Setup default routes:
    1. Set a default IPv4 route: `ip route 0.0.0.0 0.0.0.0 <gateway>`
    1. Set a default IPv6 route: `ip route ::/0 <gateway>`
1. Enable LLDP: `lldp run`
1. Add an ACL to protect management services:
    1. Create IPv4 ACL:
        1. Create and enter it: `ip access-list standard <name-v4>`
        1. Add a permitted prefix: `permit <address> <wildcard-mask>`
    1. Create IPv6 ACL:
        1. Create and enter it: `ipv6 access-list <name-v6>`
        1. Add a permitted prefix: `permit <src-prefix> <dst-prefix>`
    1. Apply it to VTY lines:
        1. IPv4 non-VRF: `access-class <name-v4> in`
        1. IPv4 VRF: `access-class <name-v4> in vrfname Mgmt-intf`
        1. IPv6 non-VRF: `ipv6 access-class <name-v6> in`
        1. IPv6 VRF: `ipv6 access-class <name-v6> in vrfname Mgmt-intf`
1. (Optional) Configure NTP client:
    1. `ntp server <address>`
    1. Show status:
        1. `sh ntp assoc`
        1. `sh ntp status`
1. (Optional) Configure remote syslog delivery:
    1. `logging host <address>`
    1. `logging facility syslog`
1. (Optional) Configure SNMP daemon:
    1. With IPv4 and IPv6 ACL: `snmp-server community public ro ipv6 <acl-name-v6> <acl-name-v4>`
1. (Optional) Configure SNMP traps:
    1. **TODO**
1. Save the config: `copy run start` or `write mem`
1. (Optional) Copy the config to a TFTP server: `copy start tftp://<host>/<path>`

## General Configuration

### VLAN Subinterfaces (IOS XE)

- Add a bridge domain for the VLAN: `bridge-domain <VID>`
    - It'll enter the section, but you can immediately exit it.
- Enter the interface containing the tagged VLAN.
- (Optional) Enter IP addresses to terminate the native VLAN.
- Setup a service config for the subinterface:
    - Create and enter: `service instance <VID> ethernet`
    - Set 802.1Q VID: `encapsulation dot1q <VID>`
    - Terminate the tag: `rewrite ingress tag pop 1 symmetric`
    - Set the bridge domain to terminate it into: `bridge-domain <VID>`
- Exit to global.
- Setup a bridge domain interface to terminate the VLAN:
    - Create and enter: `int BDI <VID>`
    - Set a description and IP addresses.
    - Enable it: `no shut`

### IPv6 Router Advertisements

- Disable sending router advertisements: `ipv6 nd ra suppress all`
    - This prevents both periodic and solicited advertisements.
    - Without the `all`, it may in certain versions still send solicited advertisements.
- **TODO**

### Bogon Filtering

- Related:
    - Add black hole routes for local prefixes to avoid leakage when a local route is missing.
    - Enable strict unicast reverse path forwarding to avoid having traffic from places it shouldn't come from (typically spoofed).
- Input bogon filter ACL (IPv4 and IPv6):
    1. Create an ACL.
    1. Add deny statements for prefixes to drop.
    1. Add an explicit allow as the catch-all.
    1. Attach it to an input interface.

{% include footer.md %}
