---
title: Kubuntu
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}

- Kubuntu 20.10

## Installation

1. Disconnect all network interfaces.
    - This will prevent an APT bug crashing the installer at the very end.
1. Use the guided partitioner.
    - The manual installer is broken and can't create encrypted volumes.

## Setup

1. Packages:
    - Install upgrades: `sudo apt update && sudo apt dist-upgrade --autoremove`
    - Install extra stuff: `sudo apt install curl vim nmap`
1. Setup default editor:
    - Set editor: `sudo update-alternatives --config editor` and select `vim.basic`.
1. Disable password for the sudo group by running `visudo` and changing the sudo group line to `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`.
1. Make sure the correct graphics drivers are in use (e.g. the proprietary Nvidia driver).
1. Fix the displays (positions, resolutions, refresh rates).
1. Enable numlock on boot (search for it).
1. Appearance:
   - Change to the dark theme.
   - Make all fonts 1 size smaller.
1. Shortcuts:
   - Disable web search keywords.
1. Setup panels for all screens. Only show tasks for the current screen.
1. Setup clipboard:
    - Open the clipboard settings from the taskbar.
    - Set the history size to 1 (effectively disabling the history).
1. Setup firewall:
    - Remove other firewalls: `apt purge ufw firewalld`.
    - Install `iptables iptables-persistent netfilter-persistent`.
    - Create and run an IPTables script, e.g. [iptables.sh](https://github.com/HON95/configs/blob/master/pc/linux/iptables/iptables.sh).
1. Firefox:
    - Disable middle mouse paste by setting `middlemouse.paste` to false in `about:config`.
    - Enable middle mouse "drag scrolling" by setting `general.autoScroll` to true in `about:config`.
    - Disable external media keys by setting `media.hardwaremediakeys.enabled` to false in `about:config`.
    - Install missing language support: `apt install $(check-language-support)`

### Extra

1. Install applications: See [PC Appluications](/config/pc/applications/).
1. (Optional) Install encrypted DVD support:
    - Install: `sudo apt install libdvd-pkg && sudo dpkg-reconfigure libdvd-pkg`
    - Warning: Don't change the region if not necessary. It's typically limited to five changes.

## Troubleshooting

**The system settings and other apps crash after updating the graphics driver:**

Reboot the system.

{% include footer.md %}
