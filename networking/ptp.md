---
title: Precision Time Protocol (PTP)
breadcrumbs:
- title: Network
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
- PTP domains:
    - Domains allow multiple clock distribution systems to share the same communications medium.
    - Domain 0 is the default. Many devices only support the default domain.
- Packet delay variation (PDV):
    - Variation is often due to varying queue depths.
    - Computed constantly, averaged out over time.
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
- Best Master Clock (BMC) algorithm:
    - Uses Announce messages.
    - Selects a clock according to (from highest priority):
        - Priority 1: User-configurable from 0 to 255, lower value takes precedence.
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
    - Assumes that each clock elects the same GMC each second, assuming they all see the same Announce messages.
    - While the class can typically correctly pick the BMC, it's a good idea to use priority 1 (or priority 2) in addition, to prevent BMC flapping.
- Oscillators:
    - Oven controlled crystal oscillators (OCXOs) are better than temperature compensated crystal oscillators (TCXOs).
    - Keep oscillator quality in mind when choosing GMCs and BC.
    - Good quality oscillators are critical for free-running clocks.
- Primary and backup GMC:
    - A single backup is typically enough.
    - Use priority 1 to choose the primary GMC.
    - Connect the backup GMC to an Ethernet switch at most one bridge hop away from the primary. This yealds lower PDV changes in case of failovers.

### Versions

#### PTPv1 (IEEE 1588-2002)

- The initial version, designed to give greater precision than NTP by using GPS.
- Used e.g. by older Dante devices.

#### PTPv2 (IEEE 1588-2008)

- Not backwards-compatible with PTPv1.
- Supports multiple profiles, including the _default_ profile which is often referred to as simply "PTPv2".

#### PTPv2.1 (IEEE 1588-2019)

- Includes some backwards-compatible improvements to the 2008 version.

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

#### ITU-T G.82751

- Used for telecom and mobile backhaul.

#### AES67

- For AES67 and Dante audio.
- Used by newer Dante devices, while older ones use PTPv1. Certain Dante devices support both PTP versions, such that they can consume PTPv2 and supply PTPv1 to other devices in the same bridge domain (like a BC).
- A variant of the default profile, with certain chosen parameters.

#### SMPTE 2059-2

- For multimedia.

## Vendor Support

### Cisco

#### Product Support

- 2-step PTP and multicast support only.
- Catalyst 9300, 9400, 9500:
    - Profiles: Default and 802.1AS.
    - Clock modes: GMC, BC, E2E-TC, P2P-TC
    - With exceptions.
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

#### Configuration and Troubleshooting (Catalyst)

- The default profile with transparent mode is the default.
- PTP can be disabled by changing to "forwarding" mode.
- Show general info: `show ptp clock`
    - Shows role, profile, identity, domain, offset from master, mean path delay, steps removed etc.
- Show master info: `show ptp parent`
    - If the parent port number is zero, then the local switch is the GMC.
    - Only GMCs and BCs show up as parents, TCs are transparent.
- Show port info: `show ptp port <interface>`
    - Shows state (master/slave), version, delay mechanism etc.
- Show histograms (24 hours): `show ptp histogram {delay|offset}`
- Show interface counters: `show ptp port counters {errors|messages}`
- Debugging:
    - Show errors: `debug ptp error`
- Set priority for GMC (default 128) (example):
    - `ptp priority1 110`
- Crossing L3 boundaries using the default profile (L3 switch):
    - Must use VLAN interfaces, not physical routed interfaces.
    - Physical interfaces must be in switchport mode for PTP messages to work.
    - PTP uses a TTL of 1 by default, but some devices support setting the TTL.
- Common issues:
    - Configure tagging for native VLAN on trunks (`vlan dot1x tag native`) to add CoS and avoid congestion drops (PTP uses priority 7).
    - For ring topologies, configure the gateway bridges as BCs and the rest as TCs.
    - Use STP portfast for non-bridge links.
    - Use matching master and slave profiles. Look for suspicious zero values in the info.
    - Set the TTL to >1 if it will be routed.

{% include footer.md %}
