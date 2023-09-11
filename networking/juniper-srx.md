---
title: Juniper SRX Series Firewalls
breadcrumbs:
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Juniper Hardware](/config/network/juniper-hardware/)
- [Juniper Junos OS](/config/network/juniper-junos/)

### Using
{:.no_toc}

- SRX320 w/ Junos 19.4R3

## Setup

### Initial Setup

1. Connect to the switch using serial:
    - RS-232 w/ RJ45, baud 9600, 8 data bits, no parity, 1 stop bits, no flow control.
1. Log in:
    1. It should say "Amnesiac" above the login prompt as the name of the switch, to show that it's factory reset.
    1. Login as `root` with no password to enter the shell.
    1. Enter the Junos operational CLI by typing `cli`.
1. Enter configuration mode:
    - Enter: `configure`
    - Commit: `commit`
    - Exit: `exit`
1. Set host name:
    1. `set system host-name <host-name>`
    1. `set system domain-name <domain-name>`
1. Enable auto snapshotting and restoration on corruption:
    1. `set system auto-snapshot`
1. Disable DHCP auto image upgrade:
    1. `delete chassis auto-image-upgrade`
1. Set new root password:
    1. `set system root-authentication plain-text-password` (prompts for password)
1. (Optional) Commit new config:
    1. `commit`
1. Setup a non-root user:
    1. `set system login user <user> [full-name <full-name>] class super-user authentication plain-text-password` (prompts for password)
1. Enable IPv6 forwarding (SRX):
    1. Enable: `set security forwarding-options family inet6 mode flow-based`
    1. (Info) Verify (after commit): `show security flow status`
1. Setup SSH:
    1. Enable server: `set system services ssh`
    1. Disable root login from SSH: `set system services ssh root-login deny`
1. Disable licensing and phone-home (for grey-market devices):
    1. `delete system license`
    1. `delete system phone-home`
1. Set DNS servers:
    1. Delete default: `delete system name-server`
    1. Set new (for each one): `set system name-server <addr>`
1. Set time:
    1. (Optional) Set time manually (UTC): `run set date <YYYYMMDDhhmm.ss>`
    1. Set server to use while booting (forces initial time): `set system ntp boot-server <address>`
    1. Set server to use periodically (for tiny, incremental changes): `set system ntp server <address>`
    1. Set time zone: `set system time-zone Europe/Oslo` (example)
    1. (Info) After committing, use `show ntp associations` to verify NTP.
    1. (Info) After committing, use `set date ntp` to force it to update. This may be required if the delta is too large and the NTP client refuses to update.
1. Configure SNMP:
    - (Info) SNMP is extremely slow on the Juniper devices I've tested it on.
    - Enable public RO access (or generate a secret community string): `set snmp community public authorization read-only`
1. (Optional) Set loopback addresses (if using routing):
    1. `set interfaces lo0.0 family inet address <address>/32`
    1. `set interfaces lo0.0 family inet6 address <address>/32`
1. (Optional) Setup static IP routes:
    1. IPv4 default gateway: `set routing-options rib inet.0 static route 0.0.0.0/0 next-hop <next-hop>`
    1. IPv6 default gateway: `set routing-options rib inet6.0 static route ::/0 next-hop <next-hop>`
1. (Optional) Disable dedicated management port and alarm (if any):
    1. Disable: `set int me0 disable`
    1. Delete logical interface: `delete int me0.0`
    1. Disable link-down alarm: `set chassis alarm management-ethernet link-down ignore`
1. Delete default interfaces configs (example):
    1. `wildcard range delete interface ge-0/0/[0-7]`
1. (Optional) Disable unused interfaces (example):
    1. `wildcard range set interface ge-0/0/[0-7] disable`
    1. `set interface cl-1/0/0 disable`
    1. `set interface dl0 disable`
1. (Optional) Setup LACP toward upstream/downstream switch:
    1. (Info) Make sure you allocate enough LAG interfaces and that the interface numbers are below some arbitrary power-of-2-limit for the device model. Maybe the CLI auto-complete shows a hint toward the max.
    1. Set number of available LAG interfaces: `set chassis aggregated-devices ethernet device-count <0-64>`
    1. Delete old configs for member interface: `wildcard range delete interfaces ge-0/0/[0-1]` (example)
    1. Add member interfaces: `wildcard range set interfaces ge-0/0/[0-1] ether-options 802.3ad ae<n>`
    1. Add some description to member interfaces: `wildcard range set interfaces ge-0/0/[0-1] description link:switch`
    1. Enter LAG interface: `edit interface ae<n>`
    1. Set description: `set desc link:switch`
    1. Set LACP active: `set aggregated-ether-options lacp active`
    1. Set LACP fast: `set aggregated-ether-options lacp periodic fast`
    1. (Optional) Set minimum links: `aggregated-ether-options minimum-links 1`
1. Delete default security (zones, policies, NAT, screens).
    1. `delete security`
1. Commit configuration: `commit [confirmed]`
1. Exit config CLI: `exit`
1. Save the rescue config: `request system configuration rescue save`
1. Save the autorecovery info: `request system autorecovery state save`

### Interface Setup

See [Juniper EX](/config/network/juniper-ex/).

### Other Setup

1. Configure sFlow:
    1. **TODO**

## Theory

### Zone-based Firewalling (SRX)

- On SRX firewalls, you assign interfaces to security zones. **TODO** All interfaces must be assigned a zone and a zone may have zero or multiple interfaces?
- *Security zones* are the main type of zone.
- *Function zones* are for special purposes. Only the management zone ("MGT") is currently supported and does not allow exchanging traffic with other zones.
- The default policy is to deny traffic both intra-zone and inter-zone.

{% include footer.md %}
