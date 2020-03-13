---
title: Linux Server Applications
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

**TODO** Migrate the rest of the config notes from the old Google Doc.

### Using
{:.no_toc}

- Debian 10 Buster

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

## ISC DHCP Server and radvd

**FIXME**

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
    2. For DHCPv6, configure radvd in stateful mode and DHCPv6.
6. (Optional) Setup interfaces to listen to:
    - This *may* (?) mute the "No subnet declaration for ..." verbose error on some distros.
    - In `/etc/default/isc-dhcp-server`, add the interfaces (space-separated) to `INTERFACESv4` and `INTERFACESv6`.

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

### Setup

- Note: The node must be publicly accessable.
- Follow the official guide.

### Game Servers

#### CSGO

- It uses a ton of storage, between 20 and 30 GB last I checked. If you useless, the installer will fail with some useless error message.
- Use app ID 730 in Steam Game Server Account Manager, regardless of which app ID the server was created with. If you use e.g. 740, the server will not be able to log into Steam.

## radvd

See [ISC DHCP Server and radvd](#isc-dhcp-server-and-radvd).

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

Using the unofficial Docker image by jacobalberty.

1. Add a system user named "unifi": `useradd -r unifi`
1. Allow the ports through the firewall: See [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used).
1. Add a Docker Compose file. See [docker-compose.yml](https://github.com/HON95/misc-configs/blob/master/linux-server/unifi/docker-compose.yml).
    - Use host networking mode for L2 adoption to work (if you're not using L3 or SSH adoption).
1. Start the container, open the webpage and follow the wizard.

{% include footer.md %}
