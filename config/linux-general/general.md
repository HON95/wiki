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

| Distro | RHEL/CentOS | Debian/Ubuntu |
| - | - | - |
| Nobody user/group | nobody:nobody | nobody:nogroup |
| Version file(s) | /etc/redhat-release <br /> /etc/centos-release | /etc/debian_version |

## Miscellaneous

- `urandom` VS `random`: `random` blocks when running out of entropy while `urandom` does not. Use `random` for creating keys etc. and urandom for everything else.

{% include footer.md %}
