---
title: Interconnects
breadcrumbs:
- title: Configuration
- title: High-Performance Computing (HPC)
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Linux Switching & Routing](/config/network/linux/)

## General

- The technology should implement RDMA, such that the CPU is not involved in transferring data between hosts (a form of zero-copy). CPU involvement would generally increase latency, increase jitter and limit bandwidth, as well as making the CPU processing power less available to other processing. This implies that the network card must be intelligent/smart and implement hardware offloading for the protocol.
- The technology should provide a rich communication interface to (userland) applications. The interface should not involve the kernel as unnecessary buffering and context switches would again lead to increased latency, increased jitter, limited bandwidth and excessive CPU usage. Instead of using the TCP/IP stack on top of the interconnect, Infiniband and RoCE (for example) provides "verbs" that the application uses to communicate with applications over the interconnect.
- The technology should support one-sided communication.
- OpenFabrics Enterprise Distribution (OFED) is a unified stack for supporting IB, RoCE and iWARP in a unified set of interfaces called the OpenFabrics Interfaces (OFI) to applications. Libfabric is the user-space API.
- UCX is another unifying stack somewhat similar to OFED. Its UCP API is equivalent to OFED's Libfabric API.

## Ethernet

### Info

- More appropriate for commodify clusters due to Ethernet NICs and switches being available off-the-shelf for lower prices.
- Support for RoCE (RDMA) is recommended to avoid overhead from the kernel TCP/IP stack (as is typically used wrt. Ethernet).
- Ethernet-based interconnects include commodity/plain Ethernet, Internet Wide-Area RDMA Protocol (iWARP), Virtual Protocol Interconnect (VPI) (Infiniband and Ethernet on same card), and RDMA over Converged Ethernet (RoCE) (Infiniband running over Ethernet).

## RDMA Over Converged Ethernet (RoCE)

### Info

- Link layer is Converged Ethernet (CE) (aka data center bridging (DCB)), but the upper protocols are Infiniband (IB).
- v1 uses an IB network layer and is limited to a single broadcast domain, but v2 uses a UDP/IP network layer (and somewhat transport layer) and is routable over IP routers. Both use an IB transport layer.
- RoCE requires the NICs and switches to support it.
- It performs very similar to Infiniband, given equal hardware.

## InfiniBand

### Info

- Each physical connection uses a specified number of links/lanes (typically x4), such that the throughput is aggregated.
- Per-lane throughput:
    - SDR: 2Gb/s
    - DDR: 4Gb/s
    - QDR: 8Gb/s
    - FDR10: 10Gb/s
    - FDR: 13.64Gb/s
    - EDR: 25Gb/s
    - HDR: 50Gb/s
    - NDR: 100Gb/s
    - XDR: 250Gb/s
- The network adapter is called a host channel adapter (HCA).
- It's typically switches, but supports routing between subnets as well.
- Channel endpoints between applications a called queue pairs (QPs).
- To avoid invoking the kernel when communicating over a channel, the kernel allocates and pins a memory region that the userland application and the HCA can both access without further kernel involvement. A local key is used by the application to access the HCA buffers and an unencrypted remote key is used by the remote host to access the HCA buffers.
- Communication uses either channel semantics (the send/receive model, two-sided) or memory semantics (RDMA model, one-sided). It also supports a special type of memory semantics using atomic operations, which is a useful foundation for e.g. distributed locks.
- Each subnet requires a subnet manager to be running on a switch or a host, which manages the subnet and is queryable by hosts (agents). For very large subnets, it may be appropriate to run it on a dedicated host. It assigns addresses to endpoints, manages routing tables and more.

### Installation (Debian)

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

## NVLink & NVSwitch

See [CUDA](/se/general/cuda/).

{% include footer.md %}
