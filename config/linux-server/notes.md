---
title: Linux Server Notes
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration
  url: /config/
- title: Linux Server
---
{% include header.md %}

## Resources

- [Cipherli.st](https://cipherli.st/)
- [Linux Hardening Checklist](https://github.com/trimstray/linux-hardening-checklist)
- [The Practical Linux Hardening Guide](https://github.com/trimstray/the-practical-linux-hardening-guide)
- [Text to ASCII Art Generator (TAAG)](http://patorjk.com/software/taag/#p=display&f=Slant&t=)

## Addresses

- Cloudflare DNS:
  - `1.1.1.1`
  - `1.0.0.1`
  - `2606:4700:4700::1111`
  - `2606:4700:4700::1001`
- Justervesenet NTP: `ntp.justervesenet.no`

## Operations and Maintenance

### Updating

Updating should be done manually, but security fixes should be applied automatically if possible.

- APT
  - Autoremove and autoclean
  - `debsums -s`
  - `needrestart`
- Docker services

### Monitoring

- CPU usage
- Available memory
- Free disk space
- ZFS pool statuses
- SMART disk statuses

{% include footer.md %}
