---
title: VirtualBox
breadcrumbs:
- title: Virtualization
---
{% include header.md %}

libvirt is a tool for managing platform virtualization like KVM and QEMU (among others).
I'll only focus on using it with KVM (and QEMU) here.

## Installation

## Arch Linux

1. Enable Intel VT/AMD-V and other virtualization features in hypervisor's BIOS settings.
1. Install stuff: `sudo pacman -S virtualbox virtualbox-host-modules-arch virtualbox-guest-iso`
1. Enable extra network modules: Add `vboxnetadp` annd `vboxnetflt` as lines in `/etc/modules-load.d/vbox.conf`, then update initramfs with `mkinitcpio -P` (unknown if this is required).
1. Give yourself extra permissions: `sudo usermod -aG vboxusers $(whoami)`
1. Disable network range check for created networks: `echo "* 0.0.0.0/0 ::/0" | sudo tee /etc/vbox/networks.conf`

## Usage

### Storage

- Generally use the VDI disk type, unless you need interoperability with other things.
- Resize VM disk: `VBoxManage modifyhd <disk>.vdi --resize <size-in-MB>`

{% include footer.md %}
