---
title: Ansible
breadcrumbs:
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
- Override: `ANSIBLE_CONFIG=ansible.cfg`
    - Required for Windows project configs due to "world-writable config".

Example config:

```ini
[defaults]
host_key_checking = false
executable = /bin/bash
#interpreter_python = auto
interpreter_python = /usr/bin/python3
#inventory = hosts.ini
#roles_path = ansible-roles:~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
```

## Templating

### YAML Files

- Indented conditionals/loops (tags) might mess up indentation for the next line. Either avoid indenting Ansible tags or specify `#jinja2: trim_blocks:False` at the top of the file to avoid removing the newline after a block.

#### ipaddr Filter

- There currently exists three versions, [`ipaddr`](https://docs.ansible.com/ansible/2.4/playbooks_filters_ipaddr.html) (deprecated), [`ansible.netcommon.ipaddr`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters_ipaddr.html) (deprecated) and [`ansible.utils.ipaddr`](https://docs.ansible.com/ansible/latest/collections/ansible/utils/docsite/filters_ipaddr.html).
- The filter takes either a single value or a list of values. For single value input, it returns false if the input is invalid. For list input, it filters out any invalid input elements.
- Common, basic usage:
    - Normal usage: {% raw %}`{{ some_address | ansible.utils.ipaddr('address') }}`{% endraw %}
    - Filter IPv4 or IPv6 addresses: `ansible.utils.ipv4` and `ansible.utils.ipv6`
    - Get address without length: `ansible.utils.ipaddr('address')`
    - Get address with length: `ansible.utils.ipaddr('host')`
    - Get address with length (alternative): `ansible.utils.ipaddr('address/prefix')`
    - Get network without length: `ansible.utils.ipaddr('network')`
    - Get network with length: `ansible.utils.ipaddr('subnet')`
    - Get prefix length: `ansible.utils.ipaddr('prefix')`
    - Get netmask: `ansible.utils.ipaddr('netmask')`
    - Get broadcast address: `ansible.utils.ipv4 | ansible.utils.ipaddr('broadcast')`
    - Get addresses count: `ansible.utils.ipaddr('size')`
    - Get indexed address with length: `ansible.utils.ipaddr('net') | ansible.utils.ipaddr(1)` (`-1` for last address)
    - Get the other address for a P2P link without length: `ansible.utils.ipaddr('peer')`
    - Convert IPv4 to IPv6 (IPv4-mapped): `ansible.utils.ipv4('ipv6')`
    - Filter MAC addresses: `ansible.utils.hwaddr`

## Examples

**Combine key-value pairs to string:**

{% raw %}
```yaml
vars:
  qm_params:
    name: "{{ vm.name }}"
    description: "{{ vm.description | default('') }}"
  qm_params_string: "{{ vm_config.items() | map('join', '=') | map('regex_replace', '^([^=]*)=(.*)$', '--\\1=\"\\2\"') | join(' ') }}"
```
{% endraw %}

## Troubleshooting

### Ansible Freezes when Connecting

Probably caused by a password-protected SSH key. Add `--private-key=<keyfile>` to specify which SSH key to use or `--private-key=/dev/null` to avoid using any SSH key.

{% include footer.md %}
