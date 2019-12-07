---
title: Raspberry Pi
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: IoT
---
{% include header.md %}

### Using
Raspbian

## Basic Setup

- Default credentials: Username `pi`, password `raspberry`.
- Configure through the menu: `raspi-config`
  - Go through all the options.
  - Locale and default locale: Use `en_US.UTF-8`.
  - Disable all interfaces except SSH (disable SSH too if not needed).
  - If a black border is present, disable overscan.
- Upgrade the system: `apt update && apt upgrade`
- Install packages: `vim htop screen`
- Add personal admin user:
  - Create user: `adduser <user>`
  - Add SSH key (from a GitHub user in this case):
    - `cd /home/<user>`
    - `mkdir .ssh`
    - `curl https://github.com/<user>.keys >> .ssh/authorized_keys`
    - `chown -R <user>:<user> .ssh`
    - `chmod 700 .ssh` and `chmod 600 .ssh/*`
  - Make user sudoer: `usermod -aG sudo <user>`
  - Let user see system logs: `usermod -aG systemd-journal <user>`
  - Try loggin into the user locally and through SSH
- Delete default user: `deluser pi`
- Configure SSHD:
  - `PermitRootLogin no`
  - `PasswordAuthentication no`
  - `AllowTcpForwarding no`
  - `GatewayPorts no`
  - `AcceptEnv LANG LC_*`
  - Restart `sshd` and try to open a new session.
- Remove the MOTD: `> /etc/motd`

{% include footer.md %}
