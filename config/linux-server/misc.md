---
title: Linux Server Miscellaneous
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

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
  </tbody>
</table>

## random VS urandom

`random` blocks when running out of entropy while `urandom` does not. Use `random` for creating keys etc. and urandom for everything else.

{% include footer.md %}
