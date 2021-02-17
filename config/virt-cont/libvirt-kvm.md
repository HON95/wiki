---
title: libvirt & KVM
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

libvirt is a tool for managing platform virtualization like KVM and QEMU (among others).
I'll only focus on using it with KVM (and QEMU) here.

Using **Debian**.

## General

- Requires Intel VT or AMD-V to be enabled to function optimally.
- Note that running commands as non-root or not in the libvirt group will generally work but will not show all VMs. etc.
- KVM was merged into the Linux kernel mainline in kernel version 2.6.20.

## Installation

1. Install without extra stuff (like GUIs): `apt-get install --no-install-recommends iptables bridge-utils qemu-system qemu-utils libvirt-clients libvirt-daemon-system virtinst libosinfo-bin`
1. (Optional) Install `dnsmasq-base` for accessing guests using their hostnames.
1. (Optional) Add users to the `libvirt` group to allow them to manage libvirt without sudo.
1. Set up the default network:
    1. It's already created, using NAT, DNS and DHCP.
    1. If not using dnsmasq, disable DNS and DHCP:
        1. Open the config: `virsh net-edit default`
        1. Disable DNS: Set `<dns enable='no'/>`.
        1. Disable DHCP: Remove `<dhcp>...</dhcp>`.
        1. Restart libvirtd.
    1. Start it: `virsh net-start default`
    1. (Optional) Autostart it: `virsh net-autostart default`
1. Set up the default storage pool:
    1. Create it: `virsh pool-define-as default --type=dir --target=/var/lib/libvirt/images`
    1. Start it: `virsh pool-start default`
    1. Autostart it: `virsh pool-autostart default`

## Usage

### General

- Use `LIBVIRT_DEFAULT_URI=qemu:///system` to explicitly use the system URI (rarely needed).
- Show version: `virsh version`

### Manage VMs

- Show VMs: `virsh list --all`
- Show VM details: `virsh dominfo <vm>`
- Start/shutdown/reboot/kill VM: `virsh {start | shutdown | reboot | kill} <vm>`
- Suspend/resume VM: `virsh {suspend | resume} <vm>`
- Enter/exit console for VM:
    - Enter: `virsh console <vm>`
    - Exit: `Ctrl+]` (US) or `Ctrl+¨` (NO)
- Create VM:
    - Example: `virt-install --name=example-vm --os-variant=debian10 --ram=$((1*1024)) --vcpus=1 --disk=path=/var/lib/libvirt/images/example-vm.qcow2,bus=virtio,size=5 --network=network=default,model=virtio --graphics=none --extra-args="console=ttyS0" --location=debian-10.7.0-amd64-netinst.iso`
    - The disk path should match a storage pool path.
    - Show available OS variants: `osinfo-query os`
    - To disable various checks, specify `--check=all=off`.
    - To use a host bridge instead of a libvirt network, specify `--network=bridge=something` instead of `--network=network=something`.
    - To avoid opening a console (or waiting if there is no console), specify `--noautoconsole` to avoid that.
    - If it "can't find the kernel" when using `--location`, use `--cdrom` instead. This disallows using arguments like `--extra-args`, so you'll need to find another console.
    - Make sure the ISO is readable by the QEMU user.
    - To install using a VNC screen instead of console (e.g. if you need richer graphics or when using `--cdrom` and no console is allocated), replace `--graphics=none` with `--noautoconsole --graphics=vnc,password=<password>`. It only binds to localhost by default, so use something like SSH port forwarding (`ssh -L 5900:127.0.0.1:5900 <user>@<addr>`) to access it remotely. Remember to disable it in the VM config when no longer needed.
- Clone VM:
    1. Create a source/template VM and make sure it's not running.
    1. Clone it: `virt-clone --original=<source-vm> --name=<vm> -f <vm>.qcow2`
- Remove VM: `virsh undefine <vm>`
- Set VM to automatically start (or disable it): `virsh autostart [--disable] <vm>`
- Edit VM config:
    1. Open tmp. config in editor: `virsh edit <vm>`
    1. Shutdown and start the VM (rebooting it doesn't work).
- Show VM config: `virsh dumpxml <vm>`
- Show VM graphics URI: `virsh domdisplay <vm>`
    - For VNC, the shown port is offset from port 5900.
- Run QEMU monitor command: `qemu-monitor-command <vm> --hmp <command>`
- Show VM logs: See log dir `/var/log/libvirt/qemu/`.

### Networking

- The default network interface is `virbr0`, called `default` in libvirt.
- Show networks: `virsh net-list`
- Show network config: `virsh net-dumpxml <network>`
- Edit network config (without applying it): `virsh net-edit <network>`
- Apply changed network config: Restart libvirt or reboot the system.
- Create bridge connected to physical NIC:
    - Note: If you're connected remotely, try to avoid locking yourself out.
    - Create bridge on the host: See [BridgeNetworkConnections (Debian Wiki)](https://wiki.debian.org/BridgeNetworkConnections) or something.

### Storage

- Effectively, the pool is a directory while the files in it (typically disk images) are the volumes.
- Pool basics:
    - Show pools: `virsh pool-list [--all] [--details]`
- Volume basics:
    - Show volumes: `virsh list-vol <pool> [--details]`
    - Show volume info: `virsh vol-info <file>`
- Resize disk: `qemu-img resize <file> <size-change>` (e.g. +1G)
- Cold backup of VM:
    - Make sure the VM is stopped so that the disk image is consistent.
    - Backup the image in `/var/lib/libvirt/images/`.
    - Backup the config in `/etc/libvirt/qemu/`.

### Snapshots

- The current snapshot means the last one.
- List snapshots for a VM: `virsh snapshot-list <vm>`
- Show snapshot info: `virsh snapshot-info --domain=<vm> [--current]`
- Create snapshot: `virsh snapshot-create-as --domain=<vm> --name=<snapshot> --description=<description>`
- Revert a snapshot:
    1. Stop the VM.
    1. Revert a named or the current snapshot: `virsh snapshot-revert {--domain=<vm> | --current} --snapshotname=<snapshot> [--running]`

### Tuning

- Assign more CPU cores. When adding many, attempt to assign every hyperthreaded twin to the same VM.
- **TODO**: Cache mode write-through and write-back.
- Consider enabling huge pages.
- Consider using memory ballooning to save memory on the host when the VM doesn't need it.

### Miscellanea

- To repair a corrupted QEMU disk, try using `guestfish`.

{% include footer.md %}
