---
title: Precision Time Protocol (PTP)
breadcrumbs:
- title: Services
---
{% include header.md %}

## Theory

### Basics

- Attempts to compensate for internal delays in the hosts by using hardware timestamping on egress to and ingress from the network, in addition to compensating for network delays.
- Often uses GNSS (GPS, GALILEO, GLONASS etc.) as the source of absolute time.
- Uses a master-slave hierarchy of clocks:
    - Grandmaster clock (GMC): The root timing reference, often fed by GNSS.
    - Orginary clock (OC): Either a master/source or slave/destination of time. Assume slave OCs if not specified, as master OCs are typically denoted as GMCs instead.
    - Boundary clock (BC): Bridges network segments. Uses slave interfaces toward GMCs and master interfaces toward slave OCs.
    - Transparent clock (TC): Similar to BCs. In end-to-end (E2E) or peer-to-peer (P2P) mode. More info later.
- Uses the same epoch as UNIX, i.e. 1970-01-01 00:00:00.
- Supports a one-step and a two-step method, but the two-step method is more widely supported. The "second step" is the follow-up message after the sync message, containing the time when the sync message *actually* entered the wire. In the one-step method, the time is embedded into the sync message itself.
- The synchronization uses a simple, rooted tree. Any redundant paths are blocked, such that each clock receives time from a single slave port. It's basically STP.
- UTC offset:
    - PTP uses International Atomic Time (TAI), while NTP and most applications use Coordinated Univseral Time (UTC).
    - UTC is offset from TAI with an integer number to remain in synchronization with mean solar time.
    - `TAI = UTC + offset`
    - As of 01 Jan 2017, the UTC offset is +37 seconds.
- PTP domains:
    - Domains allow multiple clock distribution systems to share the same communications medium.
    - Domain 0 is the default. Many devices only support the default domain.
- Packet delay variation (PDV):
    - Variation is often due to varying queue depths.
    - Computed constantly, averaged out over time.
- Transport:
    - Ethernet (PTPoE) or IP/UDP.
    - Multicast or unicast, but most often multicast.
    - Typically uses multicast with group 224.0.1.129 (default domain 0). These messages may be forwarded, according to the specific profile.
    - Profiles using peer delay messages use group 224.0.0.107 for specifically those messages. These messages are not forwarded.
    - Time-critical event messages (sync) use UDP port 319, while general messages (announce, management etc.) use port 320. Delay messages are split across both ports according to the profile details.
- Management messages:
    - Used by an external client to monitor PTP clocks.
    - The frames are forwarded inband in the PTP hierarchy, both upward and downward from the clock connected to the management client.
- Intervals/rates of messages:
    - Announce: 1s (power profile), 2s (default profile)
    - Sync: 1s (power and default profiles)
    - Follow-up (two-step method): Triggered by sync
    - Delay request (default profile): 32s (but burst at beginning)
    - Delay response (default profile): Triggered by delay request
    - Peer delay request (power profile): 1s (or 8Hz for 802.1AS)
    - Peer delay response (power profile): Triggered by peer delay request

### Clock Types

- Boundary clocks (BCs):
    - Terminate Sync messages from its master and acts as a master for its slaves. In alternative wording, it *recovers* time from its master and then *regenerates* time to its slaves.
    - Breaks up the PTP message and timing domains.
    - Contains an internal oscillator to maintain time for slaves, between updates from its own master.
    - Allows distributing PTP across VLANs and using different downstream profiles.
    - The messages are generated at outbound ports, meaning different ports may use different profiles.
    - Provides better scaling since the GMC no longer receives delay requests from clocks downstream from the BC.
    - From the perspective of its slaves, it looks like a GMC.
    - Shields slaves from upstream topology changes.
    - Can be chained, but should not have too many in a row from the GMC as they add cumulative error. Use together with TCs.
    - Must be configured appropriately.
- Transparent clocks (TCs):
    - End-to-end (E2E): Available in default profile.
    - Peer-to-peer (P2P): Available in Power and 802.1AS profiles.
    - Most switches default to TC mode. "Nothing" to configure.
    - PTP limited to single VLAN.
    - E2E has scalability issues, should probably use some BCs in the hierarchy. If power utilities, P2P would be mandated.
