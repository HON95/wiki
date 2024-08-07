---
title: Debian Server
breadcrumbs:
- title: Linux Servers
---
{% include header.md %}

Using **Debian 12 (Bookworm)**.

## Basic Setup

### Installation

- Always verify the downloaded installation image after downloading it.
- If installing in a Proxmox VE VM, see [Proxmox VE: VMs: Initial Setup](/virt/proxmox-ve/#initial-setup).
- Prefer UEFI if possible.
- Use the non-graphical installer. It's basically exactly the same as the graphical one.
- If it mentions missing non-free firmware, take note of the packages so they can be installed later.
- Localization:
    - For automation-managed systems: It doesn't matter.
    - Language: United States English.
    - Location: Your location.
    - Locale: United States UTF-8 (`en_US.UTF-8`).
    - Keymap: Your keyboard's keymap.
- Network settings:
    - Whatever is more practical, typically static addresses for static servers and DHCP/autoconfiguration for everything else.
    - Certain NICs require non-free drivers (which are not included in the public ISOs) (e.g. `bnx2`). The installer will typically show a warning about the missing firmware, but sometimes it won't and the NIC will be listed but won't be able to access the network properly (e.g. DHCP failing). To get around this you may load the driver from removable media, or connect a temporary NIC for Internet access to finish the install and to download/install the non-free driver for the other NIC(s).
- Use an FQDN as the hostname.
    - For automation-managed systems: It doesn't matter, just leave it as `debian` or something.
    - It'll automatically split it into the shortname and the FQDN.
    - If using automation to manage the system, this doen't matter.
- Use separate password for root and your personal admin user.
    - For automation-managed systems: The passwords may be something temporary and the non-root user may be called e.g. `ansible` (for the initial automation).
- System disk partitioning:
    - Simple system: Guided, single partition, use all available space.
    - Advanced system: Manually partition, see [system storage](/linux-servers/storage/#system-storage).
    - Swap can be set up later as a file or LVM volume. It isn't really that useful anymore.
    - When using LVM: Create the partition for the volume group, configure LVM (separate menu), configure the LVM volumes (filesystem and mount).
- Package manager:
    - Just pick whatever it suggests.
- Software selection:
    - Just "SSH server", so e.g. Ansible can reach it.
- GRUB bootloader (no longer asked):
    - Install to the suggested root disk (e.g. `/dev/sda`).

### Prepare for Ansible Configuration (if Ansible)

Do this if you're going to use Ansible to manage the system.
This is mainly to make the system accessible by Ansible, which can then take over the configuration.
If creating a template VM, run the first instructions before saving the template and then run the last instructions on cloned VMs.

1. Upgrade all packages: `apt update && apt full-upgrade`
    1. If anything significant was updated, restart the server.
1. Install the required packages: `apt install openssh-server sudo python3 vim`
    - If PVE/QEMU VM, install `qemu-guest-agent`.
1. Setup sudo for Ansible: `usermod -aG sudo ansible`
1. (Optional, for PVE VMs) Convert the VM into a template:
    1. Shut down the VM.
    1. Change to a template.
    1. Clone it into a new VM to be used hereafter.
    1. Boot the new VM and continue with the setup.
1. (Optional, for non-cloud) Set static IP addresses in `/etc/network/interfaces` (see the example below).
1. Reboot.

Example `/etc/network/interfaces`:

```
source /etc/network/interfaces.d/*

auto lo
ïface lo inet loopback

allow-hotplug ens18
iface ens18 inet static
    address 10.0.0.100/22
    gateway 10.0.0.1
iface ens18 inet6 static
    address fdaa:aaaa:aaaa:0::100/64
    gateway fdaa:aaaa:aaaa:0::1
    accept_ra 0
```

### Manual Configuration (if not Ansible)

The first steps (`(Skip)`) may be skipped if already configured during installation (i.e. not cloning a template VM).

1. (Skip) Check the system status:
    - Check for failed services: `systemctl --failed`
    - Check that AppArmor is operational: `apparmor_status`
1. (Skip) Update the root password: `passwd`
1. (Skip) Localization:
    - Check current locale:
        - `locale` should return `en_US.UTF-8`.
        - Update if wrong: `update-locale LANG=en_US.UTF-8`
    - Check the keymap:
        - Try typing characters specific to your keyboard.
        - Update if wrong: `dpkg-reconfigure keyboard-configuration`
1. (Skip) Set the hostname:
    - Set the shortname: `hostnamectl set-hostname <shortname>` (no domain)
    - Set both the shortname and FQDN in `/etc/hosts` using the following format, one line for IPv4 and one for IPv6: `<ip-addr> <fqdn> <shortname>`
    - Check the hostname info:
        - Shortname: `hostname`
        - FQDN: `hostname --fqdn`
        - IP addresses: `hostname --ip-address`
1. Packages:
    - (Optional) Enable the `contrib` and `non-free` repo areas: `add-apt-repository <area>`
        - Or by setting `main contrib non-free` for every `deb`/`deb-src` in `/etc/apt/sources.list`.
    - Update, upgrade and auto-remove.
    - Install: `sudo apt install ca-certificates software-properties-common man-db tree vim screen curl net-tools dnsutils moreutils htop iotop irqtop nmap`
    - (Optional) Install per-user tmpdirs: `libpam-tmpdir`
1. (Optional) Configure editor (Vim):
    - Update the default editor: `sudo update-alternatives --config editor`
    - Disable mouse globally: In `/etc/vim/vimrc.local`, add `set mouse=` and `set ttymouse=`.
    - Fix YAML formatting globally: In `/etc/vim/vimrc.local`, add `autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab`.
1. Add mount options:
    - (Not recommended) Setup hidepid:
        - (Note) Hidepid breaks certain systemd things. It's not recommended to use it until that gets fixed.
        - (Note) The `adm` group will be granted access.
        - Add your personal user to the PID monitor group: `usermod -aG adm <user>`
        - Enable hidepid in `/etc/fstab`: `proc /proc proc defaults,hidepid=2,gid=<adm-gid> 0 0` (using the numerical GID of `adm`)
    - (Optional) Disable the tiny swap partition added by the guided installer by commenting it in the fstab.
    - (Optional) Setup extra mount options: See [Storage](system.md).
    - Run `mount -a` to validate fstab.
    - (Optional) Restart the system.
1. Setup your personal user:
    - If it doesn't exist, create it: `adduser <username>`
    - Add the relevant groups (using `usermod -aG <group> <user>`):
        - `sudo` for sudo access.
        - `systemd-journal` for system log access.
        - `adm` for hidepid, to see all processes (if using hidepid).
    - Add your personal SSH pubkey to `~/.ssh/authorized_keys` and fix the owner and permissions (700 for dir, 600 for file).
        - Hint: Get `https://github.com/<user>.keys` and filter the results.
    - Try logging in remotely and gain root access through sudo.
1. Setup SSHD:
    - In `/etc/ssh/sshd_config`, set:
      ```
      PermitRootLogin no
      PasswordAuthentication no
      # Optional, disable TCP port forwarding
      AllowTcpForwarding no
      GatewayPorts no
      # Comment out to avoid locale issues (or fix it some proper way)
      #AcceptEnv ...
      ```
    - Restart `sshd`.
1. Update MOTD:
    - Clear `/etc/motd`, `/etc/issue` and `/etc/issue.net`.
    - (Optional) Add a MOTD script (see below).
1. (10/Buster and older) (Optional) Enable persistent logging:
    - (Note) Persistent logging is the default for Debian 11/Bullseye, but not Debian 10/Buster.
    - In `/etc/systemd/journald.conf`, under `[Journal]`, set `Storage=persistent`.
    - (Note) `auto` (the default) is like `persistent`, but does not automatically create the log directory.
    - (Note) The default journal directory is `/var/log/journal`.

### Machine-Specific Configuration

#### Physical Host

1. Install extra firmware:
    - Enable the `non-free` repo areas.
    - Update microcode: Install `intel-microcode` (for Intel) or `amd64-microcode` (for AMD) and reboot (now or later).
    - (Note) APT package examples: `firmware-atheros -bnx2 -bnx2x -ralink -realtek`
    - If it asked to install non-free firmware in the initial installation installation, try to install it now.
    - Install firmware from other sources (e.g. for some Intel NICs).
    - (Optional) To install all common common firmware and microcode, install `firmware-linux` (or `firmware-linux-free`) (includes e.g. microcode packages).
1. Setup smartmontools to monitor S.M.A.R.T. disks:
    1. Install `smartmontools`.
    1. (Optional) Monitor disk: `sudo smartctl -s on <dev>`.
1. Setup lm_sensors to monitor sensors:
    1. Install `lm-sensors`.
    1. Run `sensors` to make sure it runs without errors and shows some (default-ish) sensors.
    1. For further configuration (more sensors) and more info, see [Linux Server Applications: lm_sensors](/linux-servers/applications/#lm_sensors).
1. Check the performance governor and other frequency settings:
    1. Install `linux-cpupower`.
    1. Show: `cpupower frequency-info`
        - Check the boost state should be on (Intel).
        - Check the current performance governor (e.g. "powersave", "ondemand" or "performance").
    1. (Optional) Temporarily change performance governor: `cpupower frequency-set -g <governor>`
    1. (Optional) Permanently change performance governor: **TODO**
1. (Not recommended) Mask `ctrl-alt-del.target` to disable CTRL+ALT+DEL reboot at the login screen.

#### QEMU Virtual Host

1. Install QEMU guest agent: `apt install qemu-guest-agent`

### Networking

#### Network Manager

##### Using ifupdown (Alternative 1)

This is used by default and is the simplest to use for simple setups.

1. For VLAN support, install `vlan`.
1. For bonding/LACP support, install `ifenslave`.
1. Configure `/etc/network/interfaces`.
1. Reload the config (per interface): `systemctl restart ifup@<if>.service`
    - Don't restart `networking.service` or call `ifup`/`ifdown` directly, this is deprecated and may cause problems.

##### Using systemd-networkd (Alternative 2)

This is the systemd way of doing it and is recommended for more advanced setups as ifupdown is riddled with legacy/compatibility crap.

1. Add a simple network config: Create `/etc/systemd/network/lan.network` based on [main.network](https://github.com/HON95/configs/blob/master/systemd-network/main.network).
1. Disable/remove the ifupdown config: `mv /etc/network/interfaces /etc/network/interfaces.old`
1. Enable the service: `systemctl enable --now systemd-networkd`
1. Purge `ifupdown` and `ifupdown2`.
1. Check status: `networkctl [status [-a]]`
1. Restart the system to make sure all ifupdown stuff is stopped (like orphaned dhclients).

##### Configure IPv6/NDP/RA Securely

Prevent enabled (and potentially untrusted) interfaces from accepting router advertisements and autoconfiguring themselves, unless autoconfiguration is what you intended.

- Using ifupdown: Set `accept_ra 0` for all `inet6` interface sections.
- Using systemd-networkd: See example config above.
- Using firewall: If the network manager can't be set to ignore RAs, just block them. Alternatively, block all ICMPv6 in/out if IPv6 shouldn't be used on this interface at all. This is not needed with ifupdown or systemd-networkd.

#### Firewall

1. Install `apt install iptables iptables-persistent netfilter-persistent`
    - Don't save the current rules when it asks.
1. Manually add IPTables rules or make [a simple iptables script](https://github.com/HON95/scripts/blob/master/iptables/iptables.sh) or something.
1. Open a new SSH session and make sure you can still log in without closing the current one.
1. (Note) If you flush the firewall and reconfigure it, remember to restart services modifying it (like libvirt, Docker, Fail2Ban).

#### DNS

**TODO** Setup `resolvconf` to prevent automatic `resolv.conf` changes?

##### Using systemd-resolved (Alternative 1)

1. (Optional) Make sure no other local DNS servers (like dnsmasq) is running.
1. Configure `/etc/systemd/resolved.conf`
    - `DNS`: A space-separated list of DNS servers.
    - (Optional) `Domains`: A space-separated list of search domains.
    - (Optional) `DNSSEC`: Set to `no` to disable (only if you have a good reason to, like avoiding the chicken-and-egg problem with DNSSEC and NTP).
1. (Optional) If you're hosting a DNS server on this machine, set `DNSStubListener=no` to avoid binding to port 53.
1. Enable the service: `systemctl enable --now systemd-resolved.service`
1. Link `/etc/resolv.conf`: `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
1. Check status: `resolvectl`

##### Using resolv.conf (Alternative 2)

The simplest alternative, without any local system caching.

1. Make sure `/etc/resolv.conf` is a regular file and not a symlink.
1. Manually configure `/etc/resolv.conf`.
1. (Optional) Make it immutable to prevent services (like dhclient) from changing it: `chattr +i /etc/resolv.conf`

#### NTP

This is typically correct by default. Note that systemd-timesyncd uses SNTP, where only one NTP server is used.

1. Check the timezome and network time status: `timedatectl`
1. (Optional) Fix the timezone: `timedatectl set-timezone Europe/Oslo`
1. (Optional) Fix enable network time: `timedatectl set-ntp true`
1. Configure `/etc/systemd/timesyncd.conf`:
    - `NTP` (optional): A space-separated list of NTP servers. The defaults are fine. Only one is used.
1. Restart `systemd-timesyncd`.
1. Check status works: `timedatectl` and `timedatectl timesync-status` (check which servers are used)

#### Miscellanea

1. Make sure IPv6 and NDP is configured securely (prevent accidental autoconfiguration on untrusted interfaces):
    - For ifupdown, set `accept_ra 0` for all `inet6` interface sections which should not use SLAAC.
    - If configuring the interface to not accept RAs, ICMPv6/NDP may be firewalled on the untrusted interfaces.
1. Reboot and make sure everything still works.

### Extra

Everything here is optional.

- Setup BASH auto-completion:
    - This is typically installed by default.
    - Install it: `sudo apt install bash-completion`
    - Enable it globally: Find the commented `bash-completion` block in `/etc/bash.bashrc` and uncomment it.
- Setup Fail2Ban:
    - Recommended for public-facing servers.
    - Fix the firewall first so it configures itself correctly wrt. which firewall is used.
    - Install: `apt install fail2ban`
    - Check status: `fail2ban-client status [sshd]`
    - See [Linux Server Applications: Fail2Ban](applications.md#fail-2-ban) for more info.
- Set up a swap file:
    1. (Note) You should have enough memory installed to never need swapping, but it's a nice backup to prevent the system from potentially crashing if anything bugs out and eats up too much memory.
    1. Show if swap is already enabled: `swapon --show`
    1. Allocate the swap file: `fallocate -l <size> /swapfile`
        - Alternatively, use dd.
    1. Fix the permissions: `chmod 600 /swapfile`
    1. Setup the swap file: `mkswap /swapfile`
    1. Activate the swap file: `swapon /swapfile`
        - Check: `swapon --show`
    1. Add it to fstab using this line: `/swapfile swap swap defaults 0 0`
        - Check: `mount -a`
- Setup Postfix mail relay: See [Linux Server Applications: Postfix](/linux-servers/applications/#postfix).
- Prevent root local login:
    - Alternatively, keep it enabled with a strong password as a local backdoor for recovery or similar.
    - Add a personal user first.
    - Check that the password field (the second field) for root in `/etc/shadow` is something invalid like "\*" or "!", but not empty and not valid password hash. This prevents password login.
    - Clear `/etc/securetty` to prevent root local/console login.
- Extra package security:
    - Install `apt-listbugs` and `apt-listchanges` and run them before upgrading a package.
    - Install `needrestart` and run it after upgrading.
    - Install `debsums` and run it after upgrading to check deb checksums.
    - Install `debsecan` to get automatically alerted when new vulnerabilities are discovered and security updates are available.
- Google Authenticator 2FA:
    - Potentially useful for public-facing servers.
    - **TODO** See old notes.
- Install and run Lynis security auditor:
    - Install: `apt install lynis`
    - Run: `lynis audit system`
- MOTD:
    - Clear `/etc/motd`, `/etc/issue` and `/etc/issue.net`.
    - Download [dmotd.sh](https://github.com/HON95/scripts/blob/master/login/dmotd.sh) to `/etc/profile.d/`.
    - Install the dependencies: `neofetch lolcat`
    - Add an ASCII art (or Unicode art) logo to `/etc/logo`, using e.g. `figlet <text>` or [TAAG](http://patorjk.com/software/taag/).
    - (Optional) Add a MOTD to `/etc/motd`.
    - Test it: `su - <some-normal-user>`
- Setup monitoring:
    - Use Prometheus with node exporter or something and set up alerts.

## Troubleshooting

**`network-online.target` is stalling during boot**:

- See all services it depends on: `systemctl show -p WantedBy network-online.target`
- Disable the unused services which stall.

**Firmware for the network card fails to load**:

- Causes a syslog record like "firmware: failed to load rtl\_nic/rtl8168g-3.fw (-2)" when trying to up the interface.
- Might happen after installation even if working initially (for some reason).
- Realtek solution: Enable the "non-free" repo and install "firmware-realtek".

**Perl complains about a locale error**:

- Test with `perl -e exit`. It will complain if there's an error.
- Check the locale: `locale`
- Comment `AcceptEnv LANG LC_*` in `/etc/ssh/sshd_config` to prevent remote clients bringing their own locale.

**Boot volume is full**:

- If this failed during a software upgrade, take note of the error.
- Most of the time `apt auto-remove` should be enough.
- Manually remove old kernels (if there's still not enough space):
    - List installed kernels with `dpkg -l | tail -n +6 | egrep 'linux-image-[0-9]+' | grep -Fv $(uname -r)`
    - `rc` means already removed, `iU` means it’s queued for install, `ii` means eligible for removal.
    - Remove all kernels marked `ii` by apt-uninstalling `linux-image-X-generic linux-image-X linux-image-X-common`.
    - Run another `apt auto-remove` just in case (pointless?).
- Afterwards:
    - If it ran out of space during an APT software upgrade, run `apt install -f` to fix any packages which failed and maybe a `apt upgrade` in case there's more upgrades.
    - Make sure the initramfs isn't corrupt (if it ran out of space during an upgrade) by running `update-initramfs -u -k all`.

## Miscellanea

### Cron

- Don't use periods (including file extensions) in the hourly/daily/weekly/monthly scripts.

{% include footer.md %}
