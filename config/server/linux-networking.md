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
    - Only one instance is required on the network, but multiple may be used for redundancy.
    - A master SM is selected based on configured priority, with GUID as a tie breaker.
1. Setup IPoIB:
    - Just like for Ethernet. Just specify the IB interface as the L2 device.
    - Use an appropriate MTU like 2044.
1. Make sure ping and ping-pong is working (see examples below).

### Usage

- Show IPoIB status: `ip a`
- Show local devices:
    - GUIDs: `ibv_devices`
    - Basics (1): `ibstatus`
    - Basics (2): `ibstat`
    - Basics (3): `ibv_devinfo`
- Show link statuses for network: `iblinkinfo`
- Show subnet nodes:
    - Hosts: `ibhosts`
    - Switches: `ibswitches`
    - Routers: `ibrouters`
- Show active subnet manager(s): `sminfo`
- Show subnet topology: `ibnetdiscover`
- Show port counters: `perfquery`

#### Testing

- Ping:
    - Server: `ibping -S`
    - Client: `ibping -G <guid>`
- Ping-pong:
    - Server: `ibv_rc_pingpong -d <device> [-n <iters>]`
    - Client: `ibv_rc_pingpong [-n <iters>] <ip>`
- Other tools:
    - qperf
    - perftest
- Diagnose with ibutils:
    - Requires the `ibutils` package.
    - Diagnose fabric: `ibdiagnet -ls 10 -lw 4x` (example)
    - Diagnose path between two nodes: `ibdiagpath -l 65,1` (example)

{% include footer.md %}
