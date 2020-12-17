---
title: Linux Server Networking
breadcrumbs:
- title: Configuration
- title: Server
---
{% include header.md %}

**TODO**:

- Migrate stuff from Debian page.
- Add link to Linux router page. Maybe combine.
- Add ethtool notes from VyOS.

## InfiniBand

### Installation

1. Install RDMA: `apt install rdma-core`
1. Install user-space RDMA stuff: `apt install ibverbs-providers rdmacm-utils infiniband-diags ibverbs-utils`
1. Install subnet manager (SM): `apt install opensm`
    - Only one instance should be required on the subnet.
1. Setup IPoIB:
    - Just like for Ethernet. Just specify the IB interface as the L2 device.
    - Use an appropriate MTU like 2044.
1. Make sure ping and ping-pong is working.

### Usage

- Show IPoIB status: `ip a`
- Show port status: `ibstat`
- Show hosts: `ibhosts`
- Show switches: `ibswitches`
- Show link statuses for network: `iblinkinfo`
- Show active subnet manager(s): `sminfo`

#### Testing

- Ping:
    - Server: `ibping -S`
    - Client: `ibping -G <guid>`
- Ping-pong:
    - Server: `ibv_rc_pingpong`
    - Client: `ibv_rc_pingpong <ip>`
- Other tools:
    - qperf
    - perftest

{% include footer.md %}
