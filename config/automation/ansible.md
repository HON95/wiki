---
title: Ansible
breadcrumbs:
- title: Configuration
- title: Automation
---
{% include header.md %}

## Usage

### General

- Specify SSH password: `--ask-pass`
- Specify sudo password: `--ask-become-pass`
- Specify username: `--username=<username>`
- Specify SSH key: `--private-key=<key>` (use `/dev/null` to explicitly avoid SSH keys)

### Ad Hoc

- Basic usage: `ansible {all|<target>} -i <inventory> [-m <module>] [-a <module-arg>]`
    - To specify a hostname directly and not use an inventory file, specify `all -i <host>,` (with the comma).
    - To run locally, specift `all -i localhost, --connection=local`.
- Module examples:
    - Ping: `... -m ping`
    - Run command (default module): `... -a <cmd>`
    - Run complicated command (example): `... -a 'bash -c "nvidia-smi > /dev/null"'`
- Get facts (with optional filter): `ansible <...> -m setup -a 'filter=ansible_os_*'` (example fact filter)

### Playbooks

- Basic: `ansible-playbook <playbook>`
- Specify inventory file: `ansible-playbook -i <hosts> <playbook>`
- Limit which groups/hosts to use (comma-separated): `ansible-playbook -l <group|host> <playbook>`
- Limit which tasks to run using tags (comma-separated): `ansible-playbook -t <tag> <playbook>`
- Use Vault password file: `ansible-playbook --vault-password-file <file> <...>`

### Vault

- Use file for password: Just add the password as the only line in a file.
- Encrypt, prompt for secret, using password file: `ansible-vault encrypt_string --vault-password-file ~/.ansible_vault/stuff`
- To avoid leaking secrets in logs and stuff, use `no_log` in tasks handling secrets.

## Configuration

Example `/etc/ansible/ansible.cfg` or `~/.ansible.cfg`:

```
[defaults]
# Change to "auto" if this path causes problems
interpreter_python = /usr/bin/python3
host_key_checking = false
```

## Templating

- YAML files:
    - Conditionals and stuff tend to mess up indentation. Specify `#jinja2: trim_blocks:False` to avoid that. This will also make the output a little uglier with empty lines in place of unsatisfied conditionals and stuff though.

## Troubleshooting

### Ansible Freezes when Connecting

Probably caused by a password-protected SSH key. Add `--private-key=<keyfile>` to specify which SSH key to use or `--private-key=/dev/null` to avoid using any SSH key.

{% include footer.md %}
