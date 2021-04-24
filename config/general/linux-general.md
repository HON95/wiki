---
title: Linux General Notes
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Resources

### Security

- [Linux Hardening Checklist](https://github.com/trimstray/linux-hardening-checklist)
- [The Practical Linux Hardening Guide](https://github.com/trimstray/the-practical-linux-hardening-guide)

## Distros

### Debian/Ubuntu

- Nobody user and group: `nobody:nogroup`
- List of default groups: (SystemGroups (Debian Wiki))[https://wiki.debian.org/SystemGroups#Other_System_Groups]
- Release info file: `/etc/debian_version`

### RHEL/CentOS

- Nobody user and group: `nobody:nobody`
- Release info file: `/etc/redhat-release` or `/etc/centos-release`

## Miscellaneous

- `urandom` VS `random`: `random` blocks when running out of entropy while `urandom` does not. For all practical purposes, `urandom` will almost never be *less random* than `random` and `random` may block at inappropriate times, so always use `urandom`.

{% include footer.md %}
