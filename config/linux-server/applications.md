---
title: Applications
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Linux Server
---
{% include header.md %}

### Using
Debian 10 Buster

## Docker

**TODO**

### Setup

1. [Official guide for Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
2. (Optional) Setup swap limit:
   - If `docker info` contains `WARNING: No swap limit support`, it's not working and should maybe be fixed.
   - It incurs a small performance degredation and is optional but recommended.
   - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
   - Run `update-grub` and reboot.

## Fail2ban

### Setup

1. Install `fail2ban`.
2. Fix the firewall first so it configures itself correctly wrt. firewall blocking.
3. Check the status with `fail2ban-client status [sshd]`.

## ISC DHCP Server and radvd

### Notes

- DHCPv4 uses raw sockets, so it bypasses the firewall (i.e. no firewall rules are needed). DHCPv6, however, does not. This includes the respective clients as well.

### Setup

1. Install and enable `isc-dhcp-server` and `radvd`.
2. Add config files.
   1. DHCPv4: `/etc/dhcp/dhcpd.conf`
   2. DHCPv6 (optional): `/etc/dhcp/dhcpd6.conf`
   3. radvd: `/etc/radvd.conf`
3. If using systemd-networkd, fix wrong startup order:
   - **TODO**
4. IPv4:
   1. Configure DHCPv4.
5. IPv6:
   1. For SLAAC, configure only radvd.
   2. Dor DHCPv6, configure radvd in stateful mode and DHCPv6.
6. (Optional) Setup interfaces to listen to:
   - This may mute the "No subnet declaration for ..." verbose error on some distros.
   - In `/etc/default/isc-dhcp-server`, add the interfaces (space-separated) to `INTERFACESv4` and `INTERFACESv6`.

## ntpd

### Setup

- Disable systemd-timesyncd NTP client by disabling and stopping `systemd-timesyncd`.
- Install `ntp`.
- In `/etc/ntp.conf`, replace existing servers/pools with `ntp.justervesenet.no` with the `iburst` option.
- Test with `ntpq -pn` (it may take a minute to synchronize).

## Postfix

### Satellite system

#### Notes

- When using an SMTP relay, the original IP address will likely be found in the mail headers.
- Make sure DNS is configured correctly (SPF, DKIM, DMARC).

#### Setup

1. Install: `postfix libsasl2-modules mailutils`
   - If asked, choose to configure Postfix as a satellite system.
2. Make sure the FQDN is correct in `/etc/mailname` and `/etc/postfix/main.cf`.
3. Update the root alias in `/etc/aliases` and run `newaliases`.
4. Update the `main.cf` config (example not provided here).
   1. Only listen to localhost: Set “inet\_interfaces = loopback-only”
   2. Disable relaying: Set “mynetworks = 127.0.0.0/8 \[::ffff:127.0.0.0\]/104 \[::1\]/128”
   3. Anonymize banner: “smtpd\_banner = $myhostname ESMTP”
5. Relay guides:
   1. Mailgun:
      1. [How To Start Sending Email (Mailgun)](https://documentation.mailgun.com/en/latest/quickstart-sending.html)
      2. [How to Set Up a Mail Relay with Postfix and Mailgun on Ubuntu 16.04 (](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-mail-relay-with-postfix-and-mailgun-on-ubuntu-16-04)[DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-mail-relay-with-postfix-and-mailgun-on-ubuntu-16-04)
   2. SendGrid:
      1. [Postfix (SendGrid)](https://sendgrid.com/docs/for-developers/sending-email/postfix/)
      2. Use API-key with permission to send mail only.
      3. The API-key username is `apikey`.
6. Setup address rewrite rules:
   - For fixing the `To` and `From` fields, which is typically from root to root.
   - Add the rewrite config (see example below).
   - Reference the config using `smtp_header_checks` in the main config.
   - Test: `postmap -fq "From: root@<FQDN>" regexp:smtp_header_checks`
7. Setup relay credentials (SASL):
   1. Credentials file: `/etc/postfix/sasl_passwd`
   2. Add your credentials using format: `[relay_domain]:port user@domain:password`
   3. Run: `postmap sasl_passwd`
   4. Fix permissions: `chmod 600 sasl_passwd*`
8. Restart `postfix`.
9. Try sending an email: `echo "Test from $HOSTNAME at time $(date)." | mail -s "Test" root`

#### Examples

```text
# File: smtp_header_checks

/^From:\s*.*\S+@node\.example\.bet.*.*$/ REPLACE From: "Node" <node@example.net>
/^To:\s*.*\S+@node\.example\.net.*$/ REPLACE To: "Someone" <someone@example.net>
```

### Usage

- Send a test mail: `echo "Test from $HOSTNAME at time $(date)." | mail -s "Test" root`
- Test the config: `postconf > /dev/null`
- Print the config: `postconf -n`
- If mails are stuck in the mail queue (`mailq`) because of previous errors, run `postqueue -f` to flush them.

## radvd

### Setup

1. Install `radvd`.
2. Setup the config: `/etc/radvd.conf`

## TFTP Server

Using H. Peter Anvin's TFTP server (tftpd-hpa).

### Setup

1. Install `tftpd-hpa`.
2. Update `/etc/default/tftpd-hpa` based on the config below.
3. Create the folder `/var/tftp` with permissions `777` and user-group pair `tftp:tftp`.
4. Restart it.
5. If it shouldn't automatically start, disble it.

### Files

```text
# File: /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--create --secure"
```

## Pterodactyl

### Setup

- Note: The node must be publicly accessable.
- Follow the official guide.

### Game Servers

#### CSGO

- It uses a ton of storage, between 20 and 30 GB last I checked. If you useless, the installer will fail with some useless error message.
- Use app ID 730 in Steam Game Server Account Manager, regardless of which app ID the server was created with. If you use e.g. 740, the server will not be able to log into Steam.

## Unbound

### Setup

1. Install: `unbound dns-root-data`
2. Setup the config: `/etc/unbound/unbound.conf`
3. Add hostname variants to `/etc/hosts`.
4. Configure it in `/etc/resolv.conf`:
   1. `nameserver 127.0.0.1`
   2. `search <domain>`
   3. `domain <domain>`
5. Configure it in `/etc/systemd/resolved.conf`:
   1. `DNSStubListener=no`
   2. `DNS=127.0.0.1`
   3. Restart `systemd-resolved`.
6. Test DNSSEC:
   1. `drill sigfail.verteiltesysteme.net` should give an rcode of `SERVFAIL`.
   2. `drill sigok.verteiltesysteme.net` should give an rcode of `NOERROR`.
7. Make sure dns-root-data is updating root hints in file `/usr/share/dns/root.hints`.

### Troubleshooting

- It sometimes stops resolving names and responds with "servfail".
  - I don't know why. Restarting it works.

### Notes

- Use DNS over HTTPS/TLS.
- Setup private addresses for DNS rebinding prevention.

## ZFS

### Features

- Filesystem and physical storage decoupled
- Always consistent
- Intent log
- Synchronous or asynchronous
- Everything checksummed
- Compression
- Deduplication
- Encryption
- Snapshots
- Copy-on-write (CoW)
- Clones
- Caching
- Log-strucrured filesystem
- Tunable

### Setup
**TODO**: Check if this is still annoying.

1. Enable the `contrib` and `non-free` repo areas. (Don't use any backports repo.)
1. Install (it might give errors): `zfs-dkms zfsutils-linux zfs-zed`
1. Load the ZFS module: `modprobe zfs`
1. Fix the ZFS install: `apt install`
1. Check that the cron scrub script exists.
  - If not, add one which runs `/usr/lib/zfs-linux/scrub`. It'll scrub all disks. Run it e.g. monthly or every 2 weeks.

### Usage

- View activity: `zpool iostat [-v]`
- Clear transient device errors: `zpool clear <pool> [device]`
- If a pool is "UNAVAIL", it means it can't be recovered without corrupted data.
- Replace a device and automatically copy data from the old device or from redundant devices: `zpool replace <pool> <device> [new-device]`
- Bring a device online or offline: `zpool (online|offline) <pool> <device>`
- Re-add device that got wiped: Take it offline and then online again.

### Best Practices and Suggestions

- As far as possible, use raw disks and HBA disk controllers (or RAID controllers in IT mode).
- Always use `/etc/disk/by-id/X`, not `/dev/sdX`.
- Always manually set the correct ashift for pools.
  - Should be the log-2 of the physical block/sector size of the device.
  - E.g. 12 for 4kB (Advanced Format (AF), common on HDDs) and 9 for 512B (common on SSDs).
  - Check the physical block size with `smartctl -i <dev>`.
- Always enable compression. Worst case it does nothing.
- Consider using quotas and reservations.
- Make sure regular automatic scrubs are enabled. There should be a cron job/script or something. Run it e.g. every 2 weeks or monthly.
- Snapshots are great for increments backups. They're easy to send places too. If the dataset is encrypted then so is the snapshot.

### Tuning

- Very frequent reads:
  - E.g. for a static web root.
  - Set `atime=off` to disable updating the access time for files.
- Database:
  - Use different datasets for the DB data and DB WAL if possible.
  - Use an appropriate recordsize with `recordsize=<size>`.
    - InnoDB should use 16k for data files and 128k on log files.
    - PostgreSQL should use 8k for both data and WAL.
  - Disable caching with `primarycache=metadata`. DMBSes handle caching themselves.
    - For InnoDB.
  - Disable the ZIL with `logbias=throughput` to prevent writing twice.
    - For both InnoDB and PostgreSQL.

### Extra Notes

- ECC memory is recommended but not required. It helps prevent data corruption in memory, where ZFS provides no redundancy. It does not affect data corruption on disk, however.
- It does not require large amounts of memory, but more memory allows it to cache more data. A minimum of around 1GB is suggested. Memory caching is termed ARC.
- A dedicated disk (e.g. an NVMe SSD) can be used as a secondary read cache. This is termed L2ARC (level 2 ARC). Only frequently accessed blocks are cached. The memory requirement will increase based on the size of the L2ARC. It should only be considered for pools with high read traffic, slow disks and lots of memory available.
- A dedicated disk (e.g. an NVMe SSD) can be used for the ZFS intent log (ZIL), which is used for synchronized writes. This is termed SLOG (separate intent log). The disk must be able to handle lots of writes. It should only be considered for pools with high synchronous write traffic on relatively slow disks.
- Intel Optane is a perfect choice as both L2ARCs and SLOGs due to its high throughput, low latency and high durability.
- Some SSD models come with a build-in cache. Make sure it actually flushes it on power loss.

{% include footer.md %}