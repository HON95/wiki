---
title: Debian Server
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

### Using
{:.no_toc}
Debian 10 Buster

## Basic Setup

### Installation

- Always verify the downloaded installation image after downloading it.
- Use UEFI if possible.
- Use the non-graphical installer. It's basically the same as the graphical one.
- Localization:
  - Language: United States English
  - Location: Your location.
  - Locale: United States UTF-8 (`en_US.UTF-8`)
  - Keymap: Your keyboard's keymap.
- Use an FQDN as the hostname. It'll set both the shortname and the FQDN.
- Use separate password for root and your personal admin user.
- Disk partitioning:
  - (Recommended) Manually partition the system drive(s). See [system storage](#system-storage) for a suggestion.
  - Guided partitioning makes weird partition/volume sizes, try to avoid it.
  - For simple or temporary systems, just use "guided - use entire disk" with all files in one partition.
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
1. Localization:
    - Check current locale:
      - `locale` should return `en_US.UTF-8`.
      - Update if wrong: `update-locale LANG=en_US.UTF-8`
    - Check the keymap:
      - Try typing characters specific to your keyboard.
      - Update if wrong: `dpkg-reconfigure keyboard-configuration`
    - Comment `AcceptEnv LANG LC_*` in `/etc/ssh/sshd_config` to prevent clients bringing their own locale. Restart `sshd`.
1. Set the hostname:
    - Set the shortname: `hostnamectl set-hostname <shortname>`
    - Set both the shortname and FQDN in `/etc/hosts`.
    - Check the hostnames with `hostname` (shortname) and `hostname --fqdn` (FQDN).
1. Packages:
    - (Optional) Enable the `contrib` and `non-free` repo areas:
      - Add `contrib non-free` to every line in `/etc/apt/sources.list`.
    - Update, upgrade and auto-remove.
    - Install basics: `sudo ca-certificates`
    - Install extra tools: `tree vim screen curl net-tools htop iotop irqtop nmap`
    - Install per-user tmpdirs: `libpam-tmpdir`
    - Install Postfix: Install `postfix` and select "satellite system" if the system will only send email.
    - Install extra firmware:
      - Install `firmware-linux` or `firmware-linux-free` for some common firmware and microcode.
      - APT package examples: `firmware-atheros -bnx2 -bnx2x -ralink -realtek`
      - If it asked to install non-free firmware in the initial installation installation, try to install it now.
      - Install firmware from other sources (e.g. for some Intel NICs).
1. Add mount options:
    - Add PID monitor group: `groupadd -g 1500 pidmonitor`
    - Add your personal user to the PID monitor group: `usermod -aG pidmonitor <user>`
    - Set mount options in `/etc/fstab`:
      - See [Storage](system.md).
      - Enable hidepid: `proc /proc proc defaults,hidepid=2,gid=1500 0 0`
    - Run `mount -a` to validate fstab.
    - Restart the system for it to take effect.
1. Setup SSHd:
    - File: `/etc/ssh/sshd_config`
    - `PermitRootLogin no`
    - `PasswordAuthentication no`
    - `AllowTcpForwarding no`
    - `GatewayPorts no`
    - Restart `sshd`.
1. Update MOTD:
    - Clear `/etc/motd`.
1. Configure your personal user:
    - Add it to the sudo group (`usermod -aG sudo <user>`).
    - Add your personal SSH pubkey to `~/.ssh/authorized_keys` and fix the owner and permissions (700 for dir, 600 for file). (Hint: Get `https://github.com/<user>.keys` and filter the results.)
    - Try logging in remotely and gain root access through sudo.
1. (Optional) Prevent root login:
    - Alternatively, keep it enabled with a strong password as a local backdoor for recovery or similar.
    - Add a personal user first.
    - Check that the password field (the second field) for root in `/etc/shadow` is something invalid like "\*" or "!", but not empty and not valid password hash. This prevents password login.
    - Clear `/etc/securetty` to prevent root local/console login.

### Machine-Specic Configuration

#### Physical Host

1. **TODO** SSD optimizations.
1. (Optional) If using SSD, add `vm.swappiness=1` to `/etc/sysctl.conf` to minimize swapping.
1. Install `smartmontools` and run `smartctl -s on <dev>` for all physical drives to enable SMART monitoring.
1. Install `lm-sensors` and run `sensors-detect` to detect temperatur sensors etc. Add the modules to `/etc/modules` when asked.
1. Mask `ctrl-alt-del.target` to disable CTRL+ALT+DEL reboot at the login screen.

#### QEMU Virtual Host

1. Install `qemu-guest-agent`.

### Networking

1. **TODO** Security stuff.
1. (Alternative 1) (Recommended) Setup networkd network manager:
    - Add a simple network config:
      - Alternatively, add a complicated set of configs.
      - Create `/etc/systemd/network/lan.network` based on [lan.network]({{ site.github.repository_url }}/blob/master/config/linux-server/files/networkd/lan.network).
    - Disable/remove the ifupdown config: `mv /etc/network/interfaces /etc/network/interfaces.old`
    - Enable and start systemd-networkd: `systemctl enable systemd-networkd`
      - Restart it if already running.
    - Purge `ifupdown` and `ifupdown2`.
    - Check the status: `networkctl [status [-a]]`
    - Restart the system (now or later) and check if still working.
1. (Alternative 2) (Default) Setup ifupdown network manager:
    - Install `ifupdown2`.
      - This may take the network down, so do it locally.
      - Restart `networking.service` afterward.
    - For VLAN support, install `vlan`.
    - For bond support, install `ifenslave`.
    - **TODO**: DHCPv4, IPv6 (static, SLAAC, DHCPv6).
1. Setup DNS:
    - Enable and start `systemd-resolved.service`, the systemd resolver.
    - Point `/etc/resolv.conf` to the one generated by systemd: `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
1. Setup NTP:
    - Set the timezone: `timedatectl set-timezone Europe/Oslo`
    - Enable network time: `timedatectl set-ntp true`
    - In `/etc/systemd/timesyncd.conf`, set `NTP=ntp.justervesenet.no`.
    - Restart `systemd-timesyncd`.
    - Check that NTP works: `timedatectl timesync-status`
1. Setup firewall:
    - Install: `iptables iptables-persistent netfilter-persistent`
      - Don't save the current rules.
    - Add som [simple]({{ site.github.repository_url }}/blob/master/config/linux-server/files/iptables/iptables-simple.sh) or [complex]({{ site.github.repository_url }}/blob/master/config/linux-server/files/iptables/iptables-complex.sh) rules.
1. Reboot and make sure it still works.

### Extra
Optional stuff.

1. Extra package security:
    - Install `apt-listbugs` and `apt-listchanges` and run them before upgrading a package.
    - Install `needrestart` and run it after upgrading.
    - Install `debsums` and run it after upgrading to check deb checksums.
    - Install `debsecan` to get automatically alerted when new vulnerabilities are discovered and security updates are available.
1. Postfix mail relay: **TODO**
1. Install `fail2ban`.
    - Fix the firewall first so it configures itself correctly wrt. which firewall is used.
    - Check the status with `fail2ban-client status [sshd]`.
    - See [Applications](applications.md#fail-2-ban) for more info.
1. Google Authenticator 2FA: **TODO**
1. Install and run Lynis:
    - Install `lynis`.
    - Run `lynis audit system`.
1. MOTD:
    - Clear `/etc/motd`.
    - Download [dmotd.sh](https://github.com/HON95/misc-configs/blob/master/linux-server/profile/dmotd.sh) to `/etc/profile.d/`.
    - Install the dependencies: `neofetch lolcat`
    - Add an ASCII art (or Unicode art) logo to `/etc/logo`, using e.g. [TAAG](http://patorjk.com/software/taag/).
    - (Optional) Add a MOTD to `/etc/motd`.
    - (Optional) Clear or change the pre-login message in `/etc/issue`.
    - Test it (as a normal user): `bash /etc/profile.d/dmotd.sh`
1. Monitor free disk space:
    - Download [disk-space-checker.sh](https://github.com/HON95/misc-configs/blob/master/linux-server/cron/disk-space-checker.sh) either to `/cron/cron.daily/` or to `/opt/bin` and create a cron job for it.
    - Example cron job (15 minutes past every 4 hours): `15 */4 * * * root /opt/bin/disk-space-checker`
    - Configure which disks/file systems it should exclude and how full they should be before it sends an email alert.

## System Storage

- The system drive doesn’t need to be super fast if not used a lot for service stuff. It's typically built from one SSD (optionally overprovisioned) or 2 mirrored HDDs (as they're less reliable).
- Set the boot flag on `/boot/efi` (UEFI) or `/boot` (BIOS). It's not used, but some hardware may require it to try booting the drive.
- Swap can be added either as a partition, as an LVM volume or not added at all.
- Use LVM or ZFS (if supported/stable) for the whole main disk, except the boot and EFI partitions.
- Generally use EXT4, but try to use ZFS if appropriate.
- Optionally use only the first half of the disk for LVM/system stuff and the other half as for ZFS.
- Storage typically uses base-10 prefixes, not base-2, like speed and unlike memory.
- SSDs can be overprovisioned in order to improve performance by leaving unused space the SSD can use internally. Factories typically reserve some minimum size appropriate to the drive, but users can overprovision further by leaving space unallocated/unpartitioned at the end of the drive. It's typically not needed to overprovision newer SSDs.

### System Volumes Suggestion

This is just a suggestion for how to partition your main system drive. Since LVM volumes can be expanded later, it's fine to make them initially small. Create the volumes during system installation and set the mount options later in `/etc/fstab`.

| Volume/Mount | Type | Minimal Size (GB) | Mount Options |
| :--- | :--- | :--- | :--- |
| `/proc` | Runtime | N/A | hidepid=2,gid=1500 |
| `/boot/efi` | FAT32 w/ boot flag (UEFI), none (BIOS) | 0.5 | nodev,nosuid,noexec |
| `/boot` | EXT4 (UEFI), FAT32 w/ boot flag (BIOS) | 0.5 | nodev,nosuid,noexec |
| Swap | Swap (optional) | 4, 8, 16 | N/A |
| `vg0` | LVM | 50% or 100% | N/A |
| Swap | Swap (LVM) (optional) | 4, 8, 16 | N/A |
| `/` | EXT4 (LVM) | 10 | nodev |
| `/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/lib` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/log` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var/log/audit` | EXT4 (LVM) | 1 | nodev,nosuid,noexec |
| `/var/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/home` | EXT4 (LVM) | 10 | nodev,nosuid |
| `/srv` | EXT4 (LVM) or none if external | 10 | nodev,nosuid |

## Miscellaneous

### Cron

- Don't use periods (including file extensions) in the hourly/daily/weekly/monthly scripts.

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

{% include footer.md %}