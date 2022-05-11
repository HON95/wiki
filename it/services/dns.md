---
title: DNS Theory
breadcrumbs:
- title: IT
- title: Services
---
{% include header.md %}

## Resources

- [[RFC 1912] Common DNS Operational and Configuration Errors](https://datatracker.ietf.org/doc/html/rfc1912)

## Basics

Everyone knows this, no point reiterating.

## Special TLDs

- `localhost`: For statically defined domain names pointing to localhost. (RFC 2606)
- `example`: For documentation or examples. (RFC 2606)
- `test`: For testing. (RFC 2606)
- `invalid`: For domain names that should never be valid. (RFC 2626)
- `local`: Used for mDNS and zeroconf. Not available from root servers. (RFC 6762)

## DNSSEC

- Domain Name System Security Extensions (DNSSEC).
- DNSSEC is an extension of DNS for providing CA-style authentication for RRs by cryptographically signing them, thus eliminating DNS poisoning.
- As well as providing authentication and integrity to existing records, it can prove non-existance of non-existing records.
- IANA is the CA for DNSSEC with a single trusted root key.
- Host systems and recursive DNS servers may be configured to validate received RRs for DNSSEC-enabled domains.
- The set of all RRs of the same type for a domain is called an "RRset".
- The presence if a DS record for a child zone signals that the child zone is DNSSEC-enabled.
- The NSEC RR may be used to search for all subdomains and which RRs exist for them (aka zone walking or zone enumeration), so hidden records are no longer possible. NSEC3 with "white lies" and NSEC5 (when supported) prevents this. Blocking NSEC all-together breaks DNSSEC-enabled resolvers, so don't do that.
- A zone's RRsets may be signed in live mode, where the DNSKEY private key is present on the authorative DNS server(s), or in offline mode, where the zone's RRsets are signed in advance and the private key is somewhere safe.
- Due to the size of DNSSEC record types, it makes the DNS server more vulnerable to amplification attacks.

### New Record Types

- DS (delegation signer):
    - Fir bridging the trust from parent zone to child zone.
    - Contains the key tag and hash digest of the DNSKEY of the current zone, as well as the DNSKEY algorithm and hash digest algorithm.
    - Created by the current zone and added to the parent zone where it's signed by the parent.
- DNSKEY:
    - The public key used to verify RRSIGs.
    - Takes the role "key signing key" (KSK), which signs the DNSKEY RRset (including itself), and/or "zone signing key" (ZSK), which signs all other RRsets.
- RRSIG (resource record signature):
    - Signature for an RRset.
- NSEC (next secure record):
    - For returning a signed/authenticated response for non-existing RRs, thus proving its non-existance.
    - NSEC3 and NSEC3PARAM (NSEC v3, NSEC v3 parameters) do the same thing.

{% include footer.md %}
