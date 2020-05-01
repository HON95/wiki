---
title: Raspberry Pi
breadcrumbs:
- title: Configuration
- title: IoT
---
{% include header.md %}

### Using
{:.no_toc}

**OS:** Raspbian Buster

**Hardware models:** B, 3B

## Setup

### Installation

1. Download Raspbian: [Download Raspbian (Raspberry Pi)](https://www.raspberrypi.org/downloads/raspbian/)
    - Use the desktop version for DE and the Lite version for no DE.
1. Burn it to the SD card.
    - Make sure the SD card is compatible: [SD Cards (Raspberry Pi)](https://www.raspberrypi.org/documentation/installation/sd-cards.md)
    - Windows: Use Win32DiskImager.
1. Mount the SD card in the Raspi and power it on.

### Basic Setup with Desktop Environment

1. Follow the configuration wizard.
    - Set a password for the "pi" user.
1. Turn off Bluetooth and/or Wi-Fi if not used.
1. In "Raspberry Pi Configuration":
    1. (Optional) Disable auto login.
    1. Disable all unused interfaces.
    1. Fix the keyboard layout.

### Basic Setup without Desktop Environment

1. Default credentials: Username `pi`, password `raspberry`.
1. Configure through the menu: `raspi-config`
    - Go through all the options.
    - Locale and default locale: Use `en_US.UTF-8`.
    - Disable all interfaces except SSH (disable SSH too if not needed).
    - If a black border is present, disable overscan.
1. Upgrade the system and install stuff:
    - Upgrade: `apt update && apt upgrade`
    - Install basics: `apt install vim htop screen`
1. Add personal admin user:
    1. Create user: `adduser <user>`
    1. Add SSH key (from a GitHub user in this case):
        1. `cd /home/<user>`
        1. `mkdir .ssh`
        1. `curl https://github.com/<user>.keys >> .ssh/authorized_keys`
        1. `chown -R <user>:<user> .ssh`
        1. `chmod 700 .ssh` and `chmod 600 .ssh/*`
    1. Make user sudoer: `usermod -aG sudo <user>`
    1. Let user see system logs: `usermod -aG systemd-journal <user>`
    1. Try logging into the user locally and through SSH.
1. Delete default user: `deluser pi`
1. Configure SSHD:
    - `PermitRootLogin no`
    - `PasswordAuthentication no`
    - `AllowTcpForwarding no`
    - `GatewayPorts no`
    - `AcceptEnv LANG LC_*`
    - Restart `sshd` and try to open a new session.
1. Remove the MOTD: `> /etc/motd`

## Applications

### Raspotify

A Spotify Connect community client.

See [dtcooper/raspotify (GitHub)](https://github.com/dtcooper/raspotify).

{% include footer.md %}
