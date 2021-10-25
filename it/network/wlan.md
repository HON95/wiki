---
title: WLAN Theory
breadcrumbs:
- title: IT
- title: Network
---
{% include header.md %}

## Specifications

### Wi-Fi

|Standard|Name|Frequency (GHz)|Bandwidth|Modulation|
|-|-|-|-|-|
|802.11b||2.4|22|DSSS|
|802.11a||5|5/10/20|OFDM|
|802.11g||2.4|5/10/20|OFDM|
|802.11n|Wi-Fi 4|2.4 + 5|20/40|MIMO-OFDM|
|802.11ac|Wi-Fi 5|5|20/40/80/160|MIMO-OFDM|
|802.11ax|Wi-Fi 6|1-6 (ISM)|20/40/80/80+80|MIMO-OFDM|

### Not Wi-Fi

|Standard|Name|Bands (GHz)|Bandwidth (MHz)|Modulation|
|-|-|-|-|-|
|802.11||2.4|22|DSSS/FHSS|
|802.11ad|WiGig (gen 1)|60|2,160|OFDM|

## Channel Planning

- Always perform a survey before to identify internal and external existing WLANs and RF interference (on all relevant bands).
- RF radiation is weird:
    - It bounces on stuff and interferes with itself, so it's not always "closer gives better signal".
    - Windows (not the OS) may block some frequencies.
    - Changes in the physical environment (e.g. crowds) may cause changes in the WLAN coverage.
    - It may be very different for 2.4GHz and 5GHz.
- Generally avoid using automatic channel selection as it typically sucks. Plan manually.
- Don't set stations' transmit power too high.
    - Other associated stations' max transmit power may be much lower, causing asymmetric connections. They may still roam to them from a more appropriate BSS, though, since the problem is not apparent until after associated.
    - It increases interference with other stations may contribute to the hidden and exposed node problems.
    - It may overheat the device.
    - It may violate regulations.
- Use wider channel bands for better bandwidth (duh) if you can afford the band width usage and know there doesn't exist interference within the chosen band.
- 5GHz has way more channels than 2.4GHz. 2.4GHz in the US (the de facto standard) only has three non-overlapping channels (1, 6, and 11). 2.4GHz in certain countries like Norway has four non-overlapping channels (1, 5, 9 and 13).
- Disable 2.4GHz if you're not going to use it as it interferes with more stuff than 5GHz. Cheap IoT-stuff still uses only 2.4GHz though, so you may want a 2.4GHz IoT WLAN. Users with modern equipment can typically be pushed onto 5GHz only.

## Other

- If you don't need them, disable legacy protocols (such as 802.11 a, b and g). Legacy devices take up too much time when accessing the medium.
- If you don't need it, disable broadcast from LAN to WLAN. WLAN is semi-duplex and using a single collision domain (similar to an Ethernet hub, not a switch), so useless broadcasts will temporarily cripple the whole channel.
- If stations don't need to communicate between themselves, enable client isolation (whatever your WLAN solution calls it). This avoids unnecessary broadcast/multicast traffic and frees up the channel.
- Certain 5GHz channels are subject to dynamic frequency selection (DFS). This means that they will try to avoid interfering with RADAR signals and in practice that it will take some extra time before WLANs on these channels to come up after a reconfiguration.

{% include footer.md %}
