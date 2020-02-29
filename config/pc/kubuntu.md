---
title: Kubuntu
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}

- Kubuntu 19.10

## Installation

1. Use the guided partitioner.
    - The manual installer is broken and can't create encrypted volumes.

## Setup

1. Upgrade all packages.
1. Make sure the correct graphics drivers are in use (e.g. the proprietary Nvidia driver).
1. Install `vim` and change the default editor to vim by running `update-alternatives --config editor` and selecting `vim.basic`.
1. Disable password for the sudo group by running `visudo` and changing the sudo group line to `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`.
1. Enable numlock on boot (search for it).
1. Appearance:
   1. Change to the dark theme.
   1. Make all fonts 1 size smaller.
1. Shortcuts:
   1. Disable web shortcuts.
   1. Add a keyboard shortcut for Dolphin (e.g. `Meta+E`) by running `kmenuedit` and changing System, Dolphin.
1. Setup panels for all screens. Only show tasks for the current screen.
1. Setup an IPTables firewall:
    - Remove other firewalls: `apt purge ufw firewalld`.
    - Install `iptables iptables-persistent netfilter-persistent`.
    - Create and run an IPTables script, e.g. [iptables.sh](https://github.com/HON95/configs/blob/master/pc/linux/iptables/iptables.sh).
1. Firefox:
    - Disable middle mouse paste by setting `middlemouse.paste=false` in `about:config`.
1. Setup audio devices:
    - In `/etc/pulse/daemon.conf`:
        - Set: `default-sample-format = S24LE`
        - Set: `default-sample-rate = 48000`
        - Reload (as user): `pulseaudio -k`
1. Install encrypted DVD support:
    - Install: `sudo apt install libdvd-pkg && sudo dpkg-reconfigure libdvd-pkg`
    - Warning: Don't change the region if not necessary. It's typically limited to five changes.
1. Install [GameMode](https://github.com/FeralInteractive/gamemode):
    - `sudo apt install gamemode`

{% include footer.md %}
