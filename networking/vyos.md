---
title: VyOS
breadcrumbs:
- title: Network
---
{% include header.md %}

A Debian-based router OS, forked from Vyatta. Junos-like CLI.

## Resources

- [VyOS User Guide](https://docs.vyos.io/)

## TODO

- Add notes from system optimization: https://support.vyos.io/en/support/solutions/articles/103000096273-system-optimization

## Installation

See [Installation (VyOS)](https://docs.vyos.io/en/latest/install.html).

1. For bare-metal:
    - Consider disabling Intel Hyper-Threading. It does little for memory-intensive applications like packet routing.
1. For PVE/QEMU VM:
    - Set the disk size to e.g. 10GB. It will mostly only be used for 500MB VyOS images, logs, containers and other things you might have added.
    - Disable memory ballooning/memory sharing. VyOS does not use swapping so accidental overprovisioning that could starve the VyOS VM could cause errors.
    - Enable the QEMU agent option in PVE. VyOS comes with the agent installed.
1. Download the latest rolling release (free) or LTS release (paid) ISO.
1. Burn and boot from it (it's a live image).
1. Log in using user `vyos` and password `vyos`.
1. Run `install image` to run the permanent installation wizard.
    - Keep the suggested image name to keep track of versions.
    - If asked about which config to copy, either one is fine.
1. Remove the live image and reboot.

## Minimum Configuration for Remote Access (Optional)

Steps to get SSH up ASAP so you can avoid the console. Assumes you already know how to configure VyOS, jump directly to "initial configuration" if not.

1. Log in as `vyos` with the password you set during installation.
1. Set an IPv4/IPv6 address for the interface you intend to connect through.
    1. Add address: `set int eth eth0 address 10.0.0.10/24` (example)
    1. Add DHCP address (alternative): `set int eth eth0 address dhcp` (example)
1. Set the default route as a static route, if you don't connect from the connected network configured above and are not using DHCP.
    1. Add route: `set protocols static route 0.0.0.0/0 next-hop 10.0.0.1`
1. (Optional) Set DNS servers.
    1. Add server: `set system name-server <ip-address>`
1. Set the time zone. NTP servers are already configured, but might not be syncing yet.
    1. Set time zone: `set system time-zone Europe/Oslo` (example)
    1. Commit.
    1. Check time: `run show date`
1. Add proper user, remove default user:
    1. Add new user: `set system login <user> authentication plaintext-password "<password>"`
    1. Commit, log out, log in as new user.
    1. Delete old user: `delete system login user vyos`
1. Enable SSH, without root auth:
    1. Enable: `set service ssh`
1. Commit, save and try to connect through SSH.

## Initial Configuration

An example of a full-ish configuration. Skip any steps already done in "minimum configuartion for remote access".

1. Log in as user `vyos` and password as set in the installation (or `vyos` if using the live media).
    - It'll drop you directly into operational mode.
1. Enter configuration mode: `configure`
    - This changes the prompt from `$` to `#`.
1. Set the keyboard layout:
    1. Set: `set system option keyboard-layout no` (Norwegian)
    1. Apply: `commit`
1. Set hostname:
    1. Hostname: `set system host-name <hostname>`
    1. Domain name: `set system domain-name <domain-name>`
1. Set the DNS servers: `set system name-server <ip-address>` (for each server)
1. Set the time zone: `set system time-zone Europe/Oslo` (example)
1. (Optional) Replace the NTP servers:
    1. Remove default NTP servers: `delete service ntp server`
    1. Add new NTP servers: `set service ntp server <server>` (e.g. `{0..3}.no.pool.ntp.org`)
1. (Optional) Enable Ctrl+Alt+Del reboot: `set system options ctrl-alt-del-action reboot` (or `ignore`)
1. Set up a plain WAN-facing interface with an IP address (without LAG or VLAN):
    1. Show all Ethernet interfaces: `run show interfaces ethernet detail`
    1. Enter interface config: `edit interfaces ethernet <if>`
    1. Set the MAC address if missing (from `show int ...`): `set hw-id <mac-addr>`
    1. Set description: `set description <description>`
    1. (Alternative) Set static address (IPv4 + IPv6): `set address <addr>/<prefix-length>`
    1. (Alternative) Set to get IPv4 address from DHCPv4: `set address dhcp`
    1. (Alternative) Set to get IPv6 address from DHCPv6: `set address dhcpv6`
    1. (Alternative) Set to get IPv6 address from SLAAC: `set ipv6 address autoconf`
    1. (Optional) Apply firewall policies (from global): `set firewall interface {local|in|out} {name|ipv6-name} <...>`
1. Set default routes: `set protocols static route[6] <0.0.0.0/0|::/0> next-hop <next-hop>` (for IPv4 and IPv6)
1. (Optional) Setup basic SSHD:
    1. Enable server: `set service ssh`
    1. Disable reverse DNS lookup: `set service ssh disable-host-validation`
    1. (Optional) Disable password login (pubkeys only): `set service ssh disable-password-authentication`
    1. (Optional) Commit and log in through SSH instead of the console.
1. Replace default user:
    1. (Note) You may want to skip ahead to the SSHD step so you can paste stuff vis SSH instead of manually writing it into the console.
    1. Enter new user: `edit system login user <username>`
    1. Set password: `set authentication plaintext-password "<password>"`
        - Remember quotation marks if the password string spaces.
        - To generate an `encrypted-password` instead of specifying it as plaintext, run `openssl passwd -6` on a "safe" machine. (**TODO** Is this broken in 1.3? It only adds the last characters of the supplied text.)
    1. (Optional) Add your personal SSH pubkey:
        1. Set key type: `set authentication public-keys <name> type ssh-rsa`
        1. Set key (only the Base64-encoded part): `set authentication public-keys <name> key <key>`
    1. Commit and log into the new user.
    1. Delete the default user: `delete system login user vyos`
1. (Optional) Set up a LAG interface:
    1. Enter interface config: `edit interfaces bonding bond<n>`
    1. Set member interfaces: `set member interface <if>`
    1. Enable LACP: `set mode 802.3ad`
    1. Set fast: `lacp-rate fast`
    1. Set hashing policy: `set hash-policy layer2+3`
    1. Configure as a normal interface.
1. (Optional) Set up a VLAN interface:
    1. Enter the parent/physical interface config.
    1. Enter the VLAN subinterface config: `edit vif <VID>`
    1. Configure as a normal interface.
1. (Optional) Set black hole route: `set protocols static route[6] <prefix> blackhole` (for IPv4 and IPv6)
1. Enable LLDP: `set service lldp interface all`
1. Set firewall:
    1. (Note) VyOS 1.4.xxx changed to a new firewall structure.
    1. Set options and default policies:
        1. `edit firewall global-options`
        1. `set source-validation strict` (uRPF)
        1. `set all-ping enable`
        1. `set broadcast-ping disable`
        1. `set receive-redirects disable`
        1. `set ipv6-receive-redirects disable`
        1. `set ip-src-route disable`
        1. `set ipv6-src-route disable`
        1. `set log-martians disable`
        1. `set send-redirects disable`
        1. `set syn-cookies enable`
        1. `set twa-hazards-protection disable`
    1. (**OUTDATED**) Create IPv4 and IPv6 rule sets. Note that IPv4 and IPv6 rule sets can't share names, so you can suffix the names with `-4` and `-6` to avoid conflict.
    1. (**OUTDATED**) Attach rule sets to interfaces (typically "local" and "out").
1. Set banners:
    1. (Note) Newlines must be escaped with `\n`.
    1. Set pre-login banner: `set system login banner pre-login ""` (disable)
    1. Set post-login banner: `set system login banner post-login ""`
1. Hardware tuning (bare metal):
    - (Note) VyOS automatically sets large RX/TX buffers (always?) and provides a config interface for other options now, so no need to add `ethtool` stuff to `vyos-postconfig-bootup.script` anymore.
    - (Note) For background info
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

{% include footer.md %}
