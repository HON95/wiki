---
title: Linux Server Applications
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

### Using
{:.no_toc}

- Debian 10 Buster

## Apache

**Outdated and missing information**

## Setup

1. Install: `apt install apache2`
1. Update `security.conf`:
    ```
    ServerTokens Prod
    ServerSignature Off
    ```

## Usage

- Enable/disable stuff: `a2<en|dis><conf|mod|site> <...>`
- Test configuration: `apache2ctl`

## AWS CLI

**Possibly outdated**

### Setup

- Guide: [AWS: Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- Install `awscli` through pip3
- Fix permissions: `chmod +x /usr/local/bin/aws`

### Usage

- Login: `aws configure [--profile <profile>]`
    - This will store the credentials for the current Linux user.
    - London region: `eu-west-2`
    - Output format: `json`
- Examples:
    - Upload file: `aws s3 cp <local_file> s3://<bucket>/`

## bitwarden_rs

A free community backend for Bitwarden.

**TODO**

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

## DDNS

### Cloudflare

Use [cloudflare-ddns-updater.sh](https://github.com/HON95/scripts/tree/master/server/linux/cloudflare).

## Docker

### Setup

1. Install: [Docker Documentation: Get Docker Engine - Community for Debian](https://docs.docker.com/install/linux/docker-ce/debian/).
1. (Optional) Setup swap limit:
    - If `docker info` contains `WARNING: No swap limit support`, it's not working and should maybe be fixed.
    - It incurs a small performance degredation and is optional but recommended.
    - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
    - Run `update-grub` and reboot.
1. Configure `/etc/docker/daemon.json`:
    - Set DNS servers: `"dns": ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"]`
    - (Optional) Disable automatic IPTables rules: `"iptables": false`
    - Enable IPv6: `"ipv6": true`
    - Set IPv6 default subnet: `"fixed-cidr-v6": <64-prefix>`
1. (Optional, not recommended on servers) Allow certain users to use Docker: Add them to the `docker` group.

### Usage

- Docker run options:
    - Set name: `--name=<name>`
    - Run in detatched mode: `-d`
    - Run using interactive terminal: `-it`
    - Automatically remove when stopped: `--rm`
    - Automatically restart: `--restart=unless-stopped`
    - Use "tini" as entrypoint and use PID 1: `--init`
    - Set env var: `-e <var>=<val>`
    - Publish network port: `-p <host-port>:<cont-port>[/udp]`
    - Mount volume: `-v <vol>:<cont-path>` (`<vol>` must have a path prefix like `./` or `/` if it is a directory and not a named volume)
- Networks:
    - Create bridged network: `docker network create --driver=bridge --ipv6 --subnet=<ipv4-net> --subnet=<ipv6-net> <name>`
    - Create bridged network connected to host interface: `docker network create --driver=bridge --ipv6 --subnet=<ipv4-net> --gateway=<ipv4-gateway> --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o "com.docker.network.bridge.name=<host-if> <name>`
    - Run container with network: `docker run --network=<net-name> --ip=<ipv4-addr> --ip6=<ipv6-addr> --dns=<dns-server> <image>`

## Docker Compose

### Setup

1. Install Docker: See above.
1. Install: [Docker Documentation: Install Docker Compose](https://docs.docker.com/compose/install/).
1. Install command completion: [Docker Documentation: Command-line completion](https://docs.docker.com/compose/completion/).

### Troubleshooting

#### Fix Docker Compose No-Exec Tmp-Dir

Docker Compose will fail to work if `/tmp` has `noexec`.

1. Move `/usr/local/bin/docker-compose` to `/usr/local/bin/docker-compose-normal`.
1. Create `/usr/local/bin/docker-compose` with the contents below and make it executable.
1. Create the new TMPDIR dir.

New `docker-compose`:

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

## Google Authenticator

**Possibly outdated**

This setup requires pubkey plus MFA (if configured) plus password.

### Setup

- Warning: Keep a shell open and test with a new shell during the process to make sure you don’t lock yourself out.
- Install: `apt install libpam-google-authenticator`
- In `/etc/pam.d/sshd`, add `auth required pam_google_authenticator.so nullok` after `@include common-auth`.
- In `/etc/ssh/sshd_config`, set:
    ```
    ChallengeResponseAuthentication yes
    UsePAM yes
    AuthenticationMethods publickey,keyboard-interactive
    ```
- Restart `sshd` and check that you can login with pubkey and MFA now.
- (Optional) Add my [google-auth-config-prompter.sh](https://github.com/HON95/scripts/blob/master/server/linux/general/google-auth-config-prompter.sh) profile script to `/etc/profile.d/` to ask user to configure Google Auth on login.
- To allow a group to use only pubkey (no password or OTP):
    - In `/etc/ssh/sshd_config`, add `Match Group no-mfa` containing `AuthenticationMethods publickey` (indented) at the bottom.
    - Add the system group `no-mfa` and add special users to it.
- To manually configure MFA for a user:
    - Example: `google-authenticator -tduW`
    - Use time-based tokens.
    - Restrict usage of the same token multiple times.
    - Don’t rate limit.
    - Allow 3 concurrent codes (1 before, 1 after).

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

## OpenSSL

### Usage

- Many OpenSSL default options are insecure and must be specified.
- Specifying `-noout -text` prints the data as formatted text instead of raw Base64.

## Pi-hole (Docker)
 
- (Optional) Set up an upstream DNS server.
- Image: pihole/pihole
- Run on LAN-accessible bridge.
- Don’t give capability NET_ADMIN.
- Add a reject rule in the firewall to more easily block HTTPS ads.
- Find the admin password with `docker logs pihole 2>&1 | grep "random password"`
- Specify the upstream DNS server twice so that it doesn’t choose the second itself.
- Whitelists and blacklists:
    - Blacklist (example): https://v.firebog.net/hosts/lists.php
    - Whitelist (example): https://github.com/anudeepND/whitelist
    - Add blocklists to `/etc/pihole/adlists.list`.
    - Add whitelist domains to `/etc/pihole/whitelist.txt`.
    - Run `pihole -g` to update lists.

## Postfix

### Satellite system

#### Notes

- When using an SMTP relay, the original IP address will likely be found in the mail headers.
- Make sure DNS is configured correctly (SPF, DKIM, DMARC).

#### Setup

1. Install: `postfix libsasl2-modules mailutils`
    - If asked, choose to configure Postfix as a satellite system.
1. Set the FQDN in `/etc/postfix/main.cf`.
1. Update the root alias to point your real email address in `/etc/aliases`, then run `newaliases`.
1. Update the `main.cf` config (example not provided here).
    1. Only listen to localhost: Set `inet_interfaces = loopback-only`
    1. Disable relaying: Set `mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128`
    1. Anonymize banner: `smtpd_banner = $myhostname ESMTP`
1. See the specific relay guides:
    - Mailgun:
        - [How To Start Sending Email (Mailgun)](https://documentation.mailgun.com/en/latest/quickstart-sending.html)
        - [How to Set Up a Mail Relay with Postfix and Mailgun on Ubuntu 16.04 (](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-mail-relay-with-postfix-and-mailgun-on-ubuntu-16-04)[DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-mail-relay-with-postfix-and-mailgun-on-ubuntu-16-04)
    - SendGrid:
        - [Postfix (SendGrid)](https://sendgrid.com/docs/for-developers/sending-email/postfix/)
        - Use API-key with permission to send mail only.
        - The API-key username is `apikey`.
1. Setup address rewrite rules:
    - For fixing the `To` and `From` fields, which is typically from root to root.
    - Add the rewrite config (see example below).
    - Reference the config using `smtp_header_checks` in the main config.
    - Test: `postmap -fq "From: root@$(hostname --fqdn)" regexp:smtp_header_checks`
1. Setup relay credentials (SASL):
    1. Credentials file: `/etc/postfix/sasl_passwd`
    2. Add your credentials using format: `[relay_domain]:port user@domain:password`
    3. Run: `postmap sasl_passwd`
    4. Fix permissions: `chmod 600 sasl_passwd*`
1. Restart `postfix`.
1. Try sending an email: `echo "Test from $(hostname) at time $(date)." | mail -s "Test" root`

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
- If `mailq` tells you mails are stuck in the mail queue because of previous errors, run `postqueue -f` to flush them.

## Pterodactyl

### General

- The panel must be able to communicate with all daemons and all vice versa.
  The user must be able to communicate with both the panel and daemons.
- Both the panel and daemons need valid TLS certificates.

### Panel (Docker)

#### Setup

**TODO**

Logs are located in `/app/storage/logs/laravel/`.

### Daemon

1. Follow the official guide.
1. Install `unzip`.
1. Setup a valid TLS certificate.
1. Setup Docker DNS servers: Add `{ "dns": ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"] }` to `/etc/docker/daemon.json`.

### Game Servers

#### General

- You can typically watch the installation progress by watching the docker logs.

#### Counter-Strike: Global Offensive

See [Counter-Strike: Global Offensive (CS:GO)](/config/game-servers/csgo/).

#### Team Fortress 2

See [Team Fortress 2 (TF2)](/config/game-servers/tf2/).

## Router Advertisement Daemon (radvd)

### Setup

1. Install and enable `radvd`.
1. Setup config file: `/etc/radvd.conf`

## Samba

### Server

#### Setup

1. Install: `apt install samba`
1. Open TCP port 445 (and 139 if using NetBIOS).
1. (Optional) Disable NetBIOS: `systemctl disable --now nmbd` and `systemctl mask nmbd`
1. Configure it (see usage).

#### Usage

- Enforce encryption and signing (`server signing` and `smb encrypt`) on important volumes.
- Performance tuning:
    - Socket options: `socket options = TCP_NODELAY SO_KEEPALIVE IPTOS_LOWDELAY`
    - If the stuff is not important and the network is secure and high throughput is desired: `smb encrypt = disabled`
    - Raw IO: `read raw = yes` and `read raw = yes`
    - Sendfile: `use sendfile = yes`
    - Zero-copy from net to FS (doesn't work for signed connections): `min receivefile size = 16384`
    - Async RW for large files: `aio read size = 16384` and `aio write size = 16384`
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
1. Add permanent shares (see usage).

#### Usage

- Add permanent share:
    1. Create the mountpoint.
    1. Create a credentials file (`/root/.credentials/smb/<whatever>`):
       ```
       user=<user>
       password=<password>
       ```
    1. In `/etc/fstab`, add: `//<share> <mountpoint> cifs vers=3.1.1,uid=<uid>,gid=<gid>,credentials=<file>,iocharset=utf8 0 0`
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
1. Setup the config: `/etc/unbound/unbound.conf`
1. Test DNSSEC:
    1. `drill sigfail.verteiltesysteme.net` should give an rcode of `SERVFAIL`.
    2. `drill sigok.verteiltesysteme.net` should give an rcode of `NOERROR`.
1. Make sure dns-root-data is updating root hints in file `/usr/share/dns/root.hints`.

#### Setup the Local Host to Use It

1. Add hostname variants to `/etc/hosts`.
1. Configure the local host to use it in `/etc/resolv.conf`:
    - `nameserver 127.0.0.1`
    - `search <domain>`
    - `domain <domain>`
1. Configure the local host to use it in `/etc/systemd/resolved.conf`:
    - `DNSStubListener=no`
    - `DNS=::1`
    - Restart `systemd-resolved`.

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
