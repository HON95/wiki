---
title: Ubiquiti UniFi Access Points
breadcrumbs:
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Ubiquiti UniFi Controllers](/config/network/ubiquiti-unifi-controllers/)

### Using
{:.no_toc}

- AP AC Lite
- AP AC LR

## General

- PoE info: [UniFi: Supported PoE Protocols](https://help.ubnt.com/hc/en-us/articles/115000263008--UniFi-Understanding-PoE-and-How-UniFi-Devices-are-Powered)
- Adoption methods: [UniFi: Device Adoption Methods for Remote UniFi Controllers](https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Device-Adoption-Methods-for-Remote-UniFi-Controllers)
    - The DHCP option is typically the most appropriate IMO.
- Reset: Hold RESET button until the front light alternate between black, white and blue.
- Default credentials (after RESET and before adoption): Username `ubnt` with password `ubnt`.
- IPv6 management: It does not seem to support SLAAC or DHCPv6 (**TODO** Needs re-testing.).
- **TODO** Does it apply settings to all APs in an ESS simultaneously such that the whole ESS goes down?

## Settings

- 2.4GHz & 5GHz:
    - Generally use both 2.4GHz and 5GHz with the same SSID and password.
    - Consider disabling 2.4GHz if it may cause interference or may suffer from bad scaling due to fewer channels (e.g. at LAN parties).
    - IoT devices typically support only 2.4GHz (which is appropriate due to low data rates and good range).
- "Legacy Support" (802.11b): Only enable old versions if you really need to, as their low bandwidths and old protocols may clutter the same spectrum as the newer, efficient verions are also using.
- "L2 Isolation" (client isolation): Enable if clients don't need to communicate with eachother. This may increase performance (less broadcasting/multicasting) and security (assuming the network is also firewalled from outside).
- Roaming:
    - Roaming (of clients between APs) requires that the APs use/provide the same SSID, password and subnet.
    - **TODO** "Enable Fast Roaming" (802.11r)?
- Security:
    - WPA-2 (personal): Fine for small networks with a _secret_ password. Anyone _with the password/PSK_ can easily sniff traffic from other clients by de-authing them and sniffing the handshake, so this doesn't provide any benefits if the password is public.
    - WPA-3 (personal): Like WPA-2 but newer and more secure (better initial key exchange and provides forward secrecy). Only newer devices support it.
    - WPA-2/WPA-3 (personal): The most appropriate for "personal" setups, with v2 for compatibility and v3 for better security for devices supporting it. **TODO** PMF optional if transitional (WPA2+3)?
    - WPA-2 enterprise and WPA-3 enterprise: You'll already know if you need this.
- "WiFi AI": For automatically moving APs to less interfering channels. Probably bad, but I haven't tested it yet (**TODO**).
- "Guest Policy": For client isolation and captive portal. Does not support IPv6. May cause communication to fail after connecting to the AP. (**TODO** This was converted into "L2 Isolation" and "Guest Hotspot" in newer versions?)
- "High Performance Devices": Forces some clients onto the 5GHz band. May cause the connection establishment to to fail.
- "Multicast Enhancement": **TODO** This broke my printer, I think. Needs re-testing.
- "Airtime Fairness": Generally keep it enabled, esp. if many clients. It prevents devices (esp. those using old/slow 802.11 variants) from hogging bandwidth and starving other clients.
- "Auto-Optimize Network": Always keep disabled to prevent it from changing your settings in bad ways.

## Wireless Uplink (Meshing)

- Old firmware versions can be buggy wrt. wireless uplinks and can cause L2 loops.
- The APs can be adopted wirelessly if one of them is connected to the network.
- APs that are adopted wirelessly are will automatically allow meshing to other APs while APs that are adopted while wired will not. This can be changed in the AP settings.
- Disable wireless uplinks (meshing) if not used:
    - (Alternative 1) Disable per site: Go to site settings and disable "uplink connectivity monitor".
    - (Alternative 2) Disable per AP: Go to AP settings, "wireless uplinks" and disable everything.

{% include footer.md %}
