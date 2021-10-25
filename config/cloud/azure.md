---
title: Azure
breadcrumbs:
- title: Configuration
- title: Cloud
---
{% include header.md %}

## Virtual Machines Setup

### Networking

- For IPv6 support, you apparently need to create a new VM.
- You're forced to use NAT (with an internal network conneted to the VM) both for IPv4 and IPv6 (which is just disgusting).
- Some guides may tell you that you need to create a load balancer in order to add IPv6 to VMs, but that's avoidable.
- ICMPv6 is completely broken. You can't ping over IPv6, path MTU discovery (PMTUD) is broken, etc. Broken PMTUD can be avoided by simply setting the link MTU from 1500 to 1280 (the minimum for IPv6).
- The default ifupdown network config (which uses DHCP for v4 and v6) broke IPv6 connectivity for me after a while for some reason. Switching to systemd-networkd with DHCP and disabling Ifupdown (comment out everything in `/etc/network/interfaces` and mask `ifup@eth0.service`) solved this for me.
- If you configure non-Azure DNS servers in the VM config, it will seemingly only add one of the configured servers to `/etc/resolv.conf`. **TODO** It stops overriding `/etc/resolv.conf` if using Azure DNS servers?
- Adding IPv6 to VM:
    1. Note: This was written afterwards, I may be forgetting some steps.
    1. Create an IPv4 address and an IPv6 address.
    1. In the virtual network for the VM, add a ULA IPv6 address space (e.g. an `fdXX:XXXX:XXXX::/48`). Then modify the existing subnet (e.g. `default`), tick the "Add IPv6 address space" box and add a /64 subnet from the address space you just added.
    1. In the network interface for the VM, configure the primary config to use the private IPv4 subnet and the public IPv4 address. Add a new secondary config for for the IPv6 (private) ULA subnet and the (public) GUA.

{% include footer.md %}