- E2E TCs:
    - Passes Syncs directly through itself, but measures delays and stuff (adding its residence time) to assist slaves.
    - Listens to Sync messages to update its oscillator to tune its frequency, for more accurate residence time measurements.
    - Passes the PTP through as normal, unrouted data traffic, so it can't cross VLANs and similar.
- Grandmaster clocks (GMCs):
    - Only one GMC per PTP domain, but backups are recommended.
    - Has a connection to an external time source, e.g. GNSS.
- Best Master Clock algorithm (BMCA):
    - Uses Announce messages.
    - Selects a clock according to (from highest priority):
        - Priority 1: User-configurable from 0 to 255, lower value takes precedence. 255 for client-only devices.
        - Class: Related to the source of time, e.g. if using GNSS or (only) an internal oscillator.
        - Accuracy: Accuracy of a clock.
        - Variance: Stability of a clock.
        - Priority 2: Like priority 1.
        - Identity: 8-byte value, typically based on a MAC address. Tie-breaker.
    - Classes (examples):
        - Class 6: Synchronized to primary reference (e.g. GPS). Timescale distribution is PTP.
        - Class 7: Like class 6, but lost synchronization.
        - Class 13/14: Like 6/7, but timescale distribution is ARB.
        - Class 248: Default. Free-running on internal oscillator.
        - Class 255: Client-only devices.
    - Assumes that each clock elects the same GMC each second, assuming they all see the same Announce messages.
    - While the class can typically correctly pick the BMC, it's a good idea to use priority 1 (or priority 2) in addition, to prevent BMC flapping.
- Oscillators:
    - Oven controlled crystal oscillators (OCXOs) are better than temperature compensated crystal oscillators (TCXOs).
    - Keep oscillator quality in mind when choosing GMCs and BC.
    - Good quality oscillators are critical for free-running clocks.
- Primary and backup GMC:
    - A single backup is typically enough.
    - Use a priority 1 of 1 on both GMC candidates. Use a priority 2 of 1 and 2 for the primary and backup, to choose which of the clocks to prefer when both are healthy.
    - Connect the backup GMC to an Ethernet switch at most one bridge hop away from the primary. This yealds lower PDV changes in case of failovers.

### Versions and Amendments

#### PTPv1 (IEEE 1588-2002)

- The initial version, designed to give greater precision than NTP by using GPS.
- The full name is "Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems" (SPCSPNMCS?).
- Used e.g. by older Dante devices.

#### PTPv2 (IEEE 1588-2008)

- Not backwards-compatible with PTPv1.
- Supports multiple profiles, including the _default_ profile which is often referred to as simply "PTPv2".

#### PTPv2.1 (IEEE 1588-2019)

- Includes some backwards-compatible improvements to the 2008 version.

#### IEEE 1588g-2022 (IEEE Std 1588-2019 Amendment)

- Introduces alternative terminology for master and slave.
- New terms:
    - Master: Time transmitter (TT)
    - Slave: Time receiver (TR)
    - Grandmaster: Grandmaster (GM) (unchanged)
    - BMCA: BTCA

#### IEEE 1588e-2024 (IEEE Std 1588-2019 Amendment)

- Identifies structure and content of the IEEE 1588 MIB and YANG modules.

### PTPv2 Profiles

#### Default (IEEE 1588-2008)

- Commonly referred to as simply "PTPv2".
- Used for industrial automation, high-speed trading etc.
- Supports BCs and E2E TCs.
- Supports non-PTP bridging devices in the path, at the cost of added uncertainty.
- Uses UDP over IP (unicast or multicast), which can be routed.
- Example Sync message exchange (using the two-step method):
    1. The master sends a Sync message at global time t1.
    1. The master sends a Follow-Up message containing time t1.
    1. The slave receives the Sync message at local time t2 and then the Follow-Up message a short time after.
    1. The slave updates its local time based on the the local time t2 when the Sync message was received and the global time t1 contained in the Follow-Up. The local time is now updated to global time and has compensated for internal delays in the master, but has not yet compensated for the transmission delay and is running in the past.
    1. The slave sends a Delay-Request message at local time t3.
    1. The master receives the message at global time t4. It responds with a Delay-Response containing time t4.
    1. The slave receives the message containing global time t4. It uses the difference between global time t4 and local time t3 and divides it by two to calculate the offset. It's added to the local time to update it to global time, in sync with the master. Note that the delay measurement only went from slave to master, as the master to slave delay was already implicitly measured before when the Sync was received and when using that delayed local time in the calculation for the two-way delay.
    1. For future Sync and Delay messages, the calculated offset will be updated as a running average and applied immediately after received Sync messages.
