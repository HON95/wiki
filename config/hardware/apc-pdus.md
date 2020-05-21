---
title: APC PDUs
breadcrumbs:
- title: Configuration
- title: Hardware
---
{% include header.md %}

## AP7850 Metered PDU

### Network Configuration Methods

The TCP/IP settings for the PDU may be configured using the following methods:

- The APC Device IP Configuration Wizard: A Windows program.
- DHCP/BOOTP: Requires special configuration of the DHCPv4 server.
- Local computer: Using some special RJ-11 serial cable.
- Remote computer: Using some ARP and ping hack and then telnet.

#### Remote Computer

1. Connect the PDU and the computer to the same VLAN.
1. Check the status LED. It should be blinking green and/or orange to indicate that it has an invalid TCP/IP configuration and/or is trying to request BOOTP configuration, respectively. If it's solid green it means it's already configured.
1. Add a static ARP entry to the PC to bind the PDU's MAC address to the desired IPv4 address.
    - Windows: `arp -s 10.10.10.10 00-c0-b7-63-9f-67` (example)
    - Linux: `arp -s 10.10.10.10 00:c0:b7:63:9f:67` (example)
    - One way to find the MAC address may be to look in the DHCP server log for the VLAN.
1. Ping the IP address with a packet size of 113 bytes.
    - Windows: `ping 10.10.10.10 -l 113`
    - Linux: `ping 10.10.10.10 -s 113`
1. Telnet into the device: `telnet 10.10.10.10`
1. Log in using username and password `apc`.
1. Navigate to the network settings to configure it correctly.

{% include footer.md %}
