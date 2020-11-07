---
title: Email Theory
breadcrumbs:
- title: IT
- title: Services
---
{% include header.md %}

## Terminology

- Mail user agent (MUA): Client app for sending messages to an MSA and retrieving messages from an MDA.
- Mail submission agent (MSA): Server for receiving messages from a MUA and handing them over to an MTA.
- Mail delivery agent (MDA): Server for receiving messages from MTAs and storing them until a MUA retrieves them.
- Mail transfer agent (MTA): Server for transferring messages from MSAs to MDAs.
- (Extended) Simple Mail Transfer Protocol (SMTP/ESMTP): Protocol for sending messages.
- Post Office Protocol v3 (POP3) and Internet Message Access Protocol (IMAP): Protocols for retrieving messages.
- Multipurpose Internet Mail Extensions (MIME): Encoding for message contents.

## Common Mailbox Names

Based on [RFC 2142](https://tools.ietf.org/html/rfc2142).
Does not include useless ones.

- `abuse`: Inappropriate public behavior.
- `noc`: Network infrastructure operations.
- `security`: Security incidents and info.
- `support`: General customer service.
- `postmaster`: SMTP.
- `hostmaster`: DNS.
- `webmaster`: HTTP.
- `info`: Marketing and info.
- `marketing`: Marketing.
- `sales`: Sales.

## Security

- Transport Layer Security (TLS):
    - For encrypting the transport.
    - Explicit or using Opportunistic TLS (STARTTLS).
- STARTTLS:
    - Opportunistic TLS: Upgrades a non-encrypted connection to en encrypted one if possible.
    - Weak to the STRIPTLS attack via a MITM attack when not using DANE.
    - DANE (a part of DNSSEC) allows setting a DNS TLSA record which tells the clients to require TLS.
- Sender Policy Framework (SPF):
    - Specifies which IP addresses are allowed to send messages from the the `MAIL FROM` domain.
    - The record is distrubuted using a DNS TXT record with the same domain name.
    - Helps prevent email spoofing when used with DMARC.
    - Don't specify or include (recursively) more than 10 IP addresses as only 10 will be used.
    - When used with DMARC, the signing domain for one of the signatures must match the `From:` domain according to the DMARC alignment mode.
    - SPF records are not inherited by subdomains. They're only applied at the exact level.
    - Example TXT record: `v=spf1 mx include:example.net ~all`
        - `mx`: Allow sending from MX records for the same domain.
        - `include:example.net`: Include SFP records from the specified domain.
        - `~all`: `all` matches other IP addresses. `~` marks them as SOFTFAIL, `-` marks them as FAIL.
- DomainKeys Identified Mail (DKIM):
    - Digitally signs messages using a key specified by a signing domain and a selector.
    - Must be supported by the sender.
    - Helps prevent email spoofing when used with DMARC.
    - There may be several DKIM signatures for a message.
    - The signing domain need not be the same as the `From:` domain.
    - The public key is distributed as a DNS TXT record for the subdomain `<selector>._domainkey.<domain>`.
    - The sender decides which parts of the message is signed, typically the body and some default headers.
    - When used with DMARC, the `MAIL FROM` domain must match the `From:` domain according to the SPF alignment mode.
    - Example TXT record: `k=rsa; p=<pubkey>`
- Domain-based Message Authentication, Reporting and Conformance (DMARC):
    - Tells the receiver how it should handle SPF and DKIM.
    - The record is distributed using a DNS TXT record using the `_dmarc` subdomain directly below the `From:` domain.
    - The alignment mode specifies how the `From:` domain must match the domain name from DKIM and SPF individually.
        - Strict: They must match exactly.
        - Relaxed: The Organizational Domains for both domains must match.
    - Example TXT record: `v=DMARC1; adkim=r; aspf=r; p=quarantine; sp=quarantine; pct=100; rua=mailto:dmarcreports@example.com;`
        - `p`: Policy for the domain.
        - `sp`: Policy for subdomains. Defaults to `p`.
        - `pct`: Percent of bad messages to apply the policy to. Defaults to 100.
        - `rua`: Email address to send aggregate reports to. Optional.
        - `adkim` and `aspf`: Alignment mode for DKIM and SPF. Defaults to relaxed.
- Secure/MIME (S/MIME):
    - End-to-end encryption and signing of MIME data.
    - Based on certificate authorities.
    - The message may contain multiple MIME parts which may be encrypted/signed individually.
    - Currently vulnerable to the EFAIL attack and should generally not be used until fixed.
- Pretty Good Privacy (PGP)/GNU Privacy Guard (GPG):
    - Both PGP and GPG Follow the OpenPGP standard.
    - End-to-end encryption and signing of email messages and other media.
    - Based on web of trust (with public keys bound to a username or an email address),
      but supports CAs as well.
    - Currently vulnerable to the EFAIL attack (when used with email messages) and should generally not be used until fixed.

{% include footer.md %}
