---
title: Linux Server Applications
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

**TODO** Migrate the rest of the config notes from the old Google Doc.

### Using
{:.no_toc}

- Debian 10 Buster

## Ceph

See [Storage: Ceph](../storage/#ceph).

## Certbot

### Setup

1. Install: `apt install certbot`
1. (Optional) Add post-update hook: In `/etc/letsencrypt/cli.ini`, add `renew-hook = systemctl reload nginx` or equivalent.

### Usage

- Create using HTTP challenge (auto-renewable): `certbot -d <domain> --preferred-challenges=http --webroot --webroot-path=<webroot> certonly`
- Create using DNS channelge (not auto-renewable): `certbot -d <domain> --preferred-challenges=dns --manual certonly`
- Dry-run renew: `certbot renew --dry-run [--staging]`
- Revoke certificate: `certbot revoke --cert-path <cert>`

## Docker & Docker Compose

**TODO**

### Setup

1. [Install Docker (Debian)](https://docs.docker.com/install/linux/docker-ce/debian/).
1. [Install Docker Compose](https://docs.docker.com/compose/install/).
1. [Install Docker Compose command completion](https://docs.docker.com/compose/completion/).
1. (Optional) Setup swap limit:
    - If `docker info` contains `WARNING: No swap limit support`, it's not working and should maybe be fixed.
    - It incurs a small performance degredation and is optional but recommended.
    - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
    - Run `update-grub` and reboot.

### Docker Compose No-Exec Tmp-Dir Fix

Docker Compose will fail to work if `/tmp` has `noexec`.

1. Move `/usr/local/bin/docker-compose` to `/usr/local/bin/docker-compose-normal`.
1. Create `/usr/local/bin/docker-compose` with the contents below and make it executable.
1. Create the new TMPDIR dir.

```sh
#!/bin/bash
# Some dir without noexec
export TMPDIR=/var/lib/docker-compose-tmp
/usr/local/bin/docker-compose-normal "$@"
```

## Fail2ban

### Setup

1. Install `fail2ban`.
2. Fix the firewall first so it configures itself correctly wrt. firewall blocking.
3. Check the status with `fail2ban-client status [sshd]`.

## Intel SSD Data Center Tool (isdct)

### Setup

1. Download the ZIP for Linux from Intel's site.
1. Install the AMD64 deb package.

### Usage

- Command syntax: `isdct <verb> [options] [targets] [properties]`
    - Target may be either index (as seen in *show*) or serial number.
- Show all SSDs: `isdct show -intelssd`
- Show SSD properties: `isdct show -all -intelssd [target]`
- Show health: `isdct show -sensor`
- Upgrade firmware: `isdct load -intelssd <target>`
- Set physical sector size: `isdct set -intelssd <target> PhysicalSectorSize=<512|4096>`
    - 4k is generally the most optimal choice.
- Prepare a drive for removal by putting it in standby: `isdct start -intelssd <target> -standby`
- Show speed: `isdct show -a -intelssd [target] | grep -i speed`
- Fix SATA 3.0 speed: `isdct set -intelssd <target> PhySpeed=6`
    - Check before and after either with *isdct* or *smartctl*.

#### Change the Capacity

1. Remove all partitions from the drive.
1. Remove all data: `isdct delete -intelssd <target>`
1. (Optional) Set the physical sector size: `isdct set -intelssd <target> PhysicalSectorSize=<512|4096>`
1. Set the new size: `isdct set -intelssd <target> MaximumLBA=<size>`
    - If this fails, run `isdct set -system EnableLSIAdapter=true`.
      It will add another "version" of the SSDs, which you can try again with.
    - The size can be specified either as "native", the LBA count, percent (`x%`) or in gigabytes (`xGB`).
      Use "native" unless you have a reason not to.
1. Prepare it for removal: `isdct start -intelssd <target> -standby`
1. Reconnect the drives or restart the system.

## ISC DHCP Server

### Notes

- DHCPv4 uses raw sockets, so it bypasses the firewall (i.e. no firewall rules are needed).
  DHCPv6, however, does not. This includes the respective clients as well.
- The DHCPv6 server is typically used with [radvd](#Router Advertisement Daemon (radvd)) for router advertisements.

### Setup

1. Install and enable `isc-dhcp-server`.
1. Setup config files:
    - DHCPv4: `/etc/dhcp/dhcpd.conf`
    - DHCPv6 (optional): `/etc/dhcp/dhcpd6.conf`
1. If using systemd-networkd, fix wrong startup order:
    - **TODO**

### Configuration

- Always specify the `authorative` statement in subnet declarations so that the server will reply with DHCPNAK for misconfigured clients.
  This may significantly reduce reconfiguration delay when a client moves between subnets.
- For `range6`, prefer using CIDR notation.
  If using range notation, try to align the start and end on a CIDR block to avoid excessive memory usage.
- DHCPv6 uses lease pools of 9973 entries, so using range sizes below this number may be preferable as a very general reference.
  `/116` gives 8191 addresses.

## NFS

The instructions below use NFSv4 *without* Kerberos.
This is not considered secure at all and should only be used on trusted networks and systems.

### Server

#### Setup

1. (Recommended) Use NTP on both server and clients to make sure the clocks are synchronized.
1. Install: `apt install nfs-kernel-server portmap`
    - "portmap" is only required for NFSv2 and v3, not for NFSv4.
1. See which versions are running: `cat /proc/fs/nfsd/versions`
1. (Recommended) Enable only v4:
    1. In `/etc/default/nfs-common`, set:
      ```
      NEED_STATD="no"
      NEED_IDMAPD="yes"
      ```
    1. In `/etc/default/nfs-kernel-server`, set:
      ```
      RPCNFSDOPTS="-N 2 -N 3"
      RPCMOUNTDOPTS="--manage-gids -N 2 -N 3"
      ```
    1. Mask "rpcbind":
      ```
      systemctl mask rpcbind.service
      systemctl mask rpcbind.socket
      ```

#### Usage

1. Setup a new directory contain all exports in:
    1. Create the container: `mkdir /export`
    1. Create the export mount dirs within the container.
    1. Mount the exports in the container using bind mounts.
        - Example fstab entry using ZFS: `/mnt/zfspool /srv/nfs4/music none bind,defaults,nofail,x-systemd.requires=zfs-mount.service 0 0`
    1. Remember to set appropriate permissions.
1. Add filesystems to export in `/etc/exports`.
    1. (Optional) For NFSv4, the container directory can be set as the root export by specifying option `fsid=root`.
    1. For a list of options, see `exports(5)`.
1. Update the NFS table: `exportfs -ra`
    - Or, restart the service: `systemctl restart nfs-server`
1. (Optional) Show exports: `exportfs -v`
1. (Optional) Update the firewall:
    - NFSv4 uses only TCP port 2049.

### Client

#### Setup

1. Install: `apt install nfs-common`

#### Usage

1. Create a dir to mount the export to.
1. (Optional) Try to mount it: `mount -t nfs4 <server-hostname>:<export> <mountpoint>`
    - Note that for NFSv4 with a root export, the export path is relative to the root export.
1. (Optional) Make it permanent by adding it to fstab.

## ntopng

### Setup

1. Install `ntopng`.
1. Make sure service `ntopng` is enabled and running.
1. Fix log dir owner: `chown nobody:nogroup /var/log/ntopng`
1. Configure:
    1. Open `/etc/ntopng.conf`.
    1. Add `-W=<new_port>` to enable HTTPS.
    1. (Optional) Set `-w=0` to disable HTTP.
1. Restart it (takes a while).

## ntpd

### Setup

1. Disable systemd-timesyncd NTP client by disabling and stopping `systemd-timesyncd`.
1. Install `ntp`.
1. In `/etc/ntp.conf`, replace existing servers/pools with `ntp.justervesenet.no` with the `iburst` option.
1. Test with `ntpq -pn` (it may take a minute to synchronize).

## Postfix

### Satellite system

#### Notes

- When using an SMTP relay, the original IP address will likely be found in the mail headers.
- Make sure DNS is configured correctly (SPF, DKIM, DMARC).

#### Setup

1. Install: `postfix libsasl2-modules mailutils`
    - If asked, choose to configure Postfix as a satellite system.
2. Set the FQDN:
    1. Update it in `/etc/postfix/main.cf`.
    1. Link mailname to hostname (must be FQDN): `ln -sf /etc/hostname /etc/mailname`
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
9. Try sending an email: `echo "Test from $(hostname) at time $(date)." | mail -s "Test" root`

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

## Pterodactyl

### General

- The panel must be able to communicate with all daemons and all vice versa.
  The user must be able to communicate with both the panel and daemons.
- Both the panel and daemons need valid TLS certificates.

### Panel

#### Setup

1. Follow the official guide.

### Daemon

1. Follow the official guide.
1. Install `unzip`.
1. Setup a valid TLS certificate.

### Game Servers

#### General

- You can typically watch the installation progress by watching the docker logs.

#### CSGO

- Use source ID 740 in Pterodactyl (the default) and app ID 730 in Steam Game Server Account Manager, regardless of which app ID the Pterodactyl uses.
- It uses a ton of storage, between 20 and 30 GB last I checked. If you run out of space, the installer will fail with some useless error message.

## Router Advertisement Daemon (radvd)

### Setup

1. Install and enable `radvd`.
1. Setup config file: `/etc/radvd.conf`

## Samba

### Server

#### Setup

1. Install: `apt install samba`

#### Usage

- Making changes:
    - Change the configuration file: `/etc/samba/smb.conf`
    - Test the configuration: `testparm -t`
    - Restart the service: `systemctl restart smbd`
- Manage access to a share:
    - Add a Linux group for the share, like "smb-media", to restrict user access.
    - Fix permissions for only that group on the system.
    - Configure the share to only allow that group.
    - Add Linux users to the group.
- Manage users:
    - Samba users are somewhat using Linux users but with a different password.
    - To separate pure Samba users from *real* users, you can add a "smb-" prefix to its username and make it a system user.
    - Create a new Linux (system) user without shell login: `useradd -r <name>`
        - Or: `useradd `
    - Add a user and set its password: `smbpasswd -a <user>`
    - Show users: `sudo pdbedit -L -v`

### Client

#### Setup

1. Install: `apt install cifs-utils`

#### Usage

- Add permanent share:
    1. Create the mountpoint.
    1. Create a credentials file (`/root/.credentials/smb/<whatever>`):
       ```
       user=<user>
       password=<password>
       ```
    1. In `/etc/fstab`, add: `//<share> <mountpoint> cifs vers=3.1.1,credentials=<file>,iocharset=utf8 0 0`
    1. Test it: `mount -a`

## TFTP-HPA

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

## UniFi

### Setup

**TODO** This is just horrible, just use some unofficial Docker image instead.

1. Install MongoDB:
    - See: [MongoDB: Install MongoDB Community Edition on Debian](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/) or (MongoDB: Install MongoDB on Debian (v3.0))[https://docs.mongodb.com/v3.0/tutorial/install-mongodb-on-debian/]
    - Download and install [libssl1.0.0(Debian Jessie)](https://packages.debian.org/jessie/libssl1.0.0).
    - Install for Debian Jessie and MongoDB version 3.4.
    - Enable and start `mongod`.
1. Install OpenJDK 8.
    - Somehow ...
1. Install UniFi:
    - See: [UniFi: How to Install and Update via APT on Debian or Ubuntu](https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu)
1. Watch logs:
    - UniFi: `/usr/lib/unifi/logs/server.log`
    - MongoDB: `/usr/lib/unifi/logs/mongod.log`
1. Allow the following incoming ports (see [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)):
    - UDP 3478: STUN
    - TCP 8080: Device-controller communication (for devices)
    - TCP 8443: GUI/API (for admins)
    - TCP 8880: HTTP portal (for guests)
    - TCP 8843: HTTPS portal (for guests)
    - TCP 6789: Mobile speedtest (for admins)
    - UDP 10001: Device discovery (for devices)
    - UDP 1900: L2 adoption (optional, for devices)

#### Using jacobalberty's Unofficial Docker Image

1. Add a system user named "unifi": `useradd -r unifi`
1. Allow the ports through the firewall (see above).
1. Add a Docker Compose file. See [docker-compose.yml](https://github.com/HON95/misc-configs/blob/master/linux-server/unifi/docker-compose.yml).
    - Use host networking mode for L2 adoption to work (if you're not using L3 or SSH adoption).
1. Start the container, open the webpage and follow the wizard.

## ZFS

See [Storage: ZFS](../storage/#zfs).

{% include footer.md %}
