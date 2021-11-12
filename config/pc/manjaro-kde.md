---
title: Manjaro (KDE)
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}

- Manjaro 21.1 (KDE edition)

## Installation

Nothing special.

## Setup

1. Packages:
    - Install upgrades: `sudo pacman -Syu`
    - Install extra stuff: `sudo pacman -S curl vim nmap`
1. Setup default editor:
    - Create a new profile file: `/etc/profile.d/editor.sh`
    - Set the editor: `export EDITOR=vim`
    - Set the visual editor: `export VISUAL=vim`
1. Setup sudo:
    - Login as root to avoid locking yourself out: `sudo -i`
    - Enter the sudo editor by running `visudo` and add passwordless sudo for the `wheel` group by setting `%wheel ALL=(ALL) NOPASSWD: ALL`.
    - Remove the old wheel sudo config: `rm /etc/sudoers.d/10-installer`
1. Make sure the correct graphics drivers are in use (e.g. the proprietary Nvidia driver).
1. Fix the displays (positions, resolutions, refresh rates).
1. Enable numlock on boot (search for it).
1. Appearance:
   - Change to the dark theme.
   - Make all fonts 1 size smaller.
1. Shortcuts:
   - Disable web search keywords.
1. Setup panels for all screens. Only show tasks for the current screen.
1. Setup clipboard (avoid storing copied passwords and such):
    - Open the clipboard settings from the taskbar.
    - Select "ignore selection" to avoid copying when selecting text.
    - Set the history size to 1 (effectively disabling the history).
1. Setup firewall:
    - Install IPTables: `sudo pacman -S iptables`
    - Enable the IPTables services: `sudo systemctl enable iptables.service ip6tables.service`
    - Download my IPTables script: `wget https://raw.githubusercontent.com/HON95/scripts/master/linux/iptables/iptables.sh -O /etc/iptables/config.sh`
    - Make it executable: `chmod +x /etc/iptables/config.sh`
    - Modify it.
    - Run it: `/etc/iptables/config.sh`
1. Firefox:
    - Disable middle mouse paste by setting `middlemouse.paste` to false in `about:config`.
    - Enable middle mouse "drag scrolling" by setting `general.autoScroll` to true in `about:config`.
    - Disable external media keys by setting `media.hardwaremediakeys.enabled` to false in `about:config`.

### Extra

1. Install applications: See [PC Applications](/config/pc/applications/).

{% include footer.md %}
