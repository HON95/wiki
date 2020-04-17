---
title: General Notes
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Resources

### Security

- [Cipherli.st](https://cipherli.st/)

### Miscellaneous

- [Text to ASCII Art Generator (TAAG)](http://patorjk.com/software/taag/#p=display&f=Slant&t=)

## Addresses

- Cloudflare DNS (1.1.1.1):
    - Notes:
        - Privacy-focused.
        - Supports DNSSEC.
        - Supports DNS over HTTPS and DNS over TLS.
        - Supports malware and adult content blocking.
        - Supports DNS64.
        - Does not allow ANY queries.
        - Upstreams to a locally hosted F root server for privacy and reduced latency.
        - Allows cache purging: [1.1.1.1: Purge Cache](https://1.1.1.1/purge-cache/)
    - Direct:
        - `1.1.1.1`
        - `1.0.0.1`
        - `2606:4700:4700::1111`
        - `2606:4700:4700::1001`
    - Malware blocking:
        - `1.1.1.2`
        - `1.0.0.2`
        - `2606:4700:4700::1112`
        - `2606:4700:4700::1002`
    - Malware and adult content blocking:
        - `1.1.1.3`
        - `1.0.0.3`
        - `2606:4700:4700::1113`
        - `2606:4700:4700::1003`
    - DNS64:
        - `2606:4700:4700::64`
        - `2606:4700:4700::6400`
- Justervesenet NTP (JV-UTC):
    - Info: [Justervesenet: NTP-tenester frå Justervesenet](https://www.justervesenet.no/maleteknikk/tid-og-frekvens/ntp-tjenester-fra-justervesenet/)
    - Address: `ntp.justervesenet.no`

{% include footer.md %}
