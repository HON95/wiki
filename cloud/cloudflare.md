---
title: Cloudflare
breadcrumbs:
- title: Cloud
---
{% include header.md %}

Mostly a list of how I like things in Cloudflare, for the very few features I use.

## DNS Hosting

- Plan: Free
- DNS:
    - DNSSEC: Yes (no multi-signer)
- Boilerplate records (using zone "example.net"):
        - `CNAME @ "mario.example.net"` (where the main site is hosted)
        - `CNAME www "mario.example.net"` (for redirect til non-www)
        - `TXT @ "v=spf1 include:_spf.google.com ~all"` (including Google-mail, remove `include:` if not used)
        - `TXT * "v=spf1 ~all"` (avoid mail from random subdomains)
        - `TXT _dmarc "v=DMARC1; p=quarantine; pct=100;"`

## HTTP Reverse Proxy

- DNS proxy status (traffic through Cloudflare):
    - Enabled for most HTTP/HTTPS sites that behave properly and I want better cached performance and extra security for (e.g. main site).
- SSL/TLS:
    - Mode: Full (strict) (with exception through page rules)
    - Always use HTTPS: Yes
    - HSTS: On, no max-age, don't include subdomains, preload.
    - Minimum TLS version: 1.2
    - Origin certificates: Create for websites served through Cloudflare. Or just use Let's Encrypt (requires a non-HTTPS page rule for HTTP challenge).
    - Authenticated Origin Pulls: Yes. Must be configured on the hosting webserver too to prevent direct connections.
- Security:
    - Security level: Low or Medium (default)
- Caching:
    - Boilerplate rules (example sites):
        - "No cache (example.net)" (if the main site doesn't like caching, disable it):
            - When: `hostname equals "example.net"`
            - Then: Bypass cache.
- Rules:
    - Normalization type: Cloudflare (default)
    - Normalize incoming URLs: True (default)
    - Boilerplate rules (example sites):
        - "ACME Flexible SSL" (configuration rule):
            - When: `URI Path starts with "/.well-known/acme-challenge/"`
            - Then: SSL mode Flexible.
        - "Remove WWW" (redirect rule):
            - When: `Hostname equals "www.example.net"`
            - Then: Dynamic, `concat("https://example.net", http.request.uri.path)`, 301 (permanent), preserve query string.
        - "Redirect to other site" (redirect rule) (if this domain doesn't have its own main site):
            - When: `Hostname equals "example.example"`
            - Then: Static, `https://example.net)`, 303 (temporary).
- Network:
    - Websockets: On
    - gRPC: On

{% include footer.md %}
