---
title: Proxmox VE
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration
- title: Linux Server
---
{% include header.md %}

### Using
Proxmox VE 6

## Initial Setup

**TODO**

1. See [Debian Server: Initial Setup](../debian-server/#initial-setup).
    - **TODO**: Differences.
1. Disable the console MOTD:
    - Disable `pvebanner.service`.
    - Clear or update `/etc/issue` (e.g. use use the logo).
1. Disable IPv6 SLAAC:
    - It's enabled on all bridges by default, meaning the node may become accessible to untrusted bridged networks.
    - In `/etc/sysctl.conf`, set `net.ipv6.conf.default.autoconf=0`.
    - Reboot (not or later) and make sure there's no unexpected neighbors (`ip -6 n`).

### Setup SPICE Console

1. In the VM hardware, set the display to SPICE.
1. Install the guest agent:
    - Linux: `spice-vdagent`
    - Windows: `spice-guest-tools`
1. Install a SPICE compatible viewer on your client:
    - Linux: `virt-viewer`

{% include footer.md %}
