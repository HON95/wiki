---
title: Dell PowerEdge Series
breadcrumbs:
- title: Configuration
- title: Server
---
{% include header.md %}

### Using
{:.no_toc}

- DL380p Gen8

## Firmware Updates

**TODO**

## Management

- The default iLO username (typically `Administrator`) and password can be found on the service tag pull-out.
- For added security, add a personal user and delete the default admin user.

## Storage

- Gen8 requires genuine HP drives and caddies for Gen8 to work properly. When using unsupported drives, the server will be super noisy. HP drives generally are both more expensive and have less performance than the alternatives, making it a a potentially unattractive option for homelabs. This may be somewhat true for previous gens as well (I don't know, I don't have any), but Gen8 is especially restrictive.
- A CD-ROM to 2.5" SATA drive adapter can be used to boot any SATA drives from the internal SATA controller. This avoids the problems with drive compatibility for the RAID/HBA controller mentioned above.
- To enter the BIOS RAID configudation, keep pressing F8 during boot to enter iLO configuration, exit iLO configuration, then keep pressing F8 to enter RAID configuration. (It says F5, but that doesn't seem to work.)

## Booting

- Gen8 and lower generally does not support UEFI.
- To allow booting from USB drives, enable it in the setup utility under "System Options", "USB Options".

{% include footer.md %}
