---
title: 802.1X/dot1x & EAP
breadcrumbs:
- title: Network
---
{% include header.md %}

## TODO

- WPA Enterprise w/o provider certificate validation is unsafe?
- PEAP encapsulates inner authentication method, e.e. EAP-MSCHAPv2, using e.g. TLS.
- MS-CHAPv2 is old and uses DES.
- Both PEAP and MS-CHAPv2 provide mutual authentication and don't transmit the password in plaintext.
- EAP-TLS requires the client device to have both the provider cert and a provider-provided client cert (with private key).
- PEAPv0 with EAP-MSCHAPv2 without CA cert validation = bad and crackable.

{% include footer.md %}
