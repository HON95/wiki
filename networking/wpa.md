---
title: Wi-Fi Protected Access (WPA)
breadcrumbs:
- title: Network
---
{% include header.md %}

## TODO

- WPA3 stuff:
    - Uses simultaneous authentication of equals (SAE) instead of pre-shared key (PSK). SAE is a password-authenticated key agreement method based on the Diffie–Hellman key exchange, providing increased security and forward secrecy. It avoids the WPA2 Personal KRACK vulnerability which allowed offline password cracking if the initial handshake was captured. It has however been found to be imperfect by Mathy Vanhoef (author of the KRACK attack) and Eyal Ronen.
    - Modes: Personal, Enterprise, Enhanced Open
    - Personal and Enterprise is just like for WPA2, but with improved WPA3 security.
    - Enhanced Open is new, opportunistic wireless encryption (OWE) for passwordless WLANs. This prevents snooping, as is trivially doable for WPA2 open WLANs.

{% include footer.md %}
