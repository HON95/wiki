---
title: Network Authentication
breadcrumbs:
- title: Network
---
{% include header.md %}

## General

- Most types of network authentication, where a client authenticates itself to a switch or a wireless access point, uses IEEE 802.1X (aka dot1x) (excluding approaches like e.g. PSK and MACsec).
- Extensible Authentication Protocol (EAP) is generally the framework used for dot1x, using Remote Authentication Dial-In User Service (RADIUS) as the underlying protocol.
- Examples of authentication servers include FreeRADIUS and Cisco ISE, which may use internal client identities or use an upstream identity provider like Active Directory (AD).

### Usage Examples

- **TODO**

## Extensible Authentication Protocol (EAP)

### TODO

- WPA Enterprise w/o provider certificate validation is unsafe? Yes.
- PEAP encapsulates inner authentication method, e.e. EAP-MSCHAPv2, using e.g. TLS.
- MS-CHAPv2 is old and uses DES. Inside PEAP is fine.
- Both PEAP and MS-CHAPv2 provide mutual authentication and don't transmit the password in plaintext.
- EAP-TLS requires the client device to have both the provider cert and a provider-provided client cert (with private key).
- PEAPv0 with EAP-MSCHAPv2 without CA cert validation = bad and crackable.

## Tips and Best Practices

{% include footer.md %}
