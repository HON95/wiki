---
title: Brocade ICX Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}
Brocade/Ruckus ICX 6610-24 running router/L3 software

Security features like port security, dynamic ARP inspection, DHCP snooping, IP source guard, DHCPv6 snooping, IPv6 NDP inspection and IPv6 RA guard will not be covered since I mainly use the switch as a core/dist. switch and not an access switch.

## Initial Configuration

1. Connect using serial: 9600bps baud, 8 data bits, no paroty, 1 stop bit, no flow control.
2. Enter privileged exec mode: `enable`
3. Enter configuration mode: `conf t`
4. Set the correct boot preference: boot system flash primary
   1. Check it with `sh boot-pref` in privileged exec mode.
5. Set the hostname: `hostname <name>`
6. Configure time zone (Norway):
   1. Time zone: `clock timezone gmt gmt+01`
   2. Manual summer time: `clock summer-time`
7. Configure NTP client:
   1. `ntp`
   2. `server <address>`
   3. Show status:
      1. `sh ntp assoc`
      2. `sh ntp status`
8. Set the superuser enable password: `enable super-user-password <password>`
9. Add a user and enable login:
   1. Enable password encryption: `service password-encryption sha256`
   2. Add user: `user <username> privilege 0 create-password <password>`
      1. Privilege 0 is the highest.
      2. The default password hashing algorithm is MD5.
   3. Enable local login: `aaa authentication login default local`
      1. **TODO**: It doesn't work for console.
      2. Enable for enable instead: `aaa authentication enable default local`
   4. Enable login log messages and traps: `logging enable user-login`
10. Enable SSH:
    1. Delete the old key: `crypto key zeroize rsa`
    2. Generate new key: `crypto generate rsa modulus 2048`
    3. Remove old public keys: `ip ssh pub-key-file remove`
    4. Disable unused authentication methods:
       1. `ip ssh interactive-authentication no`
       2. `ip ssh key-authentication no`
       3. Note: SSH may crash if key-authentication is enabled but not configured.
    5. Make it secure:
       1. `ip ssh encryption aes-only`
       2. `ip ssh encryption disable-aes-cbc`
       3. `jitc enable`
    6. Set the idle timer: `ip ssh idle-time <minutes>` (e.g. 10)
    7. Both password and key based authentication is enabled by default.
    8. SCP is enabled by default.
11. (Optional) Enable HTTPS:
    1. Delete the old SSL/TLS certificate: `crypto-ssl certificate zeroize`
    2. Generate new SSL/TLS certificate: `crypto-ssl certificate generate`
    3. `web-management https`
    4. `no web-management http`
    5. `aaa authentication web-server default local`
12. Disable extra features:
    1. VSRP (Brocade proprietary): `no router vsrd`
    2. Telner: `no telnet`
13. Configure link aggregation (LAG/LACP):
    1. Create it: `lag <name> [static | passive]`
    2. Add ports to it: `ports ethernet <if> [to <if>]`
       1. Use `no` to remove ports.
    3. Set the primary port: `primary-port <if>`
       1. All other ports will inherit the config for the primary port.
    4. (Optional) Make it fast manually: `lacp-timeout short`
    5. Deploy/enable it: `deploy`
    6. If the LAG is not facing a STP-capable device, disable it. I've had problems where the LAG entered `LACP-BLOCKED` state and STP _seemed_ to have something to do with it.
14. Configure VLANs:
    1. Enter VLAN config: `vlan <VID> [name <name>]`
       1. Providing a name will automatically create it.
    2. Create untagged og tagged ports: `<untagged | tagged> <if> [<if>*]`
       1. Access ports and trunk ports in Cisco terms.
    3. (Optional) Set a dual mode VLAN (native VLAN for in Cisco terms):
       1. Add the port as tagged.
       2. `dual-mode <VID>`
    4. Enable spanning tree (same type as global): `spanning-tree`
15. Configure normal interfaces (`int eth <stack_unit>/slot/port [to ...]`):
    1. Set the port name: `post-name <name>`
    2. If required, set the post speed and duplex mode: `speed-duplex <mode>`
       1. Note: SFP+ are disabled until a speed and duplex has been set.
    3. See VLAN configuration for making the interface untagged, tagged or dual-mode.
16. Configure the management interface and VLAN for IPv4:
    1. Disable the OOB mgmt. interface:
       1. `int man 1`
       2. `disable`
    2. Enter management VLAN config: `vlan 10` (assuming 10 is the VID)
    3. Add router interface to the VLAN: `router-interface ve 10` (10 should be same as VID)
    4. Enter router interface: `int ve 10`
    5. Set address for it: `ip address <address>/length`
    6. Exit router interface.
    7. Add a default route: `ip route 0.0.0.0/0 <gateway>`
17. Configure spanning tree (802-1w):
    1. Enable globally: `spanning-tree single 802-1w`
    2. Set priority: `spanning-tree single 802-1w priority 12288`
    3. Configure a port as edge port (portfast in Cisco lingo): `spanning-tree 802-1w admin-edge-port`
    4. Enable root guard on a port: `spanning-tree root-protect`
    5. Enable BPDU guard on a port: `stp-bpdu-guard`
    6. Enable BPDU filter on a port: `stp-protect`
18. SNMP daemon:
    1. Page 149
19. SNMP traps:
    1. Page 28
20. Syslog:
    1. Page 269
21. Save the config: `write memory`

## Usage

- Console:
  - Backspace in serial console: `Ctrl+H`
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
- Special:
  - Enable SFP+ ports: `speed-duplex 10g-full`

## Notes

- Brocade devices operate in cut-through switching mode instead of store-and-forward.

{% include footer.md %}
