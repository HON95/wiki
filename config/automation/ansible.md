---
title: Ansible
breadcrumbs:
- title: Configuration
- title: Automation
---
{% include header.md %}

## Ad Hoc Usage

- Run module for host: `ansible all -i <host>, -m <module> [-a <module-arg>]`
    - The comma after the host is required to treat it as a host list literal instead of an inventory file name.
    - Use `-i localhost, --connection=local` to run locally.
- Get facts (with optional filter): `ansible all -i <host>, -m setup -a 'filter=ansible_os_*'` (example fact filter)

## Playbooks

- Basic: `ansible-playbook <playbook>`
- Specify inventory file: `ansible-playbook -i <hosts> <playbook>`
- Limit which groups/hosts to use (comma-separated): `ansible-playbook -l <group|host> <playbook>`
- Limit which tasks to run using tags (comma-separated): `ansible-playbook -t <tag> <playbook>`

## Vault

- Use file for password: Just add the password as the only line in a file.
- Encrypt, prompt for secret, using password file: `ansible-vault encrypt_string --vault-password-file ~/.ansible_vault/stuff`

## Configuration

Example `/etc/ansible/ansible.cfg` or `~/.ansible.cfg`:

```
[defaults]
# Change to "auto" if this path causes problems
interpreter_python = /usr/bin/python3
host_key_checking = false
```

{% include footer.md %}
