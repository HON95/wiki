---
title: Proxmox VE
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

### Using
{:.no_toc}

- Proxmox VE 6

## Initial Setup

**TODO:**

- Initial setup
- Notes from Google Docs
- `localhost` must resolve to both 127.0.0.1 and ::1 and the domain name must resolve to the mgmt. interface IP addresses (v4+v6).

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

## Cluster

- `/etc/pve` will get synchronized across all nodes.
- High availability:
    - Clusters must be explicitly configured for HA.
    - Provides live migration.
    - Requires shared storage (e.h. Ceph).

### Simple Setup

1. Setup a management network for the cluster.
    - It should generally be isolated.
1. Setup each node.
1. Add each other host to each host's hostfile.
    - So that IP addresses can be more easily changed.
    - Use short hostnames, not FQDNs.
1. Create the cluster on one of the nodes: `pvecm create <name>`
1. Join the cluster on the other hosts: `pvecm add <name>`
1. Check the status: `pvecm status`

### High Availability Info

See: [Proxmox: High Availability](https://pve.proxmox.com/wiki/High_Availability)

- Requires a cluster of at least 3 nodes.
- Configured using HA groups.
- The local resource manager (LRM/"pve-ha-lrm") controls services running on the local node.
- The cluster resource manager (CRM/"pve-ha-crm") communicates with the nodes' LRMs and handles things like migrations and node fencing.
  There's only one master CRM.
- Fencing:
    - Fencing is required to prevent services running on multiple nodes due to communication problems, causes corruption and other problems.
    - Can be provided using watchdog timers (software or hardware), external power switches, network traffic isolation and more.
    - Watchdogs: When a node loses quorum, it doesn't reset the watchdog. When it expires (typically after 60 seconds), the node is killed and restarted.
    - Hardware watchdogs must be explicitly configured.
    - The software watchdog (using the Linux kernel driver "softdog") is used by default and doesn't require any configuretion,
      but it's not as reliable as other solutions as it's running inside the host.
- Services are not migrated from failed nodes until fencing is finished.

## Ceph

See [Storage: Ceph](../storage/#ceph) for general notes.
The notes below are PVE-specific.

### Notes

- It's recommended to use a high-bandwidth SAN/management network within the cluster for Ceph traffic.
  It may be the same as used for out-of-band PVE cluster management traffic.
- When used with PVE, the configuration is stored in the cluster-synchronized PVE config dir.

### Setup

1. Setup a shared network.
    - It should be high-bandwidth and isolated.
    - It can be the same as used for PVE cluster management traffic.
1. Install (all nodes): `pveceph install`
1. Initialize (one node): `pveceph init --network <subnet>`
1. Setup a monitor (all nodes): `pveceph createmon`
1. Check the status: `ceph status`
    - Requires at least one monitor.
1. Add a disk (all nodes, all disks): `pveceph createosd <dev>`
    - If the disks contains any partitions, run `ceph-disk zap <dev>` to clean the disk.
    - Can also be done from the dashboard.
1. Check the disks: `ceph osd tree`
1. Create a pool (PVE dashboard).
    - "Size" is the number of replicas.
    - "Minimum size" is the number of replicas that must be written before the write should be considered done.
    - Use at least size 3 and min. size 2 in production.
    - "Add storage" adds the pool to PVE for disk image and container content.

## VMs

### Initial Setup

- Generally:
    - Use VirtIO if the guest OS supports it, since it provices a paravirtualized interface instead of an emulated physical interface.
- General tab:
    - Use start/shutdown order if som VMs depend on other VMs (like virtualized routers).
      0 is first, unspecified is last. Shutdown follows reverse order.
      For equal order, the VMID in is used in ascending order.
- OS tab: No notes.
- System tab:
    - Graphics card: **TODO** SPICE graphics card?
    - Qemu Agent: It provides more information about the guest and allows PVE to perform some actions more intelligently,
      but requires the guest to run the agent.
    - SCSI controller: Use VirtIO SCSI for Linux and the LSI for Windows.
    - BIOS: Generally use SeaBIOS. Use OVMF (UEFI) if you need PCIe pass-through.
    - Machine: Generally use Intel 440FX. Use Q35 if you need PCIe pass-through.
- Hard disk tab:
    - Bus/device: Use SCSI with the VirtIO SCSI controller selected in the system tab.
      It supersedes the VirtIO Block controller.
    - Cache: Optional, typically using write back.
    - Discard: When using thin-provisioning storage for the disk and a TRIM-enabled guest OS,
      this option will relay guest TRIM commands to the storage so it may shrink the disk image.
      The guest OS may require SSD emulation to be enabled.
    - IO thread: If the VirtIO SCSI single controller is used (which uses one controller per disk),
      this will create one I/O thread for each controller for maximum performance.
- CPU tab:
    - CPU type: Generally, use "kvm64".
      For HA, use "kvm64" or similar (since the new host must support the same CPU flags).
      For maximum performance on one node or HA with same-CPU nodes, use "host".
    - NUMA: Enable for NUMA systems. Set the socket count equal to the numbre of NUMA nodes.
    - CPU limit: Aka CPU quota. Floating-point number where 1.0 is equivalent to 100% of *one* CPU core.
    - CPU units: Aka CPU shares/weight. Processing priority, higher is higher priority.
    - See the documentation for the various CPU flags (especially the ones related to Meltdown/Spectre).
- Memory tab:
    - Ballooning allows the guest OS to release memory back to the host when the host is running low on it.
      For Linux, it uses the "balloon" kernel driver in the guest, which will swap out processes or start the OOM killer if needed.
      For Windows, it must be added manually and may incur a slowdown of the guest.
- Network tab:
    - Model: Use VirtIO.
    - Firewall: Enable if the guest does not provide one itself.
    - Multiqueue: When using VirtUO, it can be set to the total CPU cores of the VM for increased performance.
      It will increase the CPU load, so only use it for VMs that need to handle a high amount of connections.

### Setup SPICE Console

1. In the VM hardware configuration, set the display to SPICE.
1. Install the guest agent:
    - Linux: `spice-vdagent`
    - Windows: `spice-guest-tools`
1. Install a SPICE compatible viewer on your client:
    - Linux: `virt-viewer`

{% include footer.md %}
