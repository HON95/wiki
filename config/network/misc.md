---
title: Miscellaneous Network Notes
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

## Terms

| Cisco IOS | Brocade ICX |
| :--- | :--- |
| Access port (VLAN) | Untagged port |
| Trunk port (VLAN) | Tagged port |
| Native VLAN | Dual mode |

## Spanning Tree

### Variants

| Names | Supporting Devices\* | Description |
| :--- | :--- | :--- |
| 802.1D, STP | Cisco IOS, Linksys LGS | Single instance, slow |
| PVST/PVST+ | Cisco IOS | Like STP, one instance per VLAN |
| VSTP | Juniper | Compatible with Cisco's PVST |
| 802.1w, RSTP | Brocade ICX, Linksys LGS | Single instance, fast, backwards-compatible with STP. |
| Rapid-PVST+ | Cisco IOS | Like PVST+ but based on RSTP |
| VSTP | Juniper | Based on RSTP, compatible with STP and Cisco's PVST |
| 802.1s, MSTP, MST | Cisco IOS | Multiple instances with configurable VLAN members |
| 802.1Q |  | ??? |

(\*) Very incomplete list.

### Notes

- Use extended system ID for multi-VLAN switches.
- Make sure all switches are using compatible variants and default priorities.
- Make sure all VLANs are running STP or that STP is running globally (not per VLAN).
- STP (excluding per-VLAN STP and generally not MST) (including rapid versions) will consider multiple links between switches a loop, even when the links carry different VLANs.
- The bridge priority should generally be a multiple of 4096.
- PVST and 802.1Q regions cannot interoperate directly, but can through PVST+ regions.

#### Cisco IOS

- Disable VTP, it's dangerous if not used properly. It also doesn't carry MST configuration.
- Rapid-PVST+ ignores UplinkFast and BackboneFast and supports UDLD.

### Compatibility Between Switch Models

#### Alternative 1

- Cisco IOS (Cat 3750G): `rapid-pvst`
- Brocade (ICX 6610): `802.1w`
- Linksys (LGS326): `stp` (slow but works)
- Use the same default priority, e.g. 32768.

{% include footer.md %}