- Sync exchanges with E2E TCs:
    - Each TC calculates the path delay (pd) on the received Sync and records the time taken through the TC as the residence time (rt).
    - The TCs add the rt and pd to the Follow-Up message containing the t1. If there were previous TCs, the new rt and pd are summed with the old ones before being added.
    - The slave OC knows the delays from previous hops from the Follow-Up times, but must compute its own last-hop path delay.
- Delay exchanges with E2E TCs:
    - As for Sync messages, the TCs record their residence times (tc) both toward the master (for Delay_Req) and back from the master (for Delay_Resp).
    - The Delay_Req message contains the identifier for the slave OC and a sequence number.

#### Power (IEEE C37.238)

- Used for power utilities and substations.
- Uses L2 multicast.
- <1µs over 16 P2P hops.
- The older version C37.238-2011 is widely supported. The newer version C37-238.2017 is less widely supported.
- Supports BCs and P2P TCs.
- Is heavily P2P-focused and requires all hops to support PTP.
- Supports faster convergence then the default profile in case of topology changes and use of transparent clocks, due to backup P2P TCs being more "ready" than backup E2E TCs.
- Sync and Delay exchanges with P2P TCs:
    - The GMC sends Sync messages to the TCs. No Follow-Ups are sent.
    - Each P2P TC sends their own peer delay messages to the master, so that they maintain their own path delays.
    - When the TCs have calculated the path delay, they add a correction field to forwarded Sync mesages, containing their calculated path delay plus their residence time.
    - When TCs receive delay messages from slave clocks, they answer them directly as if they were master clocks.
    - Calculations:
        - Correction (TC): `pd + rt` (pd toward upstream and local rt)
        - Offset (OC): `(t2 - t1) - pd - correction` (pd toward upstream and received correction)

#### Generalized PTP (gPTP) (802.1AS-2011)

- Used for Audio Video Bridging (AVB) and Time Sensitive Networks (TSN).
- Uses L2 multicast.
- Does not allow non-PTP bridges in the path.
- Implicitly supports P2P TCs (not configurable).

#### Telecom (ITU-T G.8275.1)

- Used for telecom and mobile backhaul.

#### Media (AES67-2015)

- For AES67, Dante and RAVENNA audio, but they typically support the default profile too.
- Used by newer Dante devices, while older ones use PTPv1. Certain Dante devices support both PTP versions, such that they can consume PTPv2 and supply PTPv1 to other devices in the same bridge domain (like a BC).
- A variant of the default profile, with certain chosen parameters (e.g. faster sync messages).

#### SMPTE (SMPTE 2059-2)

- For multimedia.

## Implementations

### Linux PTP

