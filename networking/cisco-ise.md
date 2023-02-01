---
title: Cisco Identity Services Engine (ISE)
breadcrumbs:
- title: Network
---
{% include header.md %}

## Scale

**TODO**

## Nodes

**TODO**

## Certificate Administration

- Certificate types:
    - System certs:  Per node.
    - Trusted certs: CA certs used to trust leaf certs for various uses. Replicated to all nodes.
    - Issued certs: Certs issued by ISE. E.g. for endpoints, ISE messaging and pxGrid services.
- System certs:
    - Leaf certs for ISE nodes and node-associated services. E.g. for admin page, EAP, RADIUS-DTLS, portals, SAML, pxGrid etc.
    - Configured for each node, but certs may for certain services be shared by all nodes if configured properly.
    - May use a single cert for all services or different for all. However, certain services like pxGrid and SAML should have separate certs.
    - pxGrid cert requires both server auth and client auth usages enabled, should therefore use separate cert.
    - The admin cert is used for admin web UI, admin web API, communication between ISE nodes and communication between ISE nodes and external services.
    - Most (all?) system certs should be public CA signed since many of the services are web-based.
    - Changing admin cert causes the ISE node to restart.
- Trusted certs:
    - CA certs used to trust leaf certs for various uses.
    - Replicated to all nodes.
    - When adding new system certs, the upper CA cert should be added as trusted for appropriate services.
    - When adding new nodes with self-signed certs, their certs are automatically added to trusted certs to allow for trusted communication. This does not happen if a cert signed by a trusted cert is already present on the new node.
- Issued certs:
    - Should use a CA cert signed by a trusted enterprise or public CA. Uses a trusted CA cert by default.


{% include footer.md %}
