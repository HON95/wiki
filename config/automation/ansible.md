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

### Vault

- Used to encrypt files and values. For values, just paste the `!vault ...` output directly into the configs to use the encrypted value in.
- Use file to keep password: Just add the password as the only line in a file, e.g. `~/.ansible_vault/<name>` (with appropriate parent dir perms). A generated `[a-zA-Z0-9]{32}` string is more than strong enough.
- Encrypt, prompt for secret, using password file: `ansible-vault encrypt_string --vault-password-file=~/.ansible_vault/stuff`
- Use password file with playbook: `ansible-playbook --vault-password-file=<file> <...>`
- To avoid leaking secrets in logs and stuff, use `no_log` in tasks handling secrets.

## Configuration

Config locations:

- Global: `/etc/ansible/ansible.cfg`
- User: `~/.ansible.cfg`
- Project: `ansible.cfg`

Example config:

```
[defaults]
host_key_checking = false
#interpreter_python = auto
interpreter_python = /usr/bin/python3
#inventory = hosts.ini
#roles_path = ansible-roles:~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
```

## Templating

- YAML files:
    - Conditionals and stuff tend to mess up indentation. Specify `#jinja2: trim_blocks:False` to avoid that. This will also make the output a little uglier with empty lines in place of unsatisfied conditionals and stuff though.

## Troubleshooting

### Ansible Freezes when Connecting

Probably caused by a password-protected SSH key. Add `--private-key=<keyfile>` to specify which SSH key to use or `--private-key=/dev/null` to avoid using any SSH key.

{% include footer.md %}
