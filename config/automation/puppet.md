---
title: Puppet
breadcrumbs:
- title: Configuration
- title: Automation
---
{% include header.md %}

## General

- Can be run locally or as server-agent.
- The agent daemon must be installed on all managed systems. It checks the server periodically (every 30 minutes by default) to determine if the agent system requires changes.
- Mutual TLS authentication is used between the server and each agent, where the server acts as the CA and agents send CSRs to the server to be manually signed when first configured.
- The "resource abstraction layer" (RAL) handles agent system abstraction and the underlying commands and configurations used.
- The "facter" on the agent gathers agent information ("facts"), which are sent to the server on every run.
- The "catalog" contains all managed resources and the desired state, and is sent from the server to the agent on every run.
- The server decides which classes apply to an agent either using a manifest file (`site.pp`) or using an "external node classifier" (ENC) like Foreman or Enterprise Console.

## Setup (Debian)

### Server

**TODO**: Install, configure, maybe install PuppetDB.

### Client

1. Install: `apt install puppet-agent`
1. Specify server hostname using CLI or in file:
    - CLI method: `puppet config set server <hostname> --section main`
    - File method: In `/etc/puppetlabs/puppet/puppet.conf`, in the `main` section, set `server = <hostname>`.
1. Create TLS cert and connect the agent to the server: `puppet ssl bootstrap`
1. On the server, sign the CSR:
    - Show pending CSRs: `puppet cert --list`
    - Sign the CSR: `puppetserver ca sign --vertname <name>`
1. Re-run the agent: `puppet ssl bootstrap`

### Setup Notes

- Make sure the agents can reach the server over TCP port 8140.
- Use DNS (or static hostnames) for the agents to resolve the address of the server(s).
- Use NTP to avoid TLS issues.
- Consider HA.

## Usage

- Query or modify current state of resource: `puppet resource <type> <id> [attribute=value]*`
- Show resource types: `puppet describe --list`
- Show resource documentation, including supported attributes and parameters: `puppet describe <resource>`
- Apply manifest file: `puppet apply ...`
- Apply code: `puppet apply -e <code>`
- Modules (server):
    - Show all modules: `puppetserver module list`
- Force agent to run now:`puppet agent -t [--noop]`
    - `-t` or `--test` means to run once, in foreground and in verbose mode.
    - `--noop` means to compare catalog but not apply any changes.
- Certificates:
    - (Server) Show all certs: TODO
        - A `+` prefix means signed.
    - (Server) Remove old cert: `puppetserver cert clean <agent-name>`
    - (Agent) Remove existing cert: Find the cert dir using `puppet config print ssldir` and remove everything in it.
- Facter (agent):
    - Show all info: `facter`
    - Show specific info: `facter <info>`

### Puppet DSL and Files

- Declarative. Infrastructure as code (IoC).
- Written in manifest files with `.pp` extension.
- Resource declarations: `<type> { '<title>': <attribute> => '<value>', [...] }`
- Resource declarations may be contained in classes.
- Class definitions: `class <name> { <resource declarations> }`
- Class declarations: `include <class-name>` or `class { '<class-name>': }`
- Classes are contained in modules. Modules with only one class may for instance share a name with the class.
- Module file structure:
    - There exists one or more global "module paths", as shown with `puppet config print modulepath`.
    - Modules are contained in a directory with the module name within the module path.
    - Classes are stored in manifest files inside the `manifests` directory in the module.
    - The base class for the module is stored in `manifests/init.pp`.
- Node definitions:
    - Describes the site.
    - In the manifest file `site.pp` inside the manifest dir. Use `puppet config print manifest` to show the dir.
    - There is a fall-back node name `default` (without quotation marks) if no other node definition matches.
    - Syntax: `node '<node>' { include <class> ... }`
    - For simplicity, use only class declarations in node definitions.

{% include footer.md %}
