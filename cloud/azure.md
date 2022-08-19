---
title: Azure
breadcrumbs:
- title: Cloud
---
{% include header.md %}

## Virtual Machines

### Creating a VM and Required Resources

Note: This sets up a simple VM (called `Yolo`) in its own resource group and its own resources.

1. Create a resource group (`Yolo-RG`) in the desired region.
    - This will be used by all other resources for the VM.
1. Create a virtual network (`Yolo-VNet`).
    - Press "add IPv6 address space" and add a valid and randomized /48 ULA prefix (e.g. from [here](https://simpledns.plus/private-ipv6)), so you'll get internal address spaces for both IPv4 (/16) and IPv6 (/48).
    - Remove the "default" subnet and add a new "default" containing the first IPv4 /24 and IPv6 /64 subnets from the address spaces. No NAT gateways or service endpoints are needed.
    - No bastion host, DDoS protection or firewall is needed.
1. Create public IP addresses (IPv4 and IPv6) (`Yolo-IPv{4,6}`).
    - Select "both IPv4 and IPv6".
    - Use the "standard" SKU.
    - Use static assignment.
    - Use "Microsoft network" routing preference.
    - Use the "zone-redundant" availability zone.
    - Take note of the allocated IPv4 and IPv6 addresses so you can add it to DNS records.
1. Create a network security group (`Yolo-NSG`).
    - The configuration of this one is _after_ its creation.
    - Add the following inbound rules (depending on the purpose of the VM):
        - (Note) Use source "any", destination "any", source port "any" and action "allow".
        - (Note) The predefined services are a bit dumb, just use custom specifications instead.
        - ICMPv4: Port `*`, protocol ICMP.
        - SSH: Port `22`, protocol TCP.
        - HTTP(S): Port `80,443`, protocol any.
    - Go to the "subnets" tab and associate it with the just-created virtual network and subnet. This will implicitly associate it with NICs in the subnet too (no need to associate NICs explicitly).
1. Create a virtual machine (`Yolo-VM`).
    - Instance availability: Don't require infrastructure redundancy.
    - Instance security: Use standard security.
    - Instance OS: Use your desired OS image, e.g. Debian.
    - Instance type: Use an appropriate size. This might require a bit of research. The B-series is fine for e.g. smaller web hosting servers.
    - Admin account: If you plan on provisioning the server with e.g. Ansible after creation, use an appropriate username and SSH pubkey.
    - Inbound ports: Allow public inbound port SSH. The NSG can be changed later. (**TODO:** )
    - OS disk:
        - Use standard SSD unless you need high IOPS.
        - Use default encryption type (at-rest with platform-managed key).
        - Delete disk with VM.
    - Data disk (if needed):
        - Create a new disk.
        - The auto-generated name is fine IMO.
        - Use the same options as the OS disk, where applicable, except maybe "delete with VM".
    - Network:
        - Use the created virtual network and subnet.
        - Use the created IPv4 address, the created IPv6 address can be added later.
        - Don't use a NIC NSG, the created one is already assigned to the used subnet.
        - Delete NIC when VM is deleted, but don't dfelete IP address when VM is deleted.
        - Don't use load balancing.
    - Monitoring: You choose.
    - Backup:
        - Enable if not using other backup solutions.
        - Create a new recovery services vault (`Yolo-RSV`) within the RG.
        - Use policy subtype "standard".
        - Use the default, new backup policy or create a custom one.
    - Cloud-Init (optional): Add custom data and user data.
1. Fix the NIC:
    - (**TODO**) Was it pointless to select any inbound ports during VM creation when the NSG rules will be applied anyways?
    - Go to the "IP configurations" tab and add a new secondary config for IPv6 named `ipconfig2`, with dynamic assignment and associated with the created public IPv6 address.

### Networking

- You're forced to use NAT (with an internal network conneted to the VM) both for IPv4 and IPv6 (_why?_).
- Some guides may tell you that you need to create a load balancer in order to add IPv6 to VMs, but that's avoidable.
- ICMPv6 is completely broken. You can't ping inbound over IPv6 (outbound works), path MTU discovery (PMTUD) is broken, etc. Broken PMTUD can be avoided by simply setting the link MTU from 1500 to 1280 (the minimum for IPv6).
- The default ifupdown network config (which uses DHCP for v4 and v6) broke IPv6 connectivity for me after a while for some reason. Switching to systemd-networkd with DHCP and disabling Ifupdown (comment out everything in `/etc/network/interfaces` and mask `ifup@eth0.service`) solved this for me.
- If you configure non-Azure DNS servers in the VM config, it will seemingly only add one of the configured servers to `/etc/resolv.conf`. **TODO** It stops overriding `/etc/resolv.conf` if using Azure DNS servers?
- Adding IPv6 to VM:
    1. (Note) This was written afterwards, I may be forgetting some steps.
    1. Create an IPv4 address and an IPv6 address.
    1. In the virtual network for the VM, add a ULA IPv6 address space (e.g. an `fdXX:XXXX:XXXX::/48`). Then modify the existing subnet (e.g. `default`), tick the "Add IPv6 address space" box and add a /64 subnet from the address space you just added.
    1. In the network interface for the VM, configure the primary config to use the private IPv4 subnet and the public IPv4 address. Add a new secondary config for for the IPv6 (private) ULA subnet and the (public) GUA.

{% include footer.md %}
