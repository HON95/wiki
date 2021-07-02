---
title: Ansible
breadcrumbs:
- title: Configuration
- title: Automation
---
{% include header.md %}

## Resources

### General Networking

- [Ansible network platform options](https://docs.ansible.com/ansible/latest/network/user_guide/platform_index.html)
- [Ansible cli_config module](https://docs.ansible.com/ansible/latest/modules/cli_config_module.html)

### Cisco

- [Ansible IOS platform options](https://docs.ansible.com/ansible/latest/network/user_guide/platform_ios.html)
- [Ansible ios_config module](https://docs.ansible.com/ansible/latest/modules/ios_config_module.html)

## Configuration

Example `/etc/ansible/ansible.cfg`:

```
[defaults]
# Change to "auto" if this path causes problems
interpreter_python = /usr/bin/python3
host_key_checking = false
```

{% include footer.md %}
