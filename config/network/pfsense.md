---
title: pfSense
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: Network
---
{% include header.md %}

### Using
pfSense v2

## Initial Setup

### Installation

- Use ZFS for the root device.

### Configuration

1. Connect to the website and finish the wizard.
2. Set upstream DNS and NTP servers.
3. Enable password protection for the console.
4. Add a personal user and disable the admin user.
5. Enable "PowerD" in "hiadaptive" mode to enable power saving while still focusing on performance.
6. Enable AES-NI hardware crypto.
7. Set the correct thermal sensors.
8. Enable RAM disks with e.g. 1024MiB and 4096MiB and e.g. 3 hour backups.
9. Increase network memory buffer size: Add a new system tunable with key `kern.ipc.nmbclusters` and value `1000000`.
10. Disable TCP segmentation offload (TSO) and large receive offload (LRO). Most hardware/drivers have issues with them.
11. See [this page](https://docs.netgate.com/pfsense/en/latest/hardware/tuning-and-troubleshooting-network-cards.html) for NIC-specific tuning.

## Services

### FreeRADIUS

#### Basic Setup

1. Install `freeradius3`.
2. Go to the FreeRADIUS settings.
3. Add an interface for authentication: Listen on all interfaces (or only localhost), port 1812, type "authentication", IPv4. Add a separate interface for IPv6.
4. Add an interface for accounting: Listen on all interfaces (or only localhost), port 1813, type "accounting", IPv4. Add a separate interface for IPv6.
5. Add clients/NAS.
6. Add RADIUS users.
7. (Optional) Use FreeRADIUS as an authentication backend.
   1. Create a RADIUS client with client IP address `127.0.0.1`.
   2. Add the RADIUS client in "System/User Manager/Authentication Servers".
   3. **TODO** What's the "RADIUS NAS IP Attribute"?

#### Setup RADIUS as an Authentication Backend

1. Create a RADIUS client with client IP address `127.0.0.1`.
2. Add the RADIUS client in "System/User Manager/Authentication Servers".

#### Setup OTP

1. Make sure the server's time is synchronized, e.g. using NTP.
2. Use the PAP protocol, so that the OTP code can be transmitted along with the password. PAP is not the most secure protocol, but it's fine for running locally, such as when using OpenVPN with RADIUS as the auth backend.
3. Enable OTP support in the RADIUS settings.
4. Enable OTP for each user that should have it:
   1. Clear the user's password. It will no longer be used.
   2. Enable OTP using the Google Authenticator method.
   3. Set/generate a 4-8 digit PIN for the user.
   4. To log in with this user, the supplied password must consist of the PIN concatenated with the OTP code.

#### Notes

- RADIUS should only be used over channels/networks trusted by both/all parties, such as core networks and localhost. It sends the password in plaintext or weak ciphertext. To use it over untrusted channels, use it within a VPN such as IPsec.
- OTP disables/replaces the user's password with the PIN+OTP code. It should only be used with other types of authentication, such as a VPN certificate. Unless the PIN code is made equally strong as an acceptable password.

### ntopng

#### Setup

1. Install `ntopng`.
2. Enable it.
3. Set an admin password. (The username is "admin".)
4. Enable all interfaces to monitor.
5. Update GeoIP data (save first, it reloads the page).
6. New users can be added through the web panel.
7. It uses a bit of storage and processing power, so disable it if it's not being used.

### OpenVPN

#### Setup

1. OpenVPN is built in.
2. Install `openvpn-client-export`.
3. (Recommended) Use RADIUS as the local auth backend. OpenVPN + FreeRADIUS supports authentication with cert. + PIN + TOTP.
4. Use the wizard.
5. Use hardware crypto if you have it.
6. Use server mode with TLS cert. and password.

### Suricata

#### Setup

1. Disable hardware checksum offloading. Suricata doesn't work well with it.
2. Insall `suricata`.
3. Update the rule set manually the first time.
4. Select which rule sets to install. E.g. the ETOpen Emerging Threats (ET) Open which is free and modular.
5. Set the rule update interval. E.g. 6 or 12 hours.
6. Enable "live rule swap on update".
7. Set the "remove blocked host interval". E.g. 15 minutes.
8. Add the WAN interface.
   1. Enable desired logs.
   2. Don't enable "block offenders" (yet).
   3. Set the detect-engine profile appropriately. Use "high" if you have more than 4GB of memory and an okay machine.
9. Enable "resolve flowbits", which allows rules to match based on multiple packets by setting bits on the flow (or something like that).
10. Select which installed rule sets to use.
    1. Description of some ET Open rule sets: [Here](https://doc.emergingthreats.net/bin/view/Main/EmergingFAQ#What_is_the_general_intent_of_ea)
    2. Some rule sets contain a short description at the top of the file.
    3. Only enable rule sets if you know what they do.
    4. Only enable rule sets if you need them.
    5. Some rules produce alerts even for safe traffic.
    6. Some rule sets may be slower than others.
    7. More rules means more processing overhead.
    8. More rules means more problems and debugging.
11. Double all the "memory cap" values. It can fail to start if it runs out of memory.
12. Enable/start the WAN interface.
    1. If it doesn't start, check the error log. If it contains "alloc error" or "pool grow failed", increase "Stream Memory Cap" to e.g. `100663296` (96MiB).
    2. If it failed to start, it may have failed to remove its PID file. Remove it manually if it refuses to restart because of it.
13. Watch for alerts and resolve false alerts by changing and tweaking the settings.
    1. Torrenting is a useful way of load testing.
    2. Try using different applications: Web browsing, games, torrenting, streaming, pinging.
14. Enable "block offenders" when there's no more false alerts, using the desired mode.
    1. Legacy mode copies packets and inspects the copies. It may allow some packets to leak through before blocking.
    2. Inline mode inspects packets before the host network stack. It will affect performance/latency but will not leak, thus making it more secure. It requires support from the NIC driver.
15. Test it by trying to do bad stuff.
    1. Try downloading the EICAR file.
16. (Optional) Add LAN interfaces.

### Unbound

#### Setup

1. Use only the DNS resolver (Unbound), not the older DNS forwarder (dnsmasq).
2. Receive from and transmit to every interface.
3. Use a "transparent" local zone.
4. Enable DNSSEC.
5. Enable forwarding mode if you want to query a set of selected servers instead of the root servers. The selected servers are the ones specified in the system settings. Check that you're not using the DNS servers provided by DHCP, unless you want that for some reason.
6. Use TLS for outgoing queries if using forwarding mode and the selected servers supports it (such as Cloudflare).
7. Don't register DHCP or OpenVPN clients.
8. Enable DNSSEC hardening.
9. Enable DNS rebinding protection in the system settings (enabled by default).

#### Usage

- Add custom A/AAAA records to the host overrides section. The pfSense host is automatically added using its hostname and LAN IP address.

### UPnP/NAT-PMP

- Only use it if a game requires it and the network is trusted. It's generally a vulnerable mechanism.

{% include footer.md %}
