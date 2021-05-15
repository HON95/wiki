---
title: VyOS
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

## Resources

- [VyOS User Guide](https://docs.vyos.io/)

## Info

- Debian-based.
- Forked from Vyatta.

## Installation

See [Installation (VyOS)](https://docs.vyos.io/en/latest/install.html).

1. (Recommended) Disable Intel Hyper-Threading.
1. Download the latest rolling release (free) or LTS release (paid) ISO.
1. Burn and boot from it (it's a live image).
1. Log in using user `vyos` and password `vyos`.
1. Run `install image` to run the permanent installation wizard.
    - Keep the suggested image name to keep track of versions.
    - If asked about which config to copy, any one is fine.
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
1. (Optional) Replace the NTP servers:
    1. Remove default NTP servers: `delete system ntp <server>` (for each server)
    1. Add new NTP servers: `set system ntp server ntp.justervesenet.no` (example)
1. (Optional) Enable Ctrl+Alt+Del reboot: `set system options ctrl-alt-del-action reboot` (or `ignore`)
1. Set up a plain WAN-facing interface with an IP address (without LAG or VLAN):
    1. Show all Ethernet interfaces: `run show interfaces ethernet`
    1. Enter interface config: `edit interfaces ethernet <if>`
    1. Set the MAC address for the interface to bind to if missing: `set hw-id <mac-addr>`
    1. Set description: `set description <description>`
    1. (Alternative) Set static address (IPv4 + IPv6): `set address <addr>/<prefix-length>`
    1. (Alternative) Set to get IPv4 address from DHCPv4: `set address dhcp`
    1. (Alternative) Set to get IPv6 address from DHCPv6: `set address dhcpv6`
    1. (Alternative) Set to get IPv6 address from SLAAC: `set ipv6 address autoconf`
    1. (Optional) Set firewall policies: `set firewall {local | in | out} <...>`
1. Set default routes: `set protocols static route[6] <0.0.0.0/0|::/0> next-hop <next-hop>` (for IPv4 and IPv6)
1. (Optional) Setup basic SSHD:
    1. Enable server: `set service ssh`
    1. (Optional) Commit and log in through SSH instead of the console.
1. Replace default user:
    1. Note: You may want to skip ahead to the SSHD step so you can paste stuff vis SSH instead of manually writing it into the console.
    1. Enter new user: `system login user <username>`
    1. Set password: `set authentication plaintext-password "<password>"`
        - Remember quotation marks if the password string spaces.
        - To generate an `encrypted-password` instead of specifying it as plaintext, run `openssl passwd -6` on a "safe" machine.
    1. (Optional) Add your personal SSH pubkey:
        1. Set key type: `set authentication public-keys <name> type ssh-rsa`
        1. Set key (only the Base64-encoded part): `set authentication public-keys <name> key <key>`
    1. Commit and log into the new user.
    1. Delete the default user: `delete system login user vyos`
1. Setup SSHD:
    1. Enable server: `set service ssh`
    1. (Optional) Disable password login (pubkeys only): `set service ssh disable-password-authentication`
1. (Optional) Set up a LAG interface:
    1. Enter interface config: `edit interfaces bonding bond<n>`
    1. Set member interfaces: `set member interface <if>`
    1. Enable LACP: `set mode 802.3ad`
    1. Set hashing policy: `set hash-policy layer2+3`
    1. Configure as a normal interface.
1. (Optional) Set up a VLAN interface:
    1. Enter the parent/physical interface config.
    1. Enter the VLAN subinterface config: `edit vif <VID>`
    1. Configure as a normal interface.
1. (Optional) Set black hole route: `set protocols static route[6] <prefix> blackhole` (for IPv4 and IPv6)
1. Enable LLDP: `set service lldp interface all`
1. Enable unicast reverse path forwarding (uRPF) globally: `set firewall source-validation strict`
1. Set firewall:
    1. Enter `firewall` section.
    1. Set options:
        1. `set all-ping enable` (default) (still recommended to add ping rules)
        1. `set broadcast-ping disable`
        1. `set receive-redirects disable`
        1. `set ipv6-receive-redirects disable`
        1. `set ip-src-route disable`
        1. `set ipv6-src-route disable`
        1. `set log-martians disable`
        1. `set send-redirects disable`
    1. Set default policies:
        - `set firewall state-policy established action accept`
        - `set firewall state-policy related action accept`
        - `set firewall state-policy invalid action drop`
    1. Create IPv4 and IPv6 rule sets. Note that IPv4 and IPv6 rule sets can't share names, so you can suffix the names with `-4` and `-6` to avoid conflict.
    1. Attach rule sets to interfaces (typically "local" and "out").
1. (Optional) Tuning (bare metal):
    - **TODO** This can be done in the interface ethernet configs instead.
    - See the Linux router notes.
    - Enable GRO (example): `ethtool -K <if> gro on`
    - Increase RX/TX buffer sizes (example): `ethtool -G <if> tx 4096 rx 4096`
    - Enable scatter/gather aka vectored I/O (example): `ethtool -K <if> sg on`
    - Make any ethtool (e.g.) commands permanent by adding them to `/config/scripts/vyos-postconfig-bootup.script`.
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
        - Running this in conf mode shows any changes.
        - Run this in op mode if you intend to copy it from the terminal, to avoid the change indentation.
    - Apply changes: `commit`
    - Apply changes with confirmation: `commit-confirm [comment <comment>] [minutes]`
        - Run `confirm` within N minutes when you've verified that the changes are working as intended.
        - Not confirming in time will cause the system to reboot.
    - Save changes: `save`

## Tasks

### Reset Admin Password

Reboot the device and wait for the boot screen. In the boot screen, select the "lost password change (KVM)" option. It will boot to into a prompt asking you to set a new password. After setting a new password, the device will automatically reboot.

### Add Service

This example shows how to download an application to persistent storage and run it at boot as a service.

1. Enter persistent storage: `cd /usr/lib/live/mount/persistence/`
1. Create an `opt` dir to store apps in: `mkdir opt` and `cd opt`.
1. Download the app: `wget <whatever-v0>` and extract it (keep the version number).
1. Make a symlink without the version number: `ln -s <whatever-v0> <whatever>`
1. Try to run the executable to make sure it works.
1. Make a folder too keep systemd service files: `mkdir systemd`
1. Create a service file for the application as `systemd/<whatever>.service` (see example below).
1. Make sure the service works by manually adding it and starting it (see the script to do it automatically at boot).
1. Add and start the service at boot by adding it through `/config/scripts/vyos-postconfig-bootup.script` (see example below).
1. Reboot and make sure it works (`systemctl status <whatever>.service`).

Example service file (`<whatever>.service`):

```
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/lib/live/mount/persistence/opt/node_exporter/node_exporter --collector.interrupts

[Install]
WantedBy=multi-user.target
```

Example `/config/scripts/vyos-postconfig-bootup.script` (excluding old stuff):

```sh
# ...

# Enable Node Exporter
if [[ -f /usr/lib/live/mount/persistence/opt/systemd/node-exporter.service ]]; then
    ln -s /usr/lib/live/mount/persistence/opt/systemd/node-exporter.service /etc/systemd/system/node-exporter.service
    systemctl daemon-reload
    systemctl enable --now node-exporter.service
fi
```

## Random Notes

- The DHCPv4 relay requires the interface towards the upstream DHCP server to be included in the relay interfaces. Otherwise the responses from the upstream server will be dropped. The relay is also very bugged at the moment so I'd recommend not using it until it gets fixed. See [T377](https://phabricator.vyos.net/T377) and [T1276](https://phabricator.vyos.net/T1276).

{% include footer.md %}
