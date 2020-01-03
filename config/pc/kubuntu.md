---
title: Kubuntu
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}
Kubuntu 19.10

## Installation

1. Use the guided partitioner.
    - The manual installer is broken and can't create encrypted volumes.

## Setup

1. Upgrade all packages.
1. Make sure the correct graphics drivers are in use (e.g. the proprietary Nvidia driver).
1. Install `vim` and change the default editor to vim by running `update-alternatives --config editor` and selecting `vim.basic`.
2. Disable password for the sudo group by running `visudo` and changing the sudo group line to `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`.
3. Enable numlock on boot (search for it).
4. Appearance:
   1. Change to the dark theme.
   2. Make all fonts 1 size smaller.
5. Shortcuts:
   1. Disable web shortcuts.
   2. Add a keyboard shortcut for Dolphin (e.g. `Meta+E`) by running `kmenuedit` and changing System, Dolphin.
6. Setup panels for all screens. Only show tasks for the current screen.
7. Setup an IPTables firewall:
    - Purge `ufw firewalld`.
    - Install `iptables iptables-persistent netfilter-persistent`.
    - Create and run an IPTables script, e.g. [iptables.sh](https://github.com/HON95/configs/blob/master/pc/linux/iptables/iptables.sh).
1. Firefox:
    - Disable middle mouse paste by setting `middlemouse.paste=false` in `about:config`.

{% include footer.md %}
