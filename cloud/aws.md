---
title: AWS
breadcrumbs:
- title: Cloud
---
{% include header.md %}

## General

- Note that almost everything is tied to some availability zone, so make sure your active zone is the correct one before making any changes.

## Networking (VPC etc.)

### Security Groups

- Remember to setup IPv6 rules too (typically mirroring the IPv4 ones).
- Typical DMZ setup: Allow everything from everywhere.
- Typical non-DMZ setup: Allow ICMPv4, ICMPv6 and SSH from everywhere.

### Add IPv6 Support

1. Add an IPv6 prefix to the VPC:
    1. Find the VPC.
    1. Enter the "edit CIDRs" config page.
    1. Add an Amazon-managed IPv6 prefix.
1. Add a default gateway for the new prefix:
    1. Enter the "routing tables" page and find the table associated with the VPC.
    1. Click "edit routes".
    1. Add a new route with destination `::/0` and the same internet gateway as for the IPv4 default route as the target.
1. Create a subnet from the IPv6 prefix:
    1. Enter the "subnets" page.
    1. (Optional) Delete the existing IPv4-only subnets (not possible if any resources are using them).
    1. Create a new dual-stack subnet for the VPC, with no name (optional), the same availability zone as the VM/resource to use it with. Select some IPv4 subnet (e.g. the first `/24`) and IPv6 subnet (e.g. add `00` to the templated subnet) from the VPC prefixes.

## EC2

### General

### Networking

- **Warning:** The primary network interface of a VM can't be changed after creation. Likewise, the "subnet" of an existing network interface can't be changed. Make sure you assign the VM to the correct subnet (or network interface) during creation. (Required e.g. if you want IPv6 support.)
- For IPv6 support, see the warning above.

{% include footer.md %}