- Supports OC and BC.
- Supports multiple PTPv2 profiles, including default and 802.1AS-2011 (gPTP/AVB).
- Version 4 added support for PTPv2.1 (IEEE 1588-2019). Some clocks refuse to accept v2.1, as testet myself on Cisco Catalyst 9300 and as someone discussed on the mailing list [here](https://sourceforge.net/p/linuxptp/mailman/linuxptp-users/thread/20230710162104.2a8dd088%40rugged/). This support may be reverted by changing `PTP_MINOR_VERSION` in the source code.
- Supports serving NTP time to PTP and PTP time to NTP.
- Resources:
    - [linuxptp.sourceforge.net](https://linuxptp.sourceforge.net/)
    - [RHEL7: Configuring PTP Using ptp4l](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ptp_using_ptp4l)

#### Setup: Grandmaster Mode with Chrony Source (Debian)

Configure LinuxPTP as a GM using the default PTPv2 profile, with Chrony as the local time source.

For this setup, Chrony is the one updating the system time, so `phc2sys` is not used. **TODO**

For testing purposes only, using NTP as the source for PTP is not recommended.

**TODO**: NTP to PTP: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ptp_using_ptp4l#sec-Serving_NTP_Time_with_PTP
**TODO**: Sync PTP HW clock to system clock
**TODO**: Use NTP server directly without Chrony?
**TODO**: clockClass?

1. Check if your NIC supports hardware timestamping: `ethtool -T <interface>`
    - Software mode is fine for testing stuff.
1. Install:
    1. `git clone --depth=1 --branch=v4.1 http://git.code.sf.net/p/linuxptp/code linuxptp`
    1. `cd linuxptp`
    1. If you need PTPv2 instead of v2.1: In `msg.h`, change `PTP_MINOR_VERSION` from 1 to 0.
    1. `make`
    1. `sudo make install`
    1. `cd ..`
1. Create the config file (default profile):
    1. Copy the example config the the default profile: `sudo cp linuxptp/configs/default.cfg /etc/ptp4l.conf`
    1. Reduce the logging interval by setting `summary_interval 6` (2^N seconds). The default is 0 (each second).
    1. Set the first priority to avoid losing the GM role by setting `priority1 1`.
    1. If you have multiple clocks and want to assign some priority between then (after pri1 and class), set `priority2` to some appropriate value.
1. Create the service config below, using the correct interface: `sudo vim /etc/systemd/system/ptp4l.service`
    - If you plan on running multiple PTP profiles on the same computer, you may want to structure the service a bit differently and use different configs.
    - `-i <interface>` for each interface to use with the provided config.
    - `-4` for IPv4.
    - `-S` for SW timestamping, if no HW support available.
1. Enable and start the service: `sudo systemctl daemon-reload && sudo systemctl enable --now ptp4l.service`
1. Check the system journal to make sure it started correctly: `sudo journalctl -u ptp4l.service -f`
    - See the usage notes for more info.
1. Validate that PTP messages are sent: `sudo tcpdump -nn -i <interface> host 224.0.1.129`

Service config (`/etc/systemd/system/ptp4l.service`):

```ini
[Unit]
Description=LinuxPTP daemon
After=network.target

[Service]
ExecStart=ptp4l -f /etc/ptp4l.conf -i eth0 -4

[Install]
WantedBy=multi-user.target
```

#### Usage

- Note: Commands may require root.
- Check the log: `journalctl -u ptp4l.service -f`
    - It should show "assuming the grand master role" after a few seconds, assuming it got the grandmaster role.
    - If `summary_interval 0`, the "master offset" value is the measured offset from the master in nanoseconds.
    - If `summary_interval 0`, the "sN" strings indicate the different clock servo states: "s0" is unlocked, "s1" is clock step and "s2" is locked.
- Show status: `pmc -u -b 0 'GET CURRENT_DATA_SET'` and `pmc -u -b 0 'GET TIME_STATUS_NP'`
    - "stepsRemoved" is the number of jumps toward the GMC.
    - "offsetFromMaster" is the last measured offset of the clock from the master, in nanoseconds.
    - "meanPathDelay" is the estimated delay of the synchronization messages sent from the master, in nanoseconds.
    - "gmPresent" means that the local clock is synchronized to a GMC and that the local clock is _not_ the GMC.

### Cisco

#### Support Overview

- 2-step PTP and multicast support only.
- Catalyst 9000:
    - Profiles: Default, 802.1AS, G.8275.1, AES67.
    - Clock modes: GMC, BC, E2E-TC, P2P-TC
    - With many exceptions.
- Nexus 9000 (first gen):
    - Profiles: Default.
    - Clock modes: GMC, BC.
- Nexus 9000 (later gens):
    - Profiles: Default, AES67, SMPTE 2059-2.
    - Clock modes: GMC, BC.
- ASR 9000:
    - Profiles: Default, G.8265.1, multiprofile.
    - Clock modes: GMC, BC.
- ASR 900, NCS 5500 and NCS 500:
    - Profiles: SyncE, G.8265.1, G.8275.1, G.8275.2, GNSS external.
    - Clock modes: GMC, BC, OC.

#### Catalyst 9000 Series

##### General

- No IPv6 or VRF support.
- PTPv1 is not supported, but can be forwarded like normal traffic.
- Seemingly does not support PTPv2.1 (completely ignored it during testing).
- Supports the default profile and the gPTP profile.
- Does not support transparent clock mode on native L3 ports and EtherChannel interfaces. Boundary clocks are supported on L3 ports.
- EtherChannel interfaces run PTP as individual interfaces.
- Not supported on subinterfaces (or their base interface).
- Not supported on any ports of the supervisor module.
- Does not support SSO. PTP will restart after a switchover.
- Supported on Stackwise since 17.xxx.
- Supported on StackWise Virtual since IOS XE 17.10.1.
- Supports gPTP on 100Mb/s ports: C9300-24H, C9300-24UXB, C9300-48H, C9300L-48PF-4G, C9300L-48PF-4X
- Cat 9200:
    - Not supported.
- Cat 9300:
    - Generally supported.
    - C9300-48UXM: Supported on 1-16 downlinks and all uplinks.
    - C9300-48UN: Supported on 1-36 downlinks and all uplinks.
- Cat 9400:
    - Supported on 9404R, 9407R and 9410R.
    - Not supported on SUP 9400X.
    - Not supported on supervisor ports.
- Cat 9500:
    - Generally supported, except 9500X.
- Cat 9600:
    - Generally supported, except 9600X.

##### Configuration

- Defaults:
    - PTPv2 default profile.
    - Transparent mode.
    - Domain 0.
- Enable required license: `license boot level network-advantage` (then reboot)
- Set transport mode to L3 (before setting clock type): `ptp transport ipv4 udp`
- Set clock type (default profile):
    - BC: `ptp mode boundary delay-req`
    - TC: `ptp mode e2etransparent`
- Set priority 1: `ptp priority1 <0-255>`
    - Use 1 if intended to be GMC or 255 to never become GMC.
- Set PTP source interface: `ptp source Loopback0`
- Set port as permanent master (guard against downstream masters) (BC, interface): `ptp role primary`
- Set PTP VLAN on trunk if not native VLAN (interface): `ptp vlan <vid>`
- Set priority for GMC (default 128): `ptp priority1 100` (example)
- Set source interface: `ptp source <interface>`
- Crossing L3 boundaries using the default profile (L3 switch):
    - Must use VLAN interfaces, not physical routed interfaces.
    - Physical interfaces must be in switchport mode for PTP messages to work.
    - PTP uses a TTL of 1 by default, but some devices support setting the TTL.

**Cat 9300 BC example:**

```
ip access-list extended ptpv2-4
 10 permit udp any eq 319 host 224.0.1.129 eq 319
 20 permit udp any eq 320 host 224.0.1.129 eq 320

int Te1/1/1
 desc ptp-only-uplink
 ip address 10.0.1.0 255.255.255.0
 no switchport
 ip access-group ptpv2-4 in
 ip access-group ptpv2-4 out

int Te1/1/8
 desc downlink
 no switchport
 ip address 10.0.2.0 255.255.255.0
 ptp role primary

ptp transport ipv4 udp
ptp mode boundary delay-req
ptp priority1 255
```

##### Troubleshooting

- Show general info: `show ptp clock`
    - Shows role, profile, identity, domain, offset from master, mean path delay, steps removed etc.
- Show PTP servo clock: `show platform software fed switch active ptp domain`
- Show master info: `show ptp parent`
    - If the parent port number is zero, then the local switch is the GMC.
    - Only GMCs and BCs show up as parents, TCs are transparent.
- Show port info: `show ptp port <interface>`
    - Shows state (master/slave), version, delay mechanism etc.
- Show histograms (24 hours): `show ptp histogram {delay|offset}`
- Show interface counters: `show ptp port counters {errors|messages}`
- Debugging:
    - Show errors: `debug ptp error`
- Common issues:
    - Configure tagging for native VLAN on trunks (`vlan dot1x tag native`) to add CoS and avoid congestion drops (PTP uses priority 7).
    - For ring topologies, configure the gateway bridges as BCs and the rest as TCs.
    - Use STP portfast for non-bridge links.
    - Use matching master and slave profiles. Look for suspicious zero values in the info.
    - Set the TTL to >1 if it will be routed.
- Resources:
    - [Cisco: Troubleshoot Precision Time Protocol (PTP) on Catalyst 9000 Switches](https://www.cisco.com/c/en/us/support/docs/switches/catalyst-9300-series-switches/221062-troubleshoot-precision-time-protocol-pt.html)

#### ACI

##### General

- Switch support:
    - Requires second generation or later ACI switches. Se the config docs for an exact list.
    - Only BC mode with 2-step is supported.
    - Only multicast UDP transport mode is supported.
    - Does not support management messages.
    - Only PTPv2 profiles with E2E delays are supported, so P2P TCs can't be connected to ACI.
    - Supported PTPv2 profiles:
        - IEEE 1588-2008 (default)
        - AES67-2015 (media)
        - SMPTE 2059-2
        - ITU-T G.8275.1 (telecom)
- Fabric latency measurements:
    - One of the main use cases for PTP within ACI.
    - May be used together with atomic counters for a fuller image of what is happening in the network.
    - Used for measuring ongoing TEP-to-TEP latency and on-demand tenant latency (see the docs for details and examples).
    - Supports *average mode* and *histogram mode*.
- Topology:
    - A single PTP domain is used for the whole fabric, with all switches operating in BC mode.
    - To align with the PTP hierarchy of clocks and reduce the number of switches in the clock path, as well as reduce the difference in clock paths to leaf switches, the upstream clock should be connected to all spines.
    - For multi-pod architectures, the inter-pod network (IPN) may be a fitting place to connect the upstream clock to, such that the IPN redistributed the time from the same GMC to the spines in all the pods. When PTP it enabled for the fabric, it's also enabled on IPN uplinks on the spines, such that PTPv2 from the IPN routers can be received on VLAN 4.
    - By default, all ACI switches use a priority 1 of 255, while a single spine in each pod that uses priority 254.
    - **TODO** BD/EPG and L3Out ports. Master supported? Config?
- Resources:
    - [Cisco: Cisco ACI Latency and Precision Time Protocol](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/aci/apic/sw/kb/b_Cisco_ACI_Latency_and_Precision_Time_Protocol.html)
    - [Cisco: Cisco APIC System Management Configuration Guide, Release 6.0(x)](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/system-management-configuration/cisco-apic-system-management-configuration-guide-60x/precision-time-protocol-60x.html)

##### Configuration

- Activate PTP globally (GUI):
    1. Note: This will configure each switch as a BC, where one spine in each pod will get priority 254 and become GMC for the pod. PTP will only be enabled on internal fabric ports.
    1. Go to "System > System Settings > PTP and Latency Measurements > Policy".
    1. Configure it as follows (example):
        - Global priority 1: 255
        - Global priority 2: 255
        - Global domain 0
        - Profile: Default
        - Announce interval: 1 (2s)
        - Sync interval: 0 (1s)
        - Delay request interval: 1 (2s)
        - Announce timeout: 3s
    1. Go to the "Latency" tab and set "System Resolution" to 11.
- Configure a PTP user profile (example):
    1. Note: This depends on the requirements of the clients. As ACI leaf switches act as BCs, it can "convert" to multiple different types. A "standard" profile based on the PTPv2 default profile can be useful for clients without strict requirements, as shown in the next steps.
    1. Go to "Fabric > Access Policies > Policies > Global > PTP User Profile" and click "create".
    1. Name: default_ptp
    1. Profile: Default
    1. Announce interval (2^x s): 1 (2s)
    1. Sync interval (2^x s): -1 (0.5s)
    1. Delay request interval (2^x s): 0 (1s)
    1. Announce timeout (s): 3
- Activate PTP on EPG static ports:
    1. Go to the static port in the EPG.
    1. Configure:
        - PTP state: Enable
        - PTP mode: Multicast master (always master!)
        - PTP source address: Same as the BD GW (IPv4)
        - PTP user profile: Select an appropriate one, maybe create a new one.
- Activate PTP on L3Out ports:
    1. **TODO**
- Configure a latency measurement (when needed) (GUI):
    1. Go to "Tenants > the tenant > Policies > Troubleshooting > Atomic Counter and Latency".
    1. Click the configuration button and select the appropriate measurement type (e.g. EPG to EPG).
    1. Select the IP version(s) to measure.
    1. Select "Latency Statistics" and optionally "Atomic Counter".
    1. Choose the measurement mode (average or histogram).
    1. Fill in the traffic selectors (e.g. source and destination EPG).
    1. Optionally add some traffic filters.
    1. Submit.
    1. To view the results, go to the operational tab and check the atomic counter and latency subtabs.

##### Troubleshooting

- Validate PTP from IPN:
    1. Log into all spines.
    1. Run `show ptp brief` and validate that the IPN uplinks show as exactly one `Slave` and the rest as `Passive` (**TODO** check what it's actually called). All leaf downlinks should show as `Master`.
- Show PTP info (switch CLI):
    - Show local clock: `show ptp clock`
    - Show parent clock: `show ptp parent`
    - Show interface states: `show ptp brief`
    - Show PTP packet counters for some interface: `show ptp counters interface <ethx/x>`

{% include footer.md %}
