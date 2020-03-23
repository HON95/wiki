---
title: Linux General Notes
breadcrumbs:
- title: Configuration
- title: Linux General
---
{% include header.md %}

## Resources

### Security

- [Linux Hardening Checklist](https://github.com/trimstray/linux-hardening-checklist)
- [The Practical Linux Hardening Guide](https://github.com/trimstray/the-practical-linux-hardening-guide)

## Distros

### Debian/Ubuntu

- Nobody user and group: `nobody:nogroup`
- Release info file: `/etc/debian_version`

### RHEL/CentOS

- Nobody user and group: `nobody:nobody`
- Release info file: `/etc/redhat-release` or `/etc/centos-release`

## Miscellaneous

- `urandom` VS `random`: `random` blocks when running out of entropy while `urandom` does not. Use `random` for creating keys etc. and urandom for everything else.

{% include footer.md %}
