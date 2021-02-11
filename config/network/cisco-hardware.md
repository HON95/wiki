---
title: Cisco Hardware
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

Hardware and special configuration for Cisco equipment.

### Related Pages
{:.no_toc}

- [Cisco IOS General](/config/network/cisco-ios-general/)
- [Cisco IOS Routers](/config/network/cisco-ios-routers/)
- [Cisco IOS Switches](/config/network/cisco-ios-switches/)

## ASR General

- The ASR series runs IOS-XE, a more modern and less monolithic version of IOS running on top of Linux. The commands and configurations are mostly the same, but with some significant changes.

## ASR 920

### Safe Shutdown

This is the recommended way to shut the device down, instead of just pulling the power. It allows the system to clean up file systems and such.

1. Issue the `reload` command in privileged exec mode and confirm.
1. Wait for the system bootstrap messages.
1. Remove power.

### Serial

- Using a USB A-A cable connected between a PC and the "USB CON" port.
- A special serial driver may be required on some systems, but on Linux and Windows 10 it works fine by default.
- Default settings:
  - 9600 baud
  - 8 data bits
  - No parity
  - 1 stop bit
  - No flow control

{% include footer.md %}
