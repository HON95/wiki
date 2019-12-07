---
title: Troubleshooting
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
---
{% include header.md %}

Using: Debian 10 Buster

## Problems

- `network-online.target` is stalling during boot:
  - See all services it depends on: `systemctl show -p WantedBy network-online.target`
  - Disable the unused services which stall.
- Firmware for the network card fails to load:
  - Causes a syslog record like "firmware: failed to load rtl\_nic/rtl8168g-3.fw \(-2\)" when trying to up the interface.
  - Might happen after installation even if working initially \(for some reason\).
  - Realtek solution: Enable the "non-free" repo and install "firmware-realtek".
- Perl complains about a locale error:
  - Test with `perl -e exit`. It will complain if there's an error.
  - Check the locale: `locale`
  - Comment `AcceptEnv LANG LC_*` in `/etc/ssh/sshd_config` to prevent clients bringing their own locale.

{% include footer.md %}
