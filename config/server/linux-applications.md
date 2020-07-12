---
title: Linux Server Applications
breadcrumbs:
- title: Configuration
- title: Server
---
{% include header.md %}

### Using
{:.no_toc}

- Debian 10 Buster

## Apache

**Outdated and missing information**

### Setup

1. Install: `apt install apache2`
1. Update `security.conf`:
    ```
    ServerTokens Prod
    ServerSignature Off
    ```

### Usage

- Enable/disable stuff: `a2<en|dis><conf|mod|site> <...>`
- Test configuration: `apache2ctl`

## Apticron

Sends an emails when APT updates are available.

### Setup

1. Prerequesites:
    - Setup Postfix or similar so the system can actually send mail.
    - Make sure the root email alias is set appropriately.
1. Install: `apt install apticron`
1. Setup the config: `/etc/apticron/apticron.conf`
    - Create it: `cp /usr/lib/apticron/apticron.conf /etc/apticron/apticron.conf`
    - The defaults are typically fine.
1. Modify the check interval in `/etc/cron.d/apticron` (e.g. `30 23 * * *`).
1. Fix a bug causing it to ignore `IPADDRESSNUM` and always print all IP adresses:
    1. Open `/usr/sbin/apticron`.
    1. Find this line: ```IPADDRESSES=`(echo $( /bin/hostname --all-ip-addresses ) ;```
    1. Change it to: ```IPADDRESSES=`(```
1. Test it: `apticron`

## Avahi Daemon

**TODO**

### Setup

1. Install: `apt install avahi-daemon`

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

- Cloudflare does not allow limiting the scope for API keys to specific subdomains, so the key will have access to the whole domain (based on how it's registered).
- Use e.g. [cloudflare-ddns-updater.sh](https://github.com/HON95/scripts/tree/master/server/linux/cloudflare).

## Docker

### Setup

1. Install: [Docker Documentation: Get Docker Engine - Community for Debian](https://docs.docker.com/install/linux/docker-ce/debian/).
1. (Optional) Setup swap limit:
    - If `docker info` contains `WARNING: No swap limit support`, it's not working and should maybe be fixed.
    - It incurs a small performance degredation and is optional but recommended.
    - In `/etc/default/grub`, add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX`.
    - Run `update-grub` and reboot.
1. Configure `/etc/docker/daemon.json`:
    - Enable IPv6: `"ipv6": true` and `"fixed-cidr-v6": "<ipv6-subnet>/64"`
        - Note that IPv6 it not NATed like IPv4 is in Docker.
    - Set DNS servers: `"dns": ["1.1.1.1", "2606:4700:4700::1111"]`
        - If not set, containers will use `8.8.8.8` and `8.8.4.4` by default.
        - `/etc/resolv.conf` is limited to only three name servers, so don't provide too many. One may be set by the container itself.
    - (Optional) Disable automatic IPTables rules: `"iptables": false`
1. (Optional, not recommended on servers) Allow certain users to use Docker: Add them to the `docker` group.

### Usage

- Miscellanea:
    - Show disk usage: `docker system df -v`
- Cleanup:
    - Prune unused images: `docker image prune -a`
    - Prune unused volumes: `docker volume prune`
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

### Miscellanea

- For automatically updating containers, use e.g. [watchtower](https://github.com/containrrr/watchtower).
- For managing containers in a pretty web UI, use e.g. [Portainer](https://www.portainer.io/).

#### Networking

- Containers in production should not use the default Docker networks.
- Try to isolate container communication into as small networks as possible (e.g. one network per group of containers for an application).
- Docker doesn't integrate with ip6tables at all, meaning certain IPv6 features are lacking. For instance, IPv6 is not NATed like IPv4 and ICC can't be disabled. NAT66 shouldn't generally be used in the first place, but the lack of it means IPv6 requires a bit of extra configuration to get it working with containers. IPv6 routing and port publishing work as they should, though, as they don't use ip6tables.
- Network types:
    - Bridge: A plain bridge where all containers and the host can communicate. Can optionally be directly connected to a host bridge, but that doesn't always work as expected. Vulnerable to ARP/NDP spoofing.
    - Overlay: Overlay network for swarm stuff.
    - Host: The container use the network stack of the host. Ports are published directly to the host.
    - MACVLAN: Bridges connected to a host (parent) interface, allowing containers to be connected to a network the host is part of. Can optionally use trunking on the host interface. All communication between containers and the host is dropped (consider using a host-connected bridge if you need this).
    - L2 IPVLAN: Similar to MACVLAN, but all containers use the host's MAC address. Containers can communicate, but the host can't communicate with any containers.
    - L3 IPVLAN: Every VM uses a separate subnet and all communication, internally and externally, is routed. Should avoid ARP/NDP spoofing. (**TODO:** Containers and the host can communicate?)
- Create:
    - Create bridged network: `docker network create --driver=bridge --subnet=<ipv4-net> --ipv6 --subnet=<ipv6-net> <name>`
    - Create external bridged network (experimental, doesn't work as intented in some scenarios): `docker network create --driver=bridge --subnet=<ipv4-net> --gateway=<ipv4-gateway> --ipv6 --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o "com.docker.network.bridge.name=<host-if> <name>`
    - Create MACVLAN: `docker network create --driver=macvlan --subnet=<ipv4-net> --gateway=<ipv4-gateway> --ipv6 --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o parent=<netif>[.<vid>] <name>`
    - Create L2 IPVLAN with parent interface: `docker network create --driver=ipvlan --subnet=<ipv4-net> --gateway=<ipv4-gateway> --ipv6 --subnet=<ipv6-net> --gateway=<ipv6-gateway> -o parent=<netif> <name>`
- Use:
    - Run container with network: `docker run --network=<net-name> --ip=<ipv4-addr> --ip6=<ipv6-addr> --dns=<dns-server> [...] <image>`

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

## Intel SSD Data Center Tool (isdct)

See [Storage: isdct](../linux-storage/#intel-ssd-data-center-tool-isdct).

## Grafana

Typically used with a data source like [Prometheus](#prometheus).

### Setup (Docker)

1. See [(Grafana) Run Grafana Docker image](https://grafana.com/docs/grafana/latest/installation/docker/).
1. Mount:
    - Config: `./grafana.ini:/etc/grafana/grafana.ini:ro`
    - Data: `./data:/var/lib/grafana/:rw` (requires UID 472)
    - Logs: `./logs:/var/log/grafana/:rw` (requires UID 472)
1. Configure `grafana.ini`.
1. Open the webpage to configure it.

### Notes

- Be careful with public dashboards. "Viewers" can modify any query and thus query the entire data source for the dashboard, unless you have configured some type of access control for the data source (which you probably haven't).

## Home Assistant

See [Home Assistant](../home-assistant/).

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

## MariaDB

A MySQL fork that is generally MySQL compatible.

### Setup

1. Install: `apt install mariadb-server`
1. Run the initial configuration: `mysql_secure_installation`
    - Set a new MyriaDB root password.
    - Remove all anmonymous/test stuff.
    - Disallow remote root login.

### Usage

- Open prompt: `mariadb [-u <user> [-p]]`
    - The default user is `root`.
    - The password can be entered interactively by specifying `-p`.
    - A password is typically not needed.
- Add new admin user: `GRANT ALL ON *.* TO '<user>'@'127.0.0.1' IDENTIFIED BY '<password>' WITH GRANT OPTION;`

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

## NUT

### Setup

Instructions for both servers and clients. Exclusive steps are marked "(Server)" or "(Client)".

Since SSL/TLS is not enabled by default for client-server communication, use only trusted networks for this communication.

1. Install: `apt install nut`
    - The service will fail to start since NUT is not configured yet.
1. Set the mode: Open `/etc/nut/nut.conf` and set `MODE=netserver` for server or `MODE=netclient` for client.
1. (Server) Add the UPS(s): Open `/etc/nut/ups.conf` and add a declaration for all UPSes (see example below).
    - Try using the `usbhid-ups` driver if using USB. Otherwise, check the [hardware compatibility list](https://networkupstools.org/stable-hcl.html) to find the correct driver. If the exact model isn't there, try a similar one.
    - For `usbhid-ups`, see the example below and [usbhid-ups(8)](https://networkupstools.org/docs/man/usbhid-ups.html).
    - You *may* need to modify some udev rules, but probably not.
1. (Server) Restart driver service: `systemctl restart nut-driver.service`
1. (Server) Set up local and remote access: Open `/etc/nut/upsd.conf` and set `LISTEN ::`.
    - Alternatively add one or multiple `LISTEN` directives for only the endpoints you wish to listen on.
1. (Server) Set up users: Open `/etc/nut/upsd.users` and add users (see example below).
    - Each client should have a separate user.
1. (Server) Restart the server service: `systemctl restart nut-server.service`
1. (Client) **TODO:** Something about `nut-client.service`.
1. Monitor the UPS: Open `/etc/nut/upsmon.conf` and add `MONITOR <ups>@<host>[:<port>] <ups-count> <user> <password> <master|slave>`.
    - `ups-count` is typically `1`. If this system is not powered by the UPS but you want to monitor it without shutting down, set it to `0`.
1. (Optional) Tweak upsmon:
    - Set `RBWARNTIME` (how often upsmon should complain about batteries needing replacement) to an appropriate value, e.g. 604800 (1 week).
1. (Optional) Add a notify script to run for certain events:
    - In `/etc/nut/upsmon.conf`, add `EXEC` to all `NOTIFYFLAG` entries you want to run the script for (typically all except `LOWBATT`).
    - In `/etc/nut/upsmon.conf`, set the script to run using format `NOTIFYCMD /opt/scripts/nut-notify.sh`.
    - Create the executable script. See an example below for sending email (if Postfix is set up).
1. Restart monitoring service: `systemctl restart nut-monitor.service`
1. Check the log to make sure `nut-monitor` successfully connected to the server.
    - Note that `upsc` does not use a server user or the monitoring service, so it's not very useful for debugging that.
1. Configure delays:
    1. Figure out how much time is needed to shut down the master and all slaves, with some buffer time.
    1. Set the remaining runtime and remaining battery charge for when the UPS should send the "battery low" event (requires admin login): `upsrw -s battery.runtime.low=<seconds> <ups>` and `upsrw -s battery.charge.low=<percent> <ups>`
        - This may not work on all UPSes, even if the values appear to be modifiable. This means you're probably stuck with the defaults.
    1. Set the delay from when the master issues the shutdown command to the UPS, to when the UPS powers off; and the delay from when the UPS receives power again to when it should turn on power: For `usbhid-ups`, this is set using `offdelay` and `ondelay`. Otherwise, it's set using `ups.delay.shutdown` and `ups.delay.start`. The start delay must be greater than the stop delay.
        - The shutdown command is issued from the master after it's done waiting for itself and slaves and is shutting itself down. The shutdown delay may be useful to increase if there are slaves that take much longer than the master to shut down.
    1. Restart the affected NUT services.
1. Simulate a power loss, which should power off all monitoring clients and then the UPS: `upsmon -c fsd`
    - If the client machines are not given enough time to power off before the UPS powers off, you need to modify the shutdown delay settings in the UPS.

Example USB UPS declaration for `usbhid-ups` (`/etc/nut/ups.conf`):

```
[alpha]
    desc = "PowerWalker VI 3000 RLE"
    # usbhid-ups should work for most UPSes with
    driver = usbhid-ups
    # If you have multiple UPSes connected, see usbhid-ups(8) for more specifying which USB device it should use
    port = auto
    # Sets "ups.delay.shutdown", the delay between the shutdown command and when the UPS powers off (default 20s)
    offdelay = 60
    # Sets "ups.delay.start", which has something to do with letting the UPS charge enough to make sure devices may fully boot (default 30s, must be greater than offdelay)
    ondelay = 120
```

Example server users (`/etc/nut/upsd.users`):

```
[admin]
    password = <password>
    actions = SET
    instcmds = ALL

[local]
    password = <password>
    upsmon master
```

Example notify script:

```bash
#!/bin/bash
echo -e "Time: $(date)\nMessage: $@" | mail -s "NUT: $@" root
```

## OpenSSL

### Usage

- Many OpenSSL default options are insecure and must be specified.
- Specifying `-noout -text` prints the data as formatted text instead of raw Base64.
- Create self-signed cert: `openssl req -new -x509 -sha256 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 3650 -subj "/C=ZZ/ST=Local/L=Local/O=Local/OU=Local/CN=localhost"`

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

## Portainer

### Standalone Server Setup

Is typically run on a Docker host. Includes the agent.

1. `docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ./data:/data portainer/portainer:<version>`
    - Port 9000 is the web UI.
    - Port 8000 is an SSH tunnel server for communicating with agents.
1. Open the web UI through port 9000 (by default) or a reverse proxy to configure it.
    - If `/var/run/docker.sock` was mounted, use "local".

### Standalone Agent Setup

Must be run on a Docker host. For extra Docker hosts you want to control with another Portainer server.

1. `docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:<version>`
1. **TODO**

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

File `smtp_header_checks`:
```
/^From:\s*.*\S+@node\.example\.bet.*.*$/ REPLACE From: "Node" <node@example.net>
/^To:\s*.*\S+@node\.example\.net.*$/ REPLACE To: "Someone" <someone@example.net>
```

### Usage

- Send a test mail: `echo "Test from $HOSTNAME at time $(date)." | mail -s "Test" root`
- Test the config: `postconf > /dev/null`
- Print the config: `postconf -n`
- If `mailq` tells you mails are stuck in the mail queue because of previous errors, run `postqueue -f` to flush them.

## Prometheus

Typically used with [Grafana](#grafana) and sometimes with Cortex/Thanos in-between.

### Setup (Docker)

1. See [(Prometheus) Installation](https://prometheus.io/docs/prometheus/latest/installation/).
1. Set the retention period and size:
    - (Docker) Find and re-specify all default arguments. Check with `docker inspect` or the source code.
    - Add the command-line argument `--storage.tsdb.retention.time=15d` and/or `--storage.tsdb.retention.size=100GB` (with example values).
    - Note that the old `storage.local.*` and `storage.remote.*` flags no longer work.
1. Mount:
    - Config: `./prometheus.yml:/etc/prometheus/prometheus.yml:ro`
    - Data: `./data/:/prometheus/:rw`
1. Configure `prometheus.yml`.
    - I.e. set global variables (like `scrape_interval`, `scrape_timeout` and `evaluation_interval`) and scrape configs.
1. (Optional) Setup remote storage to replicate all scraped data to a remote backend.
1. (Optional) Setup Cortex or Thanos for global view, HA and/or long-term storage.

### Notes

- The open port (9090 by default) contains both the dashboard and the query API.
- You can check the status of scrape jobs in the dashboard.
- Prometheus does not store data forever, it's meant for short- to mid-term storage.
- Prometheus should be "physically" close to the apps it's monitoring. For large infrastructures, you should use multiple instances, not one huge global instance.
- If you need a "global view" (when using multiple instances), long-term storage and (in some way) HA, consider using Cortex or Thanos.
- Since Prometheus receives an almost continuous stream of telemetry, any restart or crash will cause a gap in the stored data. Therefore you should generally always use some type of HA in production setups.
- Cardinality is the number of time series. Each unique combination of metrics and key-value label pairs (yes, including the label value) amounts to a new time series. Very high cardinality (i.e. over 100 000 series, number taken from a Splunk presentation from 2019) amounts to significantly reduced performance and increased memory and resource usage, which is also shared by HA peers (fate sharing). Therefore, avoid using valueless labels, add labels only to metrics they belong with, try to limit the numer of unique values of a label and consider splitting metrics to use less labels. Some useful queries to monitor cardinality: `sum(scrape_series_added) by (job)`, `sum(scrape_samples_scraped) by (job)`, `prometheus_tsdb_symbol_table_size_bytes`, `rate(prometheus_tsdb_head_series_created_total[5m])`, `sum(sum_over_time(scrape_series_added[5m])) by (job)`. You can also find some useful stats in the dashboard.

### About Cortex and Thanos

- Two similar projects, which both provide global view, HA and long-term storage.
- Cortex is push-based using Prometheus remote writing, while Thanos is pull-based using Thanos sidecars for all Prometheus instances.
- Global view: Cortex stores all data internally, while Thanos queries the Prometheus instances.
- Prometheus HA: Cortex stores one instance of the received data (at write time), while Thanos queries Prometheus instances which have data (at query time). Both approaches removes gaps in the data.
- Long-term storage: Cortex periodically flushes the NoSQL index and chunks to an external object store, while Thanos uploads TSDB blocks to an object store.

## Prometheus Exporters

### Exporters and Software

This list contains exporters and software with built-in exposed metrics I typically use. Some are described in more detail in separate subsections.

#### Software with exposed metrics

- Prometheus (exports metrics about itself)
- [Grafana](https://grafana.com/docs/grafana/latest/administration/metrics/)
- [Docker Daemon](https://docs.docker.com/config/daemon/prometheus/)
- [Traefik](https://github.com/containous/traefik)
- [AWX](https://docs.ansible.com/ansible-tower/latest/html/administration/metrics.html)

#### Exporters

- [Node exporter (Prometheus)](https://github.com/prometheus/node_exporter)
- [Windows exporter (Prometheus Community)](https://github.com/prometheus-community/windows_exporter)
- [SNMP exporter (Prometheus)](https://github.com/prometheus/snmp_exporter)
- [IPMI exporter (Soundcloud)](https://github.com/soundcloud/ipmi_exporter)
- [NVIDIA DCGM exporter (NVIDIA)](https://github.com/NVIDIA/gpu-monitoring-tools/)
- [NVIDIA GPU exporter (mindprince)](https://github.com/mindprince/nvidia_gpu_prometheus_exporter)
- [cAdvisor (Google)](https://github.com/google/cadvisor)
- [UniFi exporter (jessestuart)](https://github.com/jessestuart/unifi_exporter)
- [BIND exporter (Prometheus Community)](https://github.com/prometheus-community/bind_exporter)
- [Blackbox exporter (Prometheus)](https://github.com/prometheus/blackbox_exporter)
- [NUT Exporter (HON95)](https://github.com/HON95/prometheus-nut-exporter)
- [ESP8266 DHT Exporter (HON95)](https://github.com/HON95/prometheus-esp8266-dht-exporter)

#### Special

- [Pushgateway (Prometheus)](https://github.com/prometheus/pushgateway)

### Prometheus Node Exporter

Can be set up either using Docker ([prom/node-exporter](https://hub.docker.com/r/prom/node-exporter/)) or using the package manager. The Docker method provides a level of protection as it enables read-only system access and the image is always up-to-date, unlike the package version.

#### Setup (Using the Package Manager)

- Info:
    - Doesn't require Docker, which may not be possible or practical for certain systems.
    - May be outdated.
- Files and dirs:
    - Configuration file: `/etc/default/prometheus-node-exporter`
    - Textfile directory: `/var/lib/prometheus/node-exporter/`
- Installation: `apt install prometheus-node-exporter`
- It may come with certain oneshot services and associated timers for.
    - Some of these may cause minor problems (check the system log).
    - To disable them, disable the systemd timer and remove any associated textfile output in the textfile directory.

#### Textfile Collector

#### Collector scripts

Some I typically use.

- [apt.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/apt.sh)
- [yum.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/yum.sh)
- [deleted_libraries.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/deleted_libraries.py)
- [ipmitool (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/ipmitool) (requires ipmitool)
- [smartmon.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/smartmon.sh) (requires smartctl)

#### Setup and Usage

1. Set the collector script output directory using the CLI argument `--collector.textfile.directory=<dir>`.
    - Example dir: `/var/lib/prometheus/node-exporter/`
    - If the node exporter was installed as a package, it can be set in the `ARGS` variable in `/etc/default/prometheus-node-exporter`.
    - If using Docker, the CLI argument specified as part of the command.
1. Download the collector scripts and make them executable.
    - Example dir: `/opt/prometheus/node-exporter/textfile-collectors/`
1. Add cron jobs for the scripts using sponge to wrote to the output dir.
    - Make sure `sponge` is installed. For Debian, it's found in the `moreutils` package.
    - Example cron file: `/etc/cron.d/prometheus-node-exporter-textfile-collectors`
    - Example cron entry: `0 * * * * root /opt/prometheus/node-exporter/textfile-collectors/apt.sh | sponge /var/lib/prometheus/node-exporter/apt.prom`

### Prometheus Blackbox Exporter

#### Monitor Service Availability

Add a HTTP probe job for the services and query for probe success over time.

Example query: `avg_over_time(probe_success{job="node"}[1d]) * 100`

#### Monitor for Expiring Certificates

Add a HTTP probe job for the services and query for `probe_ssl_earliest_cert_expiry - time()`.

Example alert rule: `probe_ssl_earliest_cert_expiry{job="blackbox"} - time() < 86400 * 30` (30 days)

## Pterodactyl

### General

- The panel must be able to communicate with all daemons and all vice versa.
  The user must be able to communicate with both the panel and daemons.
- Both the panel and daemons need valid TLS certificates.

### Panel (Docker)

#### Setup

**TODO**

Logs are located in `/app/storage/logs/laravel/` inside the container.

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

## smartmontools

- For monitoring disk health.
- Install: `apt install smartmontools`
- Show all info: `smartctl -a <dev>`
- Tests are available in foreground and background mode, where foreground mode is given higher priority.
- Tests:
    - Short test: Can be useful to quickly identify a faulty drive.
    - Long test: May be used to validate the results found in the short test.
    - Convoyance test: Intended to quickly discover damage incurred during transportation/shipping.
    - Select test: Test only the specified LBAs.
- Run test: `smartctl -t <short|long|conveyance|select> [-C] <dev>`
    - `-C`: Foreground mode.

## TFTP-HPA

### Setup

1. Install `tftpd-hpa`.
1. Update `/etc/default/tftpd-hpa` based on the config below.
1. Create the folder `/var/tftp` with permissions `777` and user-group pair `tftp:tftp`.
1. Restart it.
1. If it shouldn't automatically start, disble it.

File `/etc/default/tftpd-hpa`:
```
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--create --secure"
```

## Unbound

### Setup

1. Install: `apt install unbound dns-root-data`
    - It may fail to start due to systemd-resolved listening to the DNS UDP port.
1. Setup the config: `/etc/unbound/unbound.conf`
1. Make sure `/etc/hosts` contains the short and FQDN hostnames.
1. Setup systemd-resolved:
    1. Open `/etc/resolv.conf`.
    1. Set `DNSStubListener=no`.
    1. Set `DNS=::1`.
    1. Restart `systemd-resolved`.
1. Setup resolv.conf:
    1. Open `/etc/resolv.conf`.
    1. Set:
        ```
        nameserver 127.0.0.1
        nameserver ::1
        domain <domain>
        search <domain-list>
        ```
1. Restart unbound: `systemctl restart unbound`
1. Test DNSSEC:
    - `drill sigfail.verteiltesysteme.net` should give an rcode of `SERVFAIL`.
    - `drill sigok.verteiltesysteme.net` should give an rcode of `NOERROR`.
1. Make sure dns-root-data is updating root hints in file `/usr/share/dns/root.hints`.

### Notes

- Use DNS over HTTPS/TLS.
- Setup private addresses for DNS rebinding prevention.

## UniFi

See [Ubiquiti UniFi Controller (Debian)](../unifi-debian/).

## ZFS

See [Storage: ZFS](../linux-storage/#zfs).

{% include footer.md %}
