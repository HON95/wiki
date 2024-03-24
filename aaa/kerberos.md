---
title: Kerberos
breadcrumbs:
- title: Authentication, Authorization and Accounting (AAA)
---
{% include header.md %}

Kerberos is an authentication system for authenticating (and authorizing?) users or machines over a network of servers and services (similar to single sign-on (SSO)). It's often tightly integrated with LDAP for storing extra information.
It's designed to be run on top of an untrusted network using an appropriate set of security mechanisms (although you'd probably want to avoid that).

## Terminology & Conventions

- _Principal_: Any user, machine and service.
    - Identified using `<principal>@<realm>` (e.g. `user1@EXAMPLE.NET`).
    - The principal is typically the username.
- _Principal instance_: Optional, special versions of existing, normal principals.
    - Identified using `<principal>/<instance>@<realm>` (e.g. `user1/admin@EXAMPLE.NET`).
    - May be used to e.g. access certain services using different credentials or for using different privileges, e.g. for when running scripts in "less trusted" environments.
- _Realm_: An independent realm/domain of principals.
    - Equivalent to an Active Directory domain.
    - Should have upper-case name, typically the DNA domain (e.g. `EXAMPLE.NET`).
- _Key distribution center_ (KDC): A three-part server consisting the principal database, the _authentication server_ (AS) and the _ticket granting server_ (TGS).
    - Each realm has exactly one KDC.
    - The KDCs may be found using special SRV DNS records based on the realm name. They may also simply be configured in the hosts' configuration file.
- _Ticket granting ticket_ (TGT): A ticket issued by the AS to a client after successfully authenticating a user.
    - It's symmetrically encrypted using the user password, which is only known to the user and the KDC.
- _Service ticket_: A ticket granted from the TGS after requested by a client using the TGT.
- Reliability:
    - Kerberos (typically) depends on properly a configured DNS server.
    - As both the DNS server and KDC are essential, you may want to set up high-availability pairs for both.

## Usage

- Authenticate and obtain TGT: `kinit [principal[@<realm>]]`
    - The principal will default to the username of the local user.
    - Specify `KRB5_TRACE=/dev/stderr` to output more info.
- List principal and tickets in cache: `klist`

## Setup

See [FreeIPA](/aaa/freeipa/) (a suite consisting of MIT Kerberos and more).

{% include footer.md %}
