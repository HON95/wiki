---
title: Google Workspace
breadcrumbs:
- title: Cloud
---
{% include header.md %}

## Stuff to Remember

Basic stuff to remember to set up for workspaces for personal accounts or tiny businesses.

### Directory

- Add groups for various mail lists:
    - Special groups (for all domains): abuse@domain, postmaster@domain

### Apps

- Calendar:
    - Adjust sharing settings, both under "sharing settings" and "general settings".
- Drive and Docs:
    - Adjust sharing settings.
    - Disable Drive for Desktop?
- Gmail:
    - Setup a catch-all default routing rule: All recipients, add "X-GM" headers, "perform this action only on non-recognized addresses". Add a recipient with "change envelope recipient" to the address it should go to (e.g. "catch-all@example.net"), "suppress bounces from this recipient", add headers (again), prepend custom subject (e.g. "[Catch-All]"). Remember to add the recipient address as an alias to a user or group.
    - Setup mail authentication (DKIM). Copy the record to DNS. (Make sure DMARC and SPF is configured too.)

### Security

- 2-step verification: Enable 2FA enforcement?
- Account recovery: Enable account recovery for superadmin and non-admin user accounts?

### Account

- Admin roles
    - Add extra admin users?
- Domains:
    - Add a primary domain and optional secondary domains.
    - Configure DNS to both receive and send mail from all domains (as part of the wizard to add them).
    - Add SPF and DKIM DNS records for the domains. Make sure the DMARC DNS record is set up properly too.
- Branding:
    - Add a personalization logo. PNG/GIF, 320x132, max 30kB.
