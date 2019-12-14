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

- See [Debian Server: Initial Setup](../debian-server/#initial-setup).
  - **TODO**: Differences.
- Disable the console MOTD:
  - Disable `pvebanner.service`.
  - Clear or update `/etc/issue` (e.g. use use the logo).

### Setup SPICE Console

1. In the VM hardware, set the display to SPICE.
1. Install the guest agent:
    - Linux: `spice-vdagent`
    - Windows: `spice-guest-tools`
1. Install a SPICE compatible viewer on your client:
    - Linux: `virt-viewer`

{% include footer.md %}
