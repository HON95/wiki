---
title: Ubiquiti UniFi Controllers
breadcrumbs:
- title: Server
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Ubiquiti UniFi Access Points](/config/network/ubiquiti-unifi-aps/)

## General

- Relevant ports (incoming) (from [Ports Used (UniFi)](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)):
    - TCP 8443: GUI/API (for admins)
    - TCP 8880: HTTP portal (for guests)
    - TCP 8843: HTTPS portal (for guests)
    - TCP 6789: Mobile speedtest (for admins)
    - TCP 8080: Device-controller communication (for devices)
    - UDP 1900: L2 adoption (for devices, optional)
    - UDP 3478: STUN (for devices)
    - UDP 10001: Device discovery (for devices)
    - UDP 5514: Syslog (for monitoring)

## Setup

Setup alternatives:

- Cloud Key (official hardware controller)
- Linux package (official)
- Docker image (unofficial)

### Cloud Key

- A standalone device by Ubiquiti.
- Costs money.
- Requires physical space and power.
- Doen't require setting it up yourself, which can be a little tricky/uncomfortable.
- Supports a limited amount of devices and clients, however most small-to-mid-size deployments are unlikely to reach that limit.

### Debian 9

UniFi 5 is the latest version and does only officially support Debian 9 (Stretch) and Ubuntu Desktop/Server 16.04 for Linux. It requires Java 8 and other stuff which is an absolute pain to install on later versions of Debian. There is also the official physical Cloud Key device and multiple unofficial Docker images and installation packages for Linux servers.

Official installation instructions: [UniFi: How to Install & Upgrade the UniFi Network Controller Software](https://help.ubnt.com/hc/en-us/articles/360012282453-UniFi-How-to-Install-Upgrade-the-UniFi-Network-Controller-Software)

1. Install Debian 9 (later versions don't have the required versions of Java etc.).
1. Configure it: See [Debian Server](/config/linux-server/debian/) (for Debian 10).
1. Open incoming ports: See note above.
1. (Optional) NAT port 443 to 8443 (to access it from the normal HTTPS port): `iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443`
1. (Alternative 1) Install via repo: See [How to Install and Update via APT on Debian or Ubuntu (UniFi)](https://help.ui.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu).
1. (Alternative 2) Install via downloaded package: Go to the UniFi downloads page and download for Linux/Debian.
1. Configure:
    - File: `/var/lib/unifi/system.properties`
    - (Optional) Reduce the pre-allocated memory size: `unifi.xms=256`
1. (Optional) Check the logs:
    - UniFi: `/usr/lib/unifi/logs/server.log`
    - MongoDB: `/usr/lib/unifi/logs/mongod.log`
1. Set up UniFi in the web UI.
1. (Optional) Usa an existing TLS certificate:
    1. Stop UniFi.
    1. Save the full-chain certificate as `fullchain.pem` and key as `privkey.pem`.
    1. Convert it: `openssl pkcs12 -export -inkey privkey.pem -in fullchain.pem -out cert.p12 -name unifi -password pass:temppass`
    1. Import it: `keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore cert.p12 -srcstoretype PKCS12 -srcstorepass temppass -alias unifi -noprompt`
    1. Delete the local files.
    1. Start UniFi.

### Unofficial Docker Image

See [jacobalberty/unifi-docker (GitHub)](https://github.com/jacobalberty/unifi-docker).

{% include footer.md %}
