---
title: Debian Server
breadcrumbs:
- title: Configuration
- title: Server
---
{% include header.md %}

### Using
{:.no_toc}

- Debian 10 Buster

## Basic Setup

### Installation

- Always verify the downloaded installation image after downloading it.
- Use UEFI if possible.
- Use the non-graphical installer. It's basically the same as the graphical one.
- Localization:
    - Language: United States English.
    - Location: Your location.
    - Locale: United States UTF-8 (`en_US.UTF-8`).
    - Keymap: Your keyboard's keymap.
- Use an FQDN as the hostname. It'll set both the shortname and the FQDN.
- Use separate password for root and your personal admin user.
- System disk partitioning:
    - (Recommended for "simple" systems) Manually partition: One partition using all space, mounted as EXT4 at `/`.
    - (Recommended for "complex" systems) Manually partition, see [system storage](../storage/#system-storage).
    - Swap can be set up later as a file or LVM volume.
    - When using LVM: Create the partition for the volume group, configure LVM (separate menu), configure the LVM volumes (filesystem and mount).
- At the software selection menu, select only "SSH server" and "standard system utilities".
- If it asks to install non-free firmware, take note of the packages so they can be installed later.
- Install GRUB to the used disk.

### Basic Configuration

1. Login as root.
    - Since sudo is not installed yet, use `su -` if you log in through a non-root user.
1. Check the system status:
    - Check for failed services: `systemctl --failed`
    - Check that AppArmor is operational: `apparmor_status`
1. Update the root password: `passwd`
1. Localization:
    - Check current locale:
        - `locale` should return `en_US.UTF-8`.
        - Update if wrong: `update-locale LANG=en_US.UTF-8`
    - Check the keymap:
        - Try typing characters specific to your keyboard.
        - Update if wrong: `dpkg-reconfigure keyboard-configuration`
1. Set the hostname:
    - Set the shortname: `hostnamectl set-hostname <shortname>`
    - Set both the shortname and FQDN in `/etc/hosts` using the following format: `127.0.0.1 <fqdn> <shortname>`
    - Check the hostnames with `hostname` (shortname) and `hostname --fqdn` (FQDN).
1. Packages:
    - (Optional) Enable the `contrib` and `non-free` repo areas: Add `contrib non-free` to every line in `/etc/apt/sources.list`.
    - Update, upgrade and auto-remove.
    - Install basics: `sudo ca-certificates`
    - Install extra tools: `tree vim screen curl net-tools htop iotop irqtop nmap`
    - Install per-user tmpdirs: `libpam-tmpdir`
    - Install Postfix: Install `postfix` and select "satellite system" if the system will only send email.
1. Add mount options:
    - Setup hidepid:
        - Add PID monitor group: `groupadd -g 1500 pidmonitor`
        - Add your personal user to the PID monitor group: `usermod -aG pidmonitor <user>`
        - Enable hidepid in `/etc/fstab`: `proc /proc proc defaults,hidepid=2,gid=1500 0 0`
    - (Optional) Setup extra mount options: See [Storage](system.md).
    - Run `mount -a` to validate fstab.
    - (Optional) Restart the system for it to take effect.
1. Setup your personal user:
    - If it doesn't exist, create it: `adduser <username>`
    - Add the relevant groups (using `usermod -aG <group> <user>`):
        - `sudo` for sudo access.
        - `systemd-journal` for system log access.
        - `hidepid` (whatever it's called) if using hidepid, to see all processes.
    - Add your personal SSH pubkey to `~/.ssh/authorized_keys` and fix the owner and permissions (700 for dir, 600 for file).
        - Hint: Get `https://github.com/<user>.keys` and filter the results.
    - Try logging in remotely and gain root access through sudo.
1. Setup SSHD:
    - In `/etc/ssh/sshd_config`, set:
      ```
      PermitRootLogin no
      PasswordAuthentication no
      AllowTcpForwarding no
      GatewayPorts no
      #AcceptEnv ...
      ```
    - Restart `sshd`.
1. Update MOTD:
    - Clear `/etc/motd` and `/etc/issue`.
    - (Optional) Add a MOTD script (see below).
1. (Optional) Set up a swap file:
    1. (Note) Avoid using swapping if possible. If you really need it but don't intend on using it too often (e.g. for hibernation), consider putting it on a larger, slower disk.
    1. Show if swap is already enabled: `swapon --show`
    1. Allocate the swap file: `fallocate -l <size> /swapfile`
        - Alternatively, use dd.
    1. Fix the permissions: `chmod 600 /swapfile`
    1. Setup the swap file: `mkswap /swapfile`
    1. Activate the swap file: `swapon /swapfile`
        - Check: `swapon --show`
    1. Add it to fstab using this line: `/swapfile swap swap defaults 0 0`
        - Check: `mount -a`
1. (Optional) Enable persistent logging:
    - The default journal directory is `/var/log/journal`. By default, it's not automatically created.
    - In `/etc/systemd/journald.conf`, under `[Journal]`, set `Storage=persistent`.
    - `auto` (the default) is like `persistent`, but does not automatically create the log directory.
1. (Recommended) Setup Postfix mail relay: See [Linux Server Applications: Postfix](../applications/#postfix).
1. (Recommended) Setup APT update emails: See [Linux Server Applications: Apticron](../applications/#apticron).
1. (Recommended) Setup Fail2Ban:
    - Recommended for public-facing servers.
    - Fix the firewall first so it configures itself correctly wrt. which firewall is used.
    - Install: `apt install fail2ban`
    - Check status: `fail2ban-client status [sshd]`
    - See [Linux Server Applications: Fail2Ban](applications.md#fail-2-ban) for more info.
1. (Not recommended) Prevent root login:
    - Alternatively, keep it enabled with a strong password as a local backdoor for recovery or similar.
    - Add a personal user first.
    - Check that the password field (the second field) for root in `/etc/shadow` is something invalid like "\*" or "!", but not empty and not valid password hash. This prevents password login.
    - Clear `/etc/securetty` to prevent root local/console login.

### Machine-Specific Configuration

#### Physical Host

1. Install extra firmware:
    - Enable the `non-free` repo areas.
    - Install `firmware-linux` (or `firmware-linux-free`) for some common firmware and microcode.
    - APT package examples: `firmware-atheros -bnx2 -bnx2x -ralink -realtek`
    - If it asked to install non-free firmware in the initial installation installation, try to install it now.
    - Install firmware from other sources (e.g. for some Intel NICs).
    - Update microcode: Install `intel-microcode` (for Intel) or `amd64-microcode` (for AMD) and reboot (now or later).
1. Install `smartmontools` and run `smartctl -s on <dev>` for all physical drives to enable SMART monitoring.
1. Install `lm-sensors` and run `sensors-detect` to detect temperatur sensors etc. Add the modules to `/etc/modules` when asked.
1. Mask `ctrl-alt-del.target` to disable CTRL+ALT+DEL reboot at the login screen.

#### QEMU Virtual Host

1. Install QEMU guest agent: `apt install qemu-guest-agent`

### Networking

1. (Recommended alternative) Setup networking using systemd-networkd:
    1. Add a simple network config: Create `/etc/systemd/network/lan.network` based on [main.network](https://github.com/HON95/configs/blob/master/server/linux/networkd/main.network).
    1. Disable/remove the ifupdown config: `mv /etc/network/interfaces /etc/network/interfaces.old`
    1. Enable and (re)start systemd-networkd: `systemctl enable systemd-networkd`
    1. Purge `ifupdown` and `ifupdown2`.
    1. Check status: `networkctl [status [-a]]`
    1. Restart the system and check if still working. This will also kill any dhclient daemons which could trigger a DHCP renew at some point.
1. (Other alternative) Setup networking using ifupdown2:
    1. Install `ifupdown2`. (This may take the network down, so do it locally.)
    1. For VLAN support, install `vlan`.
    1. For bond support, install `ifenslave`.
    1. Restart `networking.service` afterwards.
    1. Configure `/etc/network/interfaces`.
1. (Recommended alternative) Setup DNS with systemd-resolved:
    1. (Optional) In `/etc/systemd/resolved.conf`, set `DNS` to a space separated list of DNS servers.
       If not set, this will just use the DNS servers specified by the network config.
    1. (Optional) If you're hosting a DNS server on this machine, set `DNSStubListener=no` to avoid binding to port 53.
    1. Enable and start `systemd-resolved.service`.
    1. Point `/etc/resolv.conf` to the one generated by systemd: `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
    1. Check status: `resolvectl`
1. (Other alternative) Setup DNS without systemd-resolved:
    1. Manually configure `/etc/resolv.conf`.
1. Setup time and NTP:
    1. Set the timezone: `timedatectl set-timezone Europe/Oslo`
    1. Enable network time: `timedatectl set-ntp true`
    1. (Optional) In `/etc/systemd/timesyncd.conf`, set `NTP` (e.g. to `ntp.justervesenet.no`).
       If not set, this will use the NTP servers specified by the network config.
    1. Restart `systemd-timesyncd`.
    1. Check status works: `timedatectl` and `timedatectl timesync-status`
1. Setup firewall:
    - Install: `apt install iptables iptables-persistent netfilter-persistent`
        - Don't save the current rules when it asks.
    - Add [a simple iptables script](https://github.com/HON95/scripts/blob/master/server/linux/iptables/iptables-simple.sh) or something more complex.
1. Make sure IPv6 and NDP is configured securely:
    - If IPv6 and NDP is enabled and accepting RAs on insecure (i.e. public-facing) interfaces, the server may autoconfigure itself for those interfaces.
    - By configuration: Disable "Accept-RA" on interfaces that should not autoconfigure themselves. It's typically enabled by default.
    - (Not recommended) By firewalling: Block ICMPv6/NDP on untrusted interfaces so that the host can't autoconfigure itself. This prevents all IPv6 configuration for the interface, but may be required in some cases (i.e. Proxmox).
1. Reboot and make sure it still works.

### Extra

Everything here is optional.

1. Extra package security:
    - Install `apt-listbugs` and `apt-listchanges` and run them before upgrading a package.
    - Install `needrestart` and run it after upgrading.
    - Install `debsums` and run it after upgrading to check deb checksums.
    - Install `debsecan` to get automatically alerted when new vulnerabilities are discovered and security updates are available.
1. Google Authenticator 2FA:
    - Recommended for public-facing servers.
    - **TODO**
1. Install and run Lynis security auditor:
    - Install: `apt install lynis`
    - Run: `lynis audit system`
1. MOTD:
    - Clear `/etc/motd` and `/etc/issue`.
    - Download [dmotd.sh](https://github.com/HON95/scripts/blob/master/server/linux/general/dmotd.sh) to `/etc/profile.d/`.
    - Install the dependencies: `neofetch lolcat`
    - Add an ASCII art (or Unicode art) logo to `/etc/logo`, using e.g. [TAAG](http://patorjk.com/software/taag/).
    - (Optional) Add a MOTD to `/etc/motd`.
    - (Optional) Clear or change the pre-login message in `/etc/issue`.
    - Test it: `su - <some-normal-user>`
1. Monitor free disk space:
    - Download [disk-space-checker.sh](https://github.com/HON95/scripts/blob/master/server/linux/general/disk-space-checker.sh) either to `/cron/cron.daily/` or to `/opt/bin` and create a cron job for it.
    - Example cron job (15 minutes past every 4 hours): `15 */4 * * * root /opt/bin/disk-space-checker`
    - Configure which disks/file systems it should exclude and how full they should be before it sends an email alert.

## Troubleshooting

- `network-online.target` is stalling during boot:
    - See all services it depends on: `systemctl show -p WantedBy network-online.target`
    - Disable the unused services which stall.
- Firmware for the network card fails to load:
    - Causes a syslog record like "firmware: failed to load rtl\_nic/rtl8168g-3.fw (-2)" when trying to up the interface.
    - Might happen after installation even if working initially (for some reason).
    - Realtek solution: Enable the "non-free" repo and install "firmware-realtek".
- Perl complains about a locale error:
    - Test with `perl -e exit`. It will complain if there's an error.
    - Check the locale: `locale`
    - Comment `AcceptEnv LANG LC_*` in `/etc/ssh/sshd_config` to prevent clients bringing their own locale.

## Miscellanea

### Cron

- Don't use periods (including file extensions) in the hourly/daily/weekly/monthly scripts.

{% include footer.md %}