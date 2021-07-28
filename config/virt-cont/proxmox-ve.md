---
title: Proxmox VE
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

Using **Proxmox VE 6**.

## Host

### Installation

1. Find a mouse.
    - Just a keyboard is not enough.
    - You don't need the mouse too often, though, so you can hot-swap between the keyboard and mouse during the install.
1. Download PVE and boot from the installation medium (in UEFI mode if supported, otherwise BIOS is fine).
1. Storage:
    - Use 1-2 mirrored SSDs with ZFS.
    - (ZFS) enable compression and checksums and set the correct ashift for the SSD(s). If in doubt, use ashift=12.
1. Localization:
    - (Nothing special.)
1. Administrator user:
    - Set a root password. It should be different from your personal password.
    - Set the email to "root@localhost" or something. It's not important before actually setting up email.
1. Network:
    - (Nothing special.)

### Initial Configuration

Follow the instructions for [Debian](/config/linux-server/debian/), but with the following changes:

1. Before installing updates, setup the PVE repos (assuming no subscription):
    1. Comment out all content from `/etc/apt/sources.list.d/pve-enterprise.list` to disable the enterprise repo.
    1. Create `/etc/apt/sources.list.d/pve-no-subscription.list` containing `deb http://download.proxmox.com/debian/pve buster pve-no-subscription` to enable the no-subscription repo.
    1. More info: [Proxmox VE: Package Repositories](https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo)
1. Don't install any of the firmware packages, it will remove the PVE firmware packages.
1. Update network config and hostname:
    1. Do NOT manually modify the configs for network, DNS, NTP, firewall, etc. as specified in the Debian guide.
    1. (Optional) Install `ifupdown2` to enable live network reloading. This does not work if using OVS interfaces.
    1. Update network config: Use the web GUI.
    1. (Optional) Update hostname: See the Debian guide. Note that the short and FQDN hostnames must resolve to the IPv4 and IPv6 management address to avoid breaking the GUI.
1. Update MOTD:
    1. Disable the special PVE banner: `systemctl disable --now pvebanner.service`
    1. Clear or update `/etc/issue` and `/etc/motd`.
    1. (Optional) Set up dynamic MOTD: See the Debian guide.
1. Setup firewall:
    1. Open an SSH session, as this will prevent full lock-out.
    1. Go to the datacenter firewall page.
    1. Enable the datacenter firewall.
    1. Add incoming rules on the management network for NDP (ipv6-icmp), ping (macro ping), SSH (tcp 22) and the web GUI (tcp 8006).
    1. Go to the host firewall page.
    1. Enable the host firewall (TODO disable and re-enable to make sure).
    1. Disable NDP on the nodes. (This is because of a vulnerability in Proxmox where it autoconfigures itself on all bridges.)
    1. Enable TCP flags filter to block illegal TCP flag combinations.
    1. Make sure ping, SSH and the web GUI is working both for IPv4 and IPv6.
1. Set up storage:
    1. Docs: [Storage (Proxmox VE)](https://pve.proxmox.com/wiki/Storage)
    1. Create a ZFS pool or something and add it to `/etc/pve/storage.cfg`.
    1. Setup backup pruning:
        - [Backup and Restore (Proxmox VE)](https://pve.proxmox.com/wiki/Backup_and_Restore)
        - [Prune Simulator (Proxmox BS)](https://pbs.proxmox.com/docs/prune-simulator/)

### Configure PCI(e) Passthrough

**Possibly outdated**

- Guide: [Proxmox VE: Pci passthrough](https://pve.proxmox.com/wiki/Pci_passthrough)
- Requires support for  IOMMU, IOMMU interrupt remapping, and for dome PCI devices, UEFI support
- Only 4 devices are are supported
- For graphics cards, additional steps are required
- Setup BIOS/UEFI features:
    - Enable UEFI
    - Enable VT-d and SR-IOV Global Enable
    - Disable I/OAT
- Enable SR-IOT for NICs in BIOS/ROM
- Enable IOMMU: Add `intel_iommu=on` to GRUB command line (edit `/etc/default/grub` and add to line `GRUB_CMDLINE_LINUX_DEFAULT`) and run `update-grub`
- Enable modules: Add `vfio vfio_iommu_type1 vfio_pci vfio_virqfd pci_stub` (newline-separated) to `/etc/modules` and run `update-initramfs -u -k all`
- Reboot
- Test for IOMMU interrupt remapping: Run `dmesg | grep ecap` and check if the last character of the `ecap` value is 8, 9, a, b, c, d, e, or an f. Also, run `dmesg | grep vfio` to check for - errors. If it is not supported, set `options vfio_iommu_type1 allow_unsafe_interrupts=1` in `/etc/modules`, which also makes the host vulnerable to interrupt injection attacks.
- Test NIC SR-IOV support: `lspci -s <NIC_BDF> -vvv | grep -i "Single Root I/O Virtualization"`
- List PCI devices: `lspci`
- List PCI devices and their IOMMU groups: `find /sys/kernel/iommu_groups/ -type l`
- A device with all of its functions can be added by removing the function suffix of the path
- Add PCIe device to VM:
    - Add `machine: q35` to the config
- Add `hostpci<n>: <pci-path>,pcie=1,driver=vfio` to the config for every device
- Test if the VM can see the PCI card: Run `qm monitor <vm-id>`, then `info pci` inside

### Troubleshooting

**Failed login:**

Make sure `/etc/hosts` contains both the IPv4 and IPv6 addresses for the management networks.

## Cluster

### Usage

- The cluster file system (`/etc/pve`) will get synchronized across all nodes, meaning quorum rules applies to it.
- The storage configiration (`storage.cfg`) is shared by all cluster nodes, as part of `/etc/pve`. This means all nodes must have the same storage configuration.
- Show cluster status: `pvecm status`
- Show HA status: `ha-manager status`

### Creating a Cluster

1. Setup an internal and preferrably isolated management network for the cluster.
1. Create the cluster on one of the nodes: `pvecm create <name>`

### Joining a Cluster

1. Add each other host to each host's hostfile using shortnames and internal management addresses.
1. If firewalling NDP, make sure it's allowed for the internam management network. This must be fixed BEFORE joining the cluster to avoid loss of quorum.
1. Join the cluster on the other hosts: `pvecm add <name>`
1. Check the status: `pvecm status`
1. If a node with the same IP address has been part of the cluster before, run `pvecm updatecerts` to update its SSH fingerprint to prevent any SSH errors.

### Leaving a Cluster

This is the recommended method to remove a node from a cluster. The removed node must never come back online and must be reinstalled.

1. Back up the node to be removed.
1. Log into another node in the cluster.
1. Run `pvecm nodes` to find the ID or name of the node to remove.
1. Power off the node to be removed.
1. Run `pvecm nodes` again to check that the node disappeared. If not, wait and try again.
1. Run `pvecm delnode <name>` to remove the node.
1. Check `pvevm status` to make sure everything is okay.
1. (Optional) Remove the node from the hostfiles of the other nodes.

### High Availability Info

See: [Proxmox: High Availability](https://pve.proxmox.com/wiki/High_Availability)

- Requires a cluster of at least 3 nodes.
- Requires shared storage.
- Provides live migration.
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

### Troubleshooting

**Unable to modify because of lost quorum:**

If you lost quorum because if connection problems and need to modify something (e.g. to fix the connection problems), run `pvecm expected 1` to set the expected quorum to 1.

## VMs

### Usage

- List: `qm list`

### General Setup

The "Cloud-Init" notes can be ignored if you're not using Cloud-Init. See the separate section below first if you are.

- Generally:
    - Use VirtIO if the guest OS supports it, since it provices a paravirtualized interface instead of an emulated physical interface.
- General tab:
    - Use start/shutdown order if som VMs depend on other VMs (like virtualized routers).
      0 is first, unspecified is last. Shutdown follows reverse order.
      For equal order, the VMID in is used in ascending order.
- OS tab:
    - If installing from an ISO, specify it here.
    - (Cloud-Init) Don't use any media (no ISO).
- System tab:
    - Graphics card: Use the default. If you want SPICE, you can change to that later.
    - Qemu Agent: It provides more information about the guest and allows PVE to perform some actions more intelligently,
      but requires the guest to run the agent.
    - BIOS/UEFI: BIOS w/ SeaBIOS is generally fine, but I prefer UEFI w/ OVMF (for PCIe pass-through support and stuff), assuming your OS/setup doesn't require one or the other.
        - (Cloud-Init) Prepared Cloud-Init images may typically be using UEFI (and containing an EFI partition), so you probably need to use UEFI.
        - About the EFI disk: Using UEFI in PVE typically requires a "EFI disk" (in the hardware tab). This is not the EFI system partition (ESP) and is not visible to the VM, but is used by PVE/OVMF to store the EFIVARS, which contains the boot order. (If a UEFI VM fails to boot, you may need to enter the UEFI/OVMF menu through the remote console to fix the boot entries.)
    - Machine: Intel 440FX is generally fine, but I prefer Q35 (for PCIe pass-through support and stuff).
    - SCSI controller: VirtIO SCSI.
- Hard disk tab:
    - (Cloud-Init) This doesn't matter, you're going to replace it afterwards with the imported Cloud-Init-ready qcow2 image. Just add something temporary since it can't be skipped.
    - Bus/device: Use the SCSI bus with the VirtIO SCSI controller selected in the system tab (it supersedes the VirtIO Block controller).
    - Cache:
        - Use write-back for max performance with reduced safety in case of power loss (recommended).
        - Use none for balanced performance and safety with better *write* performance.
        - Use write-through for balanced performance and safety with better *read* performance.
        - Direct-sync and write-through can be fast for SAN/HW-RAID, but slow if using qcow2.
    - Discard: When using thin-provisioning storage for the disk and a TRIM-enabled guest OS,
      this option will relay guest TRIM commands to the storage so it may shrink the disk image.
      The guest OS may require SSD emulation to be enabled.
    - SSD emulation: This just presents the drive as an SSD instead of as an HDD. It's typically not needed.
    - IO thread: If the VirtIO SCSI single controller is used (which uses one controller per disk),
      this will create one I/O thread for each controller for maximum performance.
      This is generally not needed if not doing IO-heavy stuff with multiple disks in the VM.
- CPU tab:
    - CPU type: Generally, use "kvm64".
      For HA, use "kvm64" or similar (since the new host must support the same CPU flags).
      For maximum performance on one node or HA with same-CPU nodes, use "host".
    - NUMA: Enable for NUMA systems. Set the socket count equal to the numbre of NUMA nodes.
    - CPU limit: Aka CPU quota. Floating-point number where 1.0 is equivalent to 100% of *one* CPU core.
    - CPU units: Aka CPU shares/weight. Processing priority, higher is higher priority.
    - See the documentation for the various CPU flags (especially the ones related to Meltdown/Spectre).
- Memory tab:
    - Ballooning: Enable it.
      It allows the guest OS to release memory back to the host when the host is running low on it.
      For Linux, it uses the "balloon" kernel driver in the guest, which will swap out processes or start the OOM killer if needed.
      For Windows, it must be added manually and may incur a slowdown of the guest.
- Network tab:
    - Model: Use VirtIO.
    - Firewall: Enable if the guest does not provide one itself, or if you don't want it to immediately become accessible from the network during/after installation (i.e. before you've provisioned it properly).
    - Multiqueue: When using VirtUO, it can be set to the total CPU cores of the VM for increased performance.
      It will increase the CPU load, so only use it for VMs that need to handle a high amount of connections.
- Start the VM:
    - (Cloud-Init) Don't start it yet, go back to the Cloud-Init section.
    - Open a graphical console to show what's going on.
    - See the separate sections below for more specific stuff.

### Linux Setup (Manual)

1. Setup the VM (see the general setup section).
1. (Recommended) Setup the QEMU guest agent: See the section about it.
1. (Optional) Setup SPICE (for better graphics): See the section about it.
1. More detailed Debian setup: [Debian](/config/linux-server/debian/)

### Linux Setup (Cloud-Init)

*Using Debian 10.*

1. Download a cloud-init-ready Linux image to the hypervisor:
    - Debian: [Debian Official Cloud Images](https://cloud.debian.org/images/cloud/) (the `genericcloud` variant and `qcow2` format)
    - Copy the download link and download it to the host (`wget <url>`).
1. Note: It is an UEFI installation (so the BIOS/UEFI mode must be set accordingly) and the image contains an EFI partition (so you don't need a separate EFI disk).
1. Setup a VM as in the general setup section (take note of the specified Cloud-Init notes).
    1. Set the VM up as UEFI with an "EFI disk" added.
    1. Add a serial interface since the GUI console may be broken (it is for me).
1. Setup the prepared disk:
    1. (GUI) Completely remove the disk from the VM ("detach" then "remove").
    1. Import the downloaded cloud-init-ready image as the system disk: `qm importdisk <vmid> <image-file> <storage>`
    1. (GUI) Find the unused disk for the VM, edit it (see the general notes), and add it.
    1. (GUI) Resize the disk to the desired size. Note that it can be expanded further at a later time, but not shrunk. 10GB is typically file.
    1. (GUI) Make sure the disk (e.g. `scsi0`) is added in "boot order" in the options tab. Others may be removed.
1. Setup initial Cloud-Init disk:
    1. (GUI) Add a "CloudInit drive".
    1. (GUI) In the Cloud-Init tab, set a temporary user and password and set the IP config to DHCPv4 and DHCPv6/SLAAC, such that you can boot the template and install stuff. (You can wipe these settings later to prepare it for templating.)
1. Start the VM and open its console.
    1. The NoVNC console is broken for me for these VMs for some reason, so use the serial interface you added instead if NoVNC isn't working (`qm terminal <vmid>`).
1. Fix boot order:
    1. It may fail to boot into Linux and instead drop you into a UEFI shell (`Shell>`). Skip this if it actually boots.
    1. Run `reset` and prepare to press/spam `Esc` when it resets so that it drops you into the UEFI menu.
    1. Enter "Boot Maintenance Manager" and "Boot Options", then delete all options except the harddisk one (no PXE or DVD-ROM). Commit.
    1. Press "continue" so that is attempts to boot using the new boot order. It should boot into Linux.
    1. (Optional) Try logging in (using Cloud-Init credentials), power it off (so the QEMU VM completely stops), and power it on again to check that the boot order is still working.
1. Log in and configure basic stuff:
    1. Log in using the Cloud-Init credentials. The hostname should automatically have been set to the VM name, as an indication that the initial Cloud-Init setup succeeded.
    1. Setup basics like installing `qemu-guest-agent`.
1. Wipe temporary Cloud-Init setup:
    1. (VM) Run `cloud-init clean`, so that it reruns the initial setup on the next boot.
    1. (GUI) Remove all settings in the Cloud-Init tab (or set appropriate defaults).
1. (Optional) Create a template of the VM:
    - Rename it as e.g. `<something>-template` and treat is as a template, but don't bother converting it to an actual template (which prevents you from changing it later).
    - If you made it a template then clone it and use the clone for the steps below.
1. Prepare the new VM:
    - Manually: Setup Cloud-Init in the Cloud-Init tab and start it. Start it, log in using the Cloud-Init credentials and configure it.
    - Ansible: See the `proxmox` and `proxmox_kvm` modules.
    - Consider purging the cloud-init package to avoid accidental reconfiguration later.
    - Consider running `cloud-init status --wait` before configuring it to make sure the Cloud-Init setup has completed.

### Windows Setup

*Using Windows 10.*

[Proxmox VE Wiki: Windows 10 guest best practices](https://pve.proxmox.com/wiki/Windows_10_guest_best_practices)

#### Before Installation

1. Setup the VM (see the general setup section).
1. Add the VirtIO drivers ISO: [Fedora Docs: Creating Windows virtual machines using virtIO drivers](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads)
1. Add it as a CDROM using IDE device 3.

### During Installation

1. (Optional) Select "I din't have a product key" if you don't have a product key.
1. In the advanced storage section:
    1. Install storage driver: Open drivers disc dir `vioscsi\w10\amd64` and install "Red Hat VirtIO SCSI pass-through controller".
    1. Install network driver: Open drivers disc dir `NetKVM\w10\amd64` and install "Redhat VirtIO Ethernet Adapter".
    1. Install memory ballooning driver: Open drivers disc dir `Balloon\w10\amd64` and install "VirtIO Balloon Driver".

#### After Installation

1. Install QEMU guest agent:
    1. Open the Device Manager and find "PCI Simple Communications Controller".
    1. Click "Update driver" and select drivers disc dir `vioserial\w10\amd64`
    1. Open drivers disc dir `guest-agent` and install `qemu-ga-x86_64.msi`.
1. Install drivers and services: 
    1. Download `virtio-win-gt-x64.msi` (see the wiki for the link).
    1. (Optional) Deselect "Qxl" and "Spice" if you don't plan to use SPICE.
1. Install SPICE guest agent:
    1. **TODO** Find out if this is included in `virtio-win-gt-x64.msi`.
    1. Download and install `spice-guest-tools` from spice-space.org.
    1. Set the display type in PVE to "SPICE".
1. For SPICE audio, add an `ich9-intel-hda` audio device.
1. Restart the VM.
1. Install missing drivers:
    1. Open the Device Manager and look for missing drivers.
    1. Click "Update driver", "Browse my computer for driver software" and select the drivers disc with "Include subfolders" checked.

### QEMU Guest Agent Setup

[Proxmox VE Wiki: Qemu-guest-agent](https://pve.proxmox.com/wiki/Qemu-guest-agent)

The QEMU guest agent provides more info about the VM to PVE, allows proper shutdown from PVE and allows PVE to freeze the guest file system when making backups.

1. Activate the "QEMU Guest Agent" option for the VM in Proxmox and restart if it wasn't already activated.
1. Install the guest agent:
    - Linux: `apt install qemu-guest-agent`
    - Windows: See [Windows Setup](#windows-setup).
1. Restart the VM from PVE (not from within the VM).
    - Alternatively, shut it down from inside the VM and then start it from PVE.

### SPICE Setup

[Proxmox VE Wiki: SPICE](https://pve.proxmox.com/wiki/SPICE)

SPICE allows interacting with graphical VM desktop environments, including support for keyboard, mouse, audio and video.

1. Install a SPICE compatible viewer on your client:
    - Linux: `virt-viewer`
1. Install the guest agent:
    - Linux: `spice-vdagent`
    - Windows: See [Windows Setup](#windows-setup).
1. In the VM hardware configuration, set the display to SPICE.

### Troubleshooting

**VM failed to start, possibly after migration:**

Check the host system logs. It may for instance be due to hardware changes or storage that's no longre available after migration.

## Firewall

- PVE uses three different/overlapping firewalls:
    - Cluster: Applies to all hosts/nodes in the cluster/datacenter.
    - Host: Applies to all nodes/hosts and overrides the cluster rules.
    - VM: Applies to VM (and CT) firewalls.
- To enable the firewall for nodes, both the cluster and host firewall options must be enabled.
- To enable the firewall for VMs, both the VM option and the option for individual interfaces must be enabled.
- The firewall is pretty pre-configured for most basic stuff, like connection tracking and management network access.
- Host NDP problem:
    - For hosts, there is a vulnerability where the hosts autoconfigures itself for IPv6 on all bridges (see [Bug 1251 - Security issue: IPv6 autoconfiguration on Bridge-Interfaces ](https://bugzilla.proxmox.com/show_bug.cgi?id=1251)).
    - Even though you firewall off management traffic to the host, the host may still use the "other" networks as default gateways, which will cause routing issues for IPv6.
    - To partially fix this, disable NDP on all nodes and add a rule allowing protocol "ipv6-icmp" on trusted interfaces.
    - To verify that it's working, reboot and check its IPv6 routes and neighbors.
- Check firewall status: `pve-firewall status`

### Special Aliases and IP Sets

- Alias `localnet` (cluster):
    - For allowing cluster and management access (Corosync, API, SSH).
    - Automatically detected and defined for the management network (one of them), but can be overridden at cluster level.
    - Check: `pve-firewall localnet`
- IP set `cluster_network` (cluster):
    - Consists of all cluster hosts.
- IP set `management` (cluster):
    - For management access to hosts.
    - Includes `cluster_network`.
    - If you want to handle management firewalling elsewhere/differently, just ignore this and add appropriate rules directly.
- IP set `blacklist` (cluster):
    - For blocking traffic to hosts and VMs.

### PVE Ports

- TCP 22: SSH.
- TCP 3128: SPICE proxy.
- TCP 5900-5999: VNC web console.
- TCP 8006: Web interface.
- TCP 60000-60050: Live migration (internal).
- UDP 111: rpcbind (optional).
- UDP 5404-5405: Corosync (internal).

## Storage

### Ceph

See [Storage: Ceph](/config/linux-server/storage/#ceph) for general notes.
The notes below are PVE-specific.

#### Notes

- It's recommended to use a high-bandwidth SAN/management network within the cluster for Ceph traffic.
  It may be the same as used for out-of-band PVE cluster management traffic.
- When used with PVE, the configuration is stored in the cluster-synchronized PVE config dir.

#### Setup

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

### Troubleshooting

**"Cannot remove image, a guest with VMID '100' exists!" when trying to remove unused VM disk**:

- Make sure it's not mounted to the VM.
- Make sure it's not listed as an "unused disk" for the VM.
- Run `qm rescan --vmid <vmid>` and check the steps above.

{% include footer.md %}
