---
title: VyOS
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

## Resources

- [VyOS User Guide](https://docs.vyos.io/)

## Installation

See [Installation (VyOS)](https://docs.vyos.io/en/latest/install.html).

1. (Recommended) Disable Intel Hyper-Threading.
1. Download the latest rolling release (free) or LTS release (paid) ISO.
1. Burn and boot from it (it's a live image).
1. Log in using user `vyos` and password `vyos`.
1. Run `install image` to run the permanent installation wizard.
    - Copy the `config.boot.default` config file.
1. Remove the live image and reboot.

## Initial Configuration

An example of a full configuration. Except intuitive stuff I forgot to mention.

1. Log in as user `vyos` and password as set in the installation (or `vyos` if using the live media).
    - It'll drop you directly into operational mode.
1. Fix the keyboard layout:
    - Run config TUI: `set console keymap`
    - **FIXME**: This doesn't seem to work. Relogging or restarting doesn't help either.
1. Enter configuration mode: `configure`
    - This changes the prompt from `$` to `#`.
1. Set hostname:
    1. Note: `<host-name>.<domain-name>` should be an FQDN.
    1. Hostname: `set system host-name <hostname>`
    1. Domain name: `set system domain-name <domain-name>`
1. Set the DNS servers: `set system name-server <ip-address>` (for each server)
1. Set the time zone: `set system time-zone Europe/Oslo` (Norway)
1. Set NTP servers:
    1. Enter section `system ntp`.
    1. Remove default NTP servers.
    1. Add new NTP servers: `set server ntp.justervesenet.no` (example)
1. Enable Ctrl+Alt+Del reboot: `set system options ctrl-alt-del-action reboot` (or `ignore`)
1. Replace default user:
    1. Add new user with password: `set system login user <username> authentication plaintext-password <password>`
    1. Commit and log into the new user.
    1. Delete the default user: `delete system login user vyos`
1. Set up an Internet-facing interface with an IP address: Details not included.
1. Set default routes: `set protocols static route[6] <0.0.0.0/0|::/0> next-hop <next-hop>` (for IPv4 and IPv6)
1. (Optional) Set black hole route: `set protocols static route[6] <prefix> blackhole` (for IPv4 and IPv6)
1. Enable LLDP: `set service lldp interface all`
1. Enable SSHD:
    1. Enable: `set service ssh`
    1. **TODO**
1. Enable unicast reverse path forwarding (uRPF) globally: `set firewall source-validation strict`
1. Set firewall options:
    1. Enter firewall section.
    1. `set all-ping enable`
    1. `set broadcast-ping disable`
    1. `set receive-redirects disable`
    1. `set ipv6-receive-redirects disable`
    1. `set ip-src-route disable`
    1. `set ipv6-src-route disable`
    1. `set log-martians disable`
    1. `set send-redirects disable`
1. Setup firewall:
    1. Set default policies:
        - `set firewall state-policy established action accept`
        - `set firewall state-policy related action accept`
        - `set firewall state-policy invalid action drop`
    1. Create IPv4 and IPv6 rule sets. Note that IPv4 and IPv6 rule sets can't share names, so you can suffix the names with `-4` and `-6` to avoid conflict.
    1. Attach rule sets to interfaces (typically "local" and "out").
1. Commit and save: `commit` and `save`.

## General Configuration

### CLI

- The system is in "operational mode" (`$`) after logging in. Enter "configuration mode" (`#`) using the `configure` command.
- Use `?` to show alternatives and tab to auto-complete.
- Use `run` to run operational mode commands in configuration mode.

### Basics

- System information:
    - Show log: `show log [tail]`
- Interface and routing information:
    - L2/L3 interfaces overview: `show interfaces`
    - Routes: `show ip routes` and `show ipv6 routes`
- Configuration changes:
    - Show configuration: `show`
    - Apply changes: `commit`
    - Apply changes with confirmation: `commit-confirm [comment <comment>] [minutes]`, then `confirm` within X minutes when you've verified that the changes are working as intended. Not confirming in time will cause the system to reboot.
    - Save changes: `save`

## Tasks

### Reset Admin Password

Reboot the device and wait for the boot screen. In the boot screen, select the "lost password change (KVM)" option. It will boot to into a prompt asking you to set a new password. After setting a new password, the device will automatically reboot.

{% include footer.md %}
