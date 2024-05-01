---
title: pfSense
breadcrumbs:
- title: Networking
---
{% include header.md %}

### Using
{:.no_toc}

- pfSense v2

## Initial Setup

### Installation

- Use ZFS for the root device.

### Initial Configuration

1. Connect to the website and finish the wizard.
1. Set upstream DNS and NTP servers.
1. Enable password protection for the console.
1. Add a personal user and disable the admin user.
1. Enable "PowerD" in "hiadaptive" mode to enable power saving while still focusing on performance.
1. Enable AES-NI hardware crypto.
1. Set the correct thermal sensors.
1. Enable RAM disks with e.g. 1024MiB and 4096MiB and e.g. 3 hour backups.
1. Increase network memory buffer size: Add a new system tunable with key `kern.ipc.nmbclusters` and value `1000000`.
1. Disable TCP segmentation offload (TSO) and large receive offload (LRO). Most hardware/drivers have issues with them.
1. See [this page](https://docs.netgate.com/pfsense/en/latest/hardware/tuning-and-troubleshooting-network-cards.html) for NIC-specific tuning.

## Configuration

### FreeRADIUS

#### Basic Setup

1. Install `freeradius3`.
1. Go to the FreeRADIUS settings.
1. Add an interface for authentication: Listen on all interfaces (or only localhost), port 1812, type "authentication", IPv4. Add a separate interface for IPv6.
1. Add an interface for accounting: Listen on all interfaces (or only localhost), port 1813, type "accounting", IPv4. Add a separate interface for IPv6.
1. Add clients/NAS.
1. Add RADIUS users.
1. (Optional) Use FreeRADIUS as an authentication backend.
    1. Create a RADIUS client with client IP address `127.0.0.1`.
    1. Add the RADIUS client in "System/User Manager/Authentication Servers".
    1. **TODO** What's the "RADIUS NAS IP Attribute"?

#### Setup RADIUS as an Authentication Backend

1. Create a RADIUS client with client IP address `127.0.0.1`.
1. Add the RADIUS client in "System/User Manager/Authentication Servers".

#### Setup OTP

1. Make sure the server's time is synchronized, e.g. using NTP.
1. Use the PAP protocol, so that the OTP code can be transmitted along with the password. PAP is not the most secure protocol, but it's fine for running locally, such as when using OpenVPN with RADIUS as the auth backend.
1. Enable OTP support in the RADIUS settings.
1. Enable OTP for each user that should have it:
    1. Clear the user's password. It will no longer be used.
    1. Enable OTP using the Google Authenticator method.
    1. Set/generate a 4-8 digit PIN for the user.
    1. To log in with this user, the supplied password must consist of the PIN concatenated with the OTP code.

#### Notes

- RADIUS should only be used over channels/networks trusted by both/all parties, such as core networks and localhost. It sends the password in plaintext or weak ciphertext. To use it over untrusted channels, use it within a VPN such as IPsec.
- OTP disables/replaces the user's password with the PIN+OTP code. It should only be used with other types of authentication, such as a VPN certificate. Unless the PIN code is made equally strong as an acceptable password.

### ntopng

#### Setup

1. Install `ntopng`.
1. Enable it.
1. Set an admin password. (The username is "admin".)
1. Enable all interfaces to monitor.
1. Update GeoIP data (save first, it reloads the page).
1. New users can be added through the web panel.
1. It uses a bit of storage and processing power, so disable it if it's not being used.

### OpenVPN

#### Setup

1. OpenVPN is built in.
1. Install `openvpn-client-export`.
1. (Recommended) Use RADIUS as the local auth backend. OpenVPN + FreeRADIUS supports authentication with cert. + PIN + TOTP.
1. Use the wizard.
1. Use hardware crypto if you have it.
1. Use server mode with TLS cert. and password.

### Suricata

#### Setup

1. Disable hardware checksum offloading. Suricata doesn't work well with it.
1. Insall `suricata`.
1. Update the rule set manually the first time.
1. Select which rule sets to install. E.g. the ETOpen Emerging Threats (ET) Open which is free and modular.
1. Set the rule update interval. E.g. 6 or 12 hours.
1. Enable "live rule swap on update".
1. Set the "remove blocked host interval". E.g. 15 minutes.
1. Add the WAN interface.
    1. Enable desired logs.
    1. Don't enable "block offenders" (yet).
    1. Set the detect-engine profile appropriately. Use "high" if you have more than 4GB of memory and an okay machine.
1. Enable "resolve flowbits", which allows rules to match based on multiple packets by setting bits on the flow (or something like that).
1. Select which installed rule sets to use.
    1. Description of some ET Open rule sets: [Here](https://doc.emergingthreats.net/bin/view/Main/EmergingFAQ#What_is_the_general_intent_of_ea)
    1. Some rule sets contain a short description at the top of the file.
    1. Only enable rule sets if you know what they do.
    1. Only enable rule sets if you need them.
    1. Some rules produce alerts even for safe traffic.
    1. Some rule sets may be slower than others.
    1. More rules means more processing overhead.
    1. More rules means more problems and debugging.
1. Double all the "memory cap" values. It can fail to start if it runs out of memory.
1. Enable/start the WAN interface.
    1. If it doesn't start, check the error log. If it contains "alloc error" or "pool grow failed", increase "Stream Memory Cap" to e.g. `100663296` (96MiB).
    1. If it failed to start, it may have failed to remove its PID file. Remove it manually if it refuses to restart because of it.
1. Watch for alerts and resolve false alerts by changing and tweaking the settings.
    1. Torrenting is a useful way of load testing.
    1. Try using different applications: Web browsing, games, torrenting, streaming, pinging.
1. Enable "block offenders" when there's no more false alerts, using the desired mode.
    1. Legacy mode copies packets and inspects the copies. It may allow some packets to leak through before blocking.
    1. Inline mode inspects packets before the host network stack. It will affect performance/latency but will not leak, thus making it more secure. It requires support from the NIC driver.
1. Test it by trying to do bad stuff.
    1. Try downloading the EICAR file.
1. (Optional) Add LAN interfaces.

### Unbound

#### Setup

1. Use only the DNS resolver (Unbound), not the older DNS forwarder (dnsmasq).
1. Receive from and transmit to every interface.
1. Use a "transparent" local zone.
1. Enable DNSSEC.
1. Enable forwarding mode if you want to query a set of selected servers instead of the root servers. The selected servers are the ones specified in the system settings. Check that you're not using the DNS servers provided by DHCP, unless you want that for some reason.
1. Use TLS for outgoing queries if using forwarding mode and the selected servers supports it (such as Cloudflare).
1. Don't register DHCP or OpenVPN clients.
1. Enable DNSSEC hardening.
1. Enable DNS rebinding protection in the system settings (enabled by default).

#### Usage

- Add custom A/AAAA records to the host overrides section. The pfSense host is automatically added using its hostname and LAN IP address.

### UPnP/NAT-PMP

- Only use it if a game requires it and the network is trusted. It's generally a vulnerable mechanism.

{% include footer.md %}
