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

## Planning & Implementation

- Always perform a survey before to identify internal and external existing WLANs and RF interference.
- Windows may block relevant frequencies.
- Don't set stations' transmit power too high.
    - Other associated stations' max transmit power may be much lower, causing asymmetric connections. They may still roam to them from a more appropriate BSS, though, since the problem is not apparent until after associated.
    - It increases interference with other stations may contribute to the hidden and exposed node problems.
    - It may overheat the device.
    - It may violate regulations.
- Disable legcy protocols (such as 802.11 a, b and g). Legacy devices take up too much time when accessing the medium.
- Move as many devices as possible to the 5GHz band. Try to reserve the 2.4GHz band for legacy/simple and distant devices.
- The 2.4GHz (ISM) band is more susceptible to interference since the frequency is used by e.g. Bluetooth and microwave ovens.
- Changes in the physical environment may cause changes in the WLAN coverage.

{% include footer.md %}
