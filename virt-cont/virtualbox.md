---
title: VirtualBox
breadcrumbs:
- title: Virtualization, Containerization and Orchestration
---
{% include header.md %}

libvirt is a tool for managing platform virtualization like KVM and QEMU (among others).
I'll only focus on using it with KVM (and QEMU) here.

## General

- Requires Intel VT or AMD-V to be enabled to function optimally.

## Usage

### Storage

- Resize VM disk: `VBoxManage modifyhd <disk>.vdi --resize <size-in-MB>`

{% include footer.md %}
