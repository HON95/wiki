---
title: Linux Server Applications
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

Using **Debian**, unless otherwise stated.

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

## BIND

### Info

- Aka "named".

### Config

- Should typically be installed directly on the system, but the Docker image is pretty good too.
    - Docker image: [internetsystemsconsortium/bind9 (Docker Hub)](https://hub.docker.com/internetsystemsconsortium/bind9)
- Guides:
    - [Tutorial: How To Configure Bind as a Caching or Forwarding DNS Server on Ubuntu 16.04 (DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-caching-or-forwarding-dns-server-on-ubuntu-16-04)
    - [Tutorial: How To Setup DNSSEC on an Authoritative BIND DNS Server (DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-setup-dnssec-on-an-authoritative-bind-dns-server-2)

### Usage

- Valdiate config: `named-checkconf`
- Validate DNSSEC:
    - `dig sigfail.verteiltesysteme.net @<server> +dnssec` should give an rcode of `SERVFAIL`.
    - `dig sigok.verteiltesysteme.net @<server> +dnssec` should give an rcode of `NOERROR`.

## bitwarden_rs

A free community backend for Bitwarden.

**TODO**

## Ceph

See [Storage: Ceph](/config/linux-server/storage/#ceph).

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

See [Storage: isdct](/config/linux-server/storage/#intel-ssd-data-center-tool-isdct).

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

See [Home Assistant](/config/iot-ha/home-assistant/).

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

## lm_sensors

Get sensor values like temperature, voltage, fan speeds, etc.

### Setup

1. Install: `apt install lm-sensors`
1. Test run it: `sensors`
1. Run `sensors-detect`. When it asks, add the modules to `/etc/modules`.
1. Load new modules: `systemctl restart kmod`
1. Test run it: `sensors`

### Troubleshooting

- There's module/chip/sensor errors in the output or `journalctl`:
    - If you know which chip and sensor (e.g. if it shows it during output), try adding `chip "<chip>"\n    ignore <sensor>` in `/etc/sensors3.conf`. Re-run `sensors`. (See [Kernel ACPI Error SMBus/IPMI/GenericSerialBus (ServerAdminBlog)](https://www.serveradminblog.com/2015/05/kernel-acpi-error-smbusipmigenericserialbus/) for an example on certain HP servers.)
    - If you know which module it is, try to unload it. Re-run `sensors`. If it worked, then remove it from `/etc/modules` to make it permanent.

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

The instructions below use NFSv4 *without* Kerberos. This should only be used on trusted networks and requires manual user and group ID management.

### Server (without Kerberos)

#### Setup

1. (Recommended) Use NTP on both server and clients to make sure the clocks are synchronized.
1. Install: `apt install nfs-kernel-server`
    - Install `portmap` if you need support for NFSv2 and v3 (not NFSv4).
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
      systemctl disable --now rpcbind.service
      systemctl mask rpcbind.service
      systemctl mask rpcbind.socket
      ```
    1. Restart it: `systemctl restart nfs-server.service`
    1. See which versions are running: `cat /proc/fs/nfsd/versions` (`-` means disabled)

#### Usage

1. Setup a new directory contain all exports in:
    1. Create the root export containing other export dirs: `mkdir /export`
    1. Create the export mount dirs within the container.
    1. Mount the exports in the container using bind mounts.
        - Example fstab entry using ZFS: `/zfspool/alpha /export/alpha none bind,defaults,nofail,x-systemd.requires=zfs-mount.service 0 0`
    1. Remember to set appropriate permissions.
1. Add filesystems to export in `/etc/exports`.
    - See the example config below.
    - For a list of options, see `exports(5)`.
1. Update the NFS table: `exportfs -ra`
    - Or, restart the service: `systemctl restart nfs-server.service`
1. (Optional) Show exports: `exportfs -v`
1. (Optional) Update the firewall:
    - NFSv4 uses only TCP port 2049.

Example `/etc/exports`:

```
# "fsid=root" is a special root export in NFSv4 where other exports are accessible relative to it.
# "sync" should generally always be used. While "async" gives better performance, it violates the spec and may cause data loss in case of power loss.
# "root_squash" maps client root users to an anon user to prevent remote root access. If that's desired, set "no_root_squash" instead.
# "no_subtree_check" disables subtree checking. Subtree checking may be appropriate for certain file systems, but in general it may cause more problems than it solves.
# "insecure" allows clients connecting from non-well-known ports.
/export/ *(fsid=root,ro,sync,root_squash,no_subtree_check,insecure)
/export/projects/ *(rw,sync,root_squash,no_subtree_check,insecure)
```

### Client (without Kerberos)

#### Setup

1. Install: `apt install nfs-common`

#### Usage

1. Create a dir to mount the export to.
1. (Optional) Try to mount it:
    - Command: `mount -t nfs4 <server-hostname>:<export> <mountpoint>`
    - Note that for NFSv4 with a root export, the export path is relative to the root export.
1. (Optional) Make it permanent by adding it to fstab.
    - `/etc/fstab` entry: `<nfs-server>:<export> <local-dir> nfs4 defaults 0 0`

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

### Usage

- Show UPSes: `upsc -l`
- Show UPS vars: `upsc <ups>`

#### Query the Server

1. Telnet into it: `telnet localhost 3493`
1. Show UPSes: `LIST UPS`
1. Show UPS vars: `LIST VAR <ups>`

## OpenSSL

### Usage

- General info:
    - Many OpenSSL default options are insecure and must be specified.
    - Specifying `-noout -text` prints the data as formatted text instead of raw Base64.
- Inspect certificate file: `openssl x509 -in <cert-file> [-inform der] -noout -text`
- Inspect online certificate: `openssl s_client -connect <site>:443 </dev/null | openssl x509 -noout -text`
- Create self-signed cert for localhost/localdomain:
    ```sh
    openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -out localhost.crt -keyout localhost.key -config <(
    cat <<-EOF
    [req]
    default_bits = 2048
    prompt = no
    default_md = sha256
    x509_extensions = ext
    distinguished_name = dn

    [ext]
    subjectAltName = @alt_names
    basicConstraints = CA:FALSE
    #keyUsage = digitalSignature, keyEncipherment
    #extendedKeyUsage = serverAuth

    [dn]
    C = ZZ
    ST = Localhost
    L = Localhost
    O = Localhost
    OU = Localhost
    emailAddress = webmaster@localhost
    CN = localhost

    [alt_names]
    DNS.1 = *.localdomain.
    EOF
    )
    ```

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

## Processor Counter Monitor (PCM)

### Setup

1. Load the MSR (x86 model-specific register) module: `modprobe msr`
    - Make this persistent or load it when you need PCM.
1. Install the perf toolkit: `apt install linux-tools-generic`
1. Download the source: `git clone https://github.com/opcm/pcm`
1. Build it: `make`
    - The output binaries are contained in the current dir with `.x` suffixes.

### Usage

#### CLI

- Basic process monitoring: `pcm`
- Memory bandwidth monitoring: `pcm-memory`
- Memory/cache latency monitoring: `pcm-latency`
- PCIe per-socket bandwidth monitoring: `pcm-pcie`
- PCIe per-device bandwidth monitoring: `pcm-iio`
- NUMA monitoring: `pcm-numa`
- Energy-related monitoring: `pcm-power`
- Intel TSX monitoring: `pcm-tsx`
- Procesor core event monitoring: `pcm-core`
- Procesor core event querying: `pcm-query`
- Program core/uncore events: `pcm-raw`
- Collect memory bandwidth utilization histogram: `pcm-hw-histogram`

#### GUI

- Grafana dashboard using Prometheus exporter (`pcm-sensor-server`).
- KDE KSysGuard: `pcm-sensor`
- WIndows perfmon: `pcm-service`

#### Miscellanea

- JSON or Prometheus exporter: `pcm-sensor-server`

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

### Setup (Satellite System)

#### References

- [How to Set Up a Mail Relay with Postfix and Mailgun on Ubuntu 16.04 (DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-mail-relay-with-postfix-and-mailgun-on-ubuntu-16-04)
- [How To Start Sending Email (Mailgun)](https://documentation.mailgun.com/en/latest/quickstart-sending.html)
- [Postfix (SendGrid)](https://sendgrid.com/docs/for-developers/sending-email/postfix/)

#### Notes

- When using an SMTP relay, the original IP address will likely be found in the mail headers. So this will generelly not provide any privacy.
- Make sure DNS is configured correctly (SPF, DKIM, DMARC).
    - Example DMARC record for the `_dmarc` subdomain: `v=DMARC1; adkim=r; aspf=r; p=quarantine;`
- In certain config places, specifying a domain name will use the MX record for it, but putting it in square brackets will use the A/AAAA record for it.

#### Setup

1. Install: `postfix libsasl2-modules mailutils`
    - If asked, choose to configure Postfix as a satellite system.
1. Update the root alias:
    - In `/etc/aliases`, add `root: admin@example.net` (for forward everything to `admin@example.net`).
    - Run `newaliases` to update the alias DB file.
1. Update the `main.cf` config.
    - Example: [main.cf](https://github.com/HON95/configs/blob/master/postfix/main.cf)
    - Update FQDN.
    - Only listen to localhost: Set `inet_interfaces = loopback-only`
    - Disable relaying: Set `mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128`
    - Anonymize banner: `smtpd_banner = $myhostname ESMTP`
    - Disable backward compatibility before a certain level: `compatibility_level = 2`
1. Configure the relay provider:
    - See the references above.
    - SendGrid uses `apikey` as the username for API key access.
1. Setup relay credentials (SASL):
    1. Create and secure credentials file: `touch sasl_passwd && chmod 600 sasl_passwd`
    1. Add your credentials using this format: `[relay_domain]:port user@domain:password`
        - Example: [sasl_passwd](https://github.com/HON95/configs/blob/master/postfix/sasl_passwd)
    1. Update database: `postmap sasl_passwd`
1. (Optional) Rewrite from-to fields: See below.
1. Restart `postfix`.
1. Try sending an email: `echo "Test from $(hostname) at time $(date)." | mail -s "Test" root`

##### Fancy To-From Fields

Use this mess to change the ugly `From: root@node.example.net` and `To: root@node.example.net` to `From: "Node" <root@node.example.net>` and `To: "Admin" <admin@example.net>` when most/all email coming from the system is from root to some root alias.

1. Add a `smtp_header_checks` file (arbitrary name).
    - Example: [smtp_header_checks](https://github.com/HON95/configs/blob/master/postfix/smtp_header_checks)
1. Add it to `main.cf`: `smtp_header_checks = regexp:/etc/postfix/smtp_header_checks`
1. Test it locally: `postmap -fq "From: root@$(hostname --fqdn)" regexp:smtp_header_checks`
1. Restart `postfix`.
1. Test it with a real email.

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

### General

- Exporters often expose the metrics endpoint over plain HTTP without any scraper or exporter authentication. Prometheus supports exporters using HTTPS for scraping (for integrity, confidentiality and authenticating the Prometheus), as well as using client authentication (from Prometheus, for authenticating Prometheus), providing mutual authentication if both are used. This may require setting up a reverse web proxy in front of the exporter. Therefore, the simplest alternative (where appropriate) is often to just secure the network itself using segmentation and segregation.

### List of Exporters and Software

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
- [Prometheus Proxmox VE exporter (prometheus-pve)](https://github.com/prometheus-pve/prometheus-pve-exporter)
- [NUT Exporter (HON95)](https://github.com/HON95/prometheus-nut-exporter)
- [ESP8266 DHT Exporter (HON95)](https://github.com/HON95/prometheus-esp8266-dht-exporter)

#### Special

- [Pushgateway (Prometheus)](https://github.com/prometheus/pushgateway)

### Prometheus Node Exporter

Can be set up either using Docker ([prom/node-exporter](https://hub.docker.com/r/prom/node-exporter/)), using the package manager (`prometheus-node-exporter` on Debian), or by building it from source. The Docker method provides a small level of protection as it's given only read-only system access. The package version is almost always out of date and is typically not optimal to use. If Docker isn't available and you want the latest version, build it from source.

#### Setup (Downloaded Binary)

See [Building and running](https://github.com/prometheus/node_exporter#building-and-running (node_exporter)).

Details:

- User: `prometheus`
- Binary file: `/usr/bin/prometheus-node-exporter`
- Service file: `/etc/systemd/system/prometheus-node-exporter.service`
- Configuration file: `/etc/default/prometheus-node-exporter`
- Textfile directory: `/var/lib/prometheus/node-exporter/`

Instructions:

1. Install requirements: `apt install moreutils`
1. Find the link to the latest tarball from [the download page](https://prometheus.io/download/#node_exporter).
1. Download and unzip it: `wget <url>` and `tar xvf <file>`
1. Move the binary to the system: `cp node_exporter*/node_exporter /usr/bin/prometheus-node-exporter`
1. Make sure it's runnable: `node_exporter -h`
1. Add the user: `useradd -r prometheus`
    - If you have hidepid setup to hide system process details from normal users, remember to add the user to a group with access to that information. This is only required for some metrics, most of them work fine without this extra access.
1. Create the required files and directories:
    - `touch /etc/default/prometheus-node-exporter`
    - `mkdir -p /var/lib/prometheus/node-exporter/`
1. Create the systemd service `/etc/systemd/system/prometheus-node-exporter.service`, see [prometheus-node-exporter.service](../files/prometheus-node-exporter.service.txt).
1. (Optional) Configure it:
    - The defaults work fine.
    - File: `/etc/default/prometheus-node-exporter`
    - Example: `ARGS="--collector.processes --collector.interrupts --collector.systemd"` (enables more detailed process and interrupt collectors)
1. Enable and start the service: `systemctl enable --now prometheus-node-exporter`
1. (Optional) Setup textfile exporters.

#### Textfile Collector

##### Setup and Usage

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

##### Collector Scripts

Some I typically use.

- [apt.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/apt.sh)
- [yum.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/yum.sh)
- [deleted_libraries.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/deleted_libraries.py)
- [ipmitool (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/ipmitool) (requires ipmitool) (**Warning:** This is slow, don't run it frequently. If you do, it may spawn more and more processes waiting to read the IPMI sensors. Run it manually to get a feeling.)
- [smartmon.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/smartmon.sh) (requires smartctl)
- [My own textfile exporters](https://github.com/HON95/prometheus-textfile-exporters)

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

## SSHD

### Security Recommendations

- Disable root login (strongly recommended).
    - Use users with sudo access (or with su and knowing the root password) instead.
    - Only allow with `PermitRootLogin without-password` in case you need root access to the server with tools that don't play nice with sudo.
    - Principle of least privilege.
    - Avoid using shared accounts. Simple accounting/auditing is basically impossible (who are logged in, who did that, etc.) and passwords are easily leaked (when sending it to persons that should have access) and hard to change (having to redistribute the one password to everyone again).
- For public-facing entry points, use pubkey authentication and disable password authentication (recommended).
    - Pubkey authn is secure against MITM attacks since it uses a Diffie Hellman key exchange where the middle man can't affect the input from the client since it's signed by the clients private key (which is never sent to the server). Password authn sends the actual password over the wire, meaning a middle man can easily disguise itself as the client. (See [SSH Man-in-the-Middle Attack and Public-Key Authentication Method (Gremwell)](https://www.gremwell.com/ssh-mitm-public-key-authentication).)
    - Pubkeys are often more convenient to use since the user won't have to type the full password. In public, not having to type the password (when people are watching) may be considered more secure.
    - For _internal_ systems, where authn is typically centrally handled and users often have to SSH between systems (where their SSH key isn't and shouldn't be present), passwords generally are a better option.
- Consider using MFA with OTP in addition to the pubkey (sometimes recommended).
    - Note that this also makes logins signficantly more annoying for users, so don't use this needlessly.
    - See the [Google Authenticator section](#google-authenticator)).
- Use Fail2Ban or similar (recommended):
    - Blocks IP addresses after a number of unsuccessful attempts.
    - Highly effective against brute force attacks.
    - May cause accidental of malicious lockouts of legitimate users.
- Change the server port (not recommended).
    - Security by obscurity.
    - Almost eliminates "random" attacks, but useless if being targeted as a simple port scan will generally reveal the port.
    - Reduces the chance of successful authentications if the server uses _easily guessable users_ (e.g. root, admin, pi) with _weak passwords_ (if password authn is even enabled).
    - Reduces server load from not having to deal with the connections, but the load is typically negligible anyways.
- Disable IPv6 (not recommended).
    - Fix the network instead.
    - For legacy IPv4-only networks or servers, firewall IPv6 instead (all of it).

## TFTP-HPA

### Setup

1. Install: `apt install tftpd-hpa` (note the `d`)
1. (Optional) Configure it:
    - Config file: `/etc/default/tftpd-hpa`
    - Change dir: `TFTP_DIRECTORY="<dir>"` (e.g. `/var/tftp`)
    - Change options: `TFTP_OPTIONS="[opt]*"` (see the most relevant options below)
    - Option `--secure`: Change the root directory to the specified `TFTP_DIRECTORY` directory.
    - Option `--create`: Allow clients to upload new files. Existing files may be changed regardless.
1. Fix folder permissions:
    - Make sure `tftp:tftp` has read access.
    - If it needs to be TFTP writable, make sure `tftp:tftp` has write access to it.
1. Restart it: `systemctl restart tftpd-hpa`

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

See [Ubiquiti UniFi Controllers](/config/network/ubiquiti-unifi-controllers/).

## WireGuard

### Installation

1. Install: `apt install wireguard`
1. (Debian) Fix broken DNS (using systemd resolved):
    1. Enable systemd resolved: See [systemd-resolved (Debian server setup)](/config/linux-server/debian/#using-systemd-resolved-alternative-2).
    1. Fix missing `resolvconf`: `ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf`

### Usage

- Default config path (not world readable): `/etc/wireguard/*.conf`
- Bring up or down a tunnel based on a config: `wg-quick {up|down} <conf>`
- Start a tunnel on boot: `systemctl enable wg-quick@wg0.service` (for config `/etc/wireguard/wg0.conf`)

**Example tunnel config**:

```
[Interface]
# Generate with "wg genkey"
PrivateKey = <HIDDEN>
# Address for the local tunnel interface
Address = 10.234.0.3/31, 2a0f:9400:800f:ff01::1/127
DNS = 1.1.1.1, 2606:4700:4700::1111

[Peer]
# Get with "echo <privkey> | wg pubkey"
PublicKey = <HIDDEN>
# Add static route and reverse path filtering
# "0.0.0.0/0, ::/0" means this will be the default gateway, capturing all traffic
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = vpn.oolacile.hon.systems.:51823
# Keep the connection alive to keep firewall state alive (not very stealthy, though)
PersistentKeepalive = 25
```

## ZFS

See [Storage: ZFS](/config/linux-server/storage/#zfs).

{% include footer.md %}
