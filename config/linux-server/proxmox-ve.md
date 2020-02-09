---
title: Proxmox VE
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

### Using
{:.no_toc}

- Proxmox VE 6

## Initial Setup

**TODO**

1. See [Debian Server: Initial Setup](../debian-server/#initial-setup).
    - **TODO**: Differences.
1. Setup the PVE repos (assuming no subscription):
    - In `/etc/apt/sources.list.d/pve-enterprise.list`, comment out the Enterprise repo.
    - In `/etc/apt/sources.list`, add the PVE No-Subscription repo. See [Package Repositories](https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo).
    - Update the package index.
1. Disable the console MOTD:
    - Disable `pvebanner.service`.
    - Clear or update `/etc/issue` (e.g. use use the logo).
1. Disable IPv6 NDP (**TODO** Move to Debian?):
    - It's enabled on all bridges by default, meaning the node may become accessible to untrusted bridged networks even when no IPv4 or IPv6 addresses are specified.
    - **TODO**
    - Reboot (now or later) and make sure there's no unexpected neighbors (`ip -6 n`).

### Setup SPICE Console

1. In the VM hardware configuration, set the display to SPICE.
1. Install the guest agent:
    - Linux: `spice-vdagent`
    - Windows: `spice-guest-tools`
1. Install a SPICE compatible viewer on your client:
    - Linux: `virt-viewer`

## Cluster

- `/etc/pve` will get synchronized across all nodes.
- High availability:
    - Clusters must be explicitly configured for HA.
    - Provides live migration.
    - Requires shared storage (e.h. Ceph).

### Simple Setup

1. Setup a management network for the cluster.
    - Either isolated or firewalled with internet access.
1. Setup each node.
1. Add each other host to each host's hostfile.
    - So that IP addresses can be more easily changed.
    - Use short hostnames, not FQDNs.
1. Create the cluster on one of the nodes: `pvecm create <name>`
1. Join the cluster on the other hosts: `pvecm add <name>`
1. Check the status: `pvecm status`

### High Availability Setup

## Ceph

{% include footer.md %}
