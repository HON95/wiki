---
title: Juniper EX Series Switches
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Juniper Junos OS](../juniper-junos/)

### Using
{:.no_toc}

- EX3300 w/ Junos 15.1R7

## Initial Setup

Enter configuration mode as necessary in the steps below with `configure` and `exit`.

1. Connect to the switch using serial.
1. Login with username `root` and no password. You'll enter the shell.
1. Enter the operation mode: `cli`
1. Set hostname (conf mode): `set system host-name <hostname>`

**TODO**
1. Setup root authentication.
1. Disable DHCP auto image upgrade: `delete chassis auto-image-upgrade` (conf mode)
1. Disable alarm for mgmt. port link down.
1. Commit.

## Theory

### Virtual Chassis

**TODO**

{% include footer.md %}
