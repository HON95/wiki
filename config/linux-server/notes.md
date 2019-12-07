---
title: Linux Server Notes
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
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

## Distros
<table>
  <thead>
    <tr>
      <th style="text-align:left">Distro</th>
      <th style="text-align:left">RHEL/CentOS</th>
      <th style="text-align:left">Debian/Ubuntu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Nobody user and group</td>
      <td style="text-align:left">nobody:nobody</td>
      <td style="text-align:left">nobody:nogroup</td>
    </tr>
    <tr>
      <td style="text-align:left">Release file(s)</td>
      <td style="text-align:left">
        <p>/etc/redhat-release</p>
        <p>/etc/centos-release</p>
      </td>
      <td style="text-align:left">/etc/debian_version</td>
    </tr>
    <tr>
      <td style="text-align:left"></td>
      <td style="text-align:left"></td>
      <td style="text-align:left"></td>
    </tr>
  </tbody>
</table>

{% include footer.md %}
