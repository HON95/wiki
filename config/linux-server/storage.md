---
title: Linux Server Storage
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

Using **Debian**, unless otherwise stated.

## General

- For benchmarking etc., see [Computer Testing (General)](/config/general/computer-testing/).

## Guidelines and Miscellaneous Notes

- While file/block sizes typically use base-2 prefixes, storage mediums typically use base-10 prefixes.
- Partitioning formats:
    - Master Boot Record (MBR):
        - From DOS.
        - Supports only 4 physical partitions, but one (and only one) physical partition may be used as an extended partition which contains logical partitions.
        - Supports disks up to 2TB only.
    - GUID Partition Table (GPT):
        - Newer than MBR, part of the UEFI specification.
        - Supports disks over 2TB.
        - Some OSes requires EFI support in order to boot from GPT drives.
- Addressing modes: Cylinder, head and sector (CHS) (old and HDD-based) and logical block addressing (LBA) (new and hardware agnostic).
- After receiving a new drive or after transporting an existing drive, you should run a SMART conveyance test,
  which is similar to a short test but targeted at this scenario.
  See [smartmontools](/config/linux-server/applications/#smartmontools).
- Alignment and block sizes:
    - Using a logical block size smaller than the physical one or misaligning logical and physical blocks will cause reduced performance, mainly for small writes.
    - Main variants:
        - 512: The original, still used by some drives.
        - 4096: Aka "Advanced Format" or "AF". Newer than 512.
        - Emulated 512: Actually 4096 but emulating 512 for compatibility reasons. Problematic when automatically selecting block size.
    - Some enterprise SSDs let you to set the physical block size.
- Hard drives often experience performance degredation before failing completely.
  This may lead to high latencies, reduced bandwidth and possibly read/write errors.
  High latencies and low bandwidth is hard to detect automatically and may result in reduced performance for the whole system.
- SSD/HDD optimiztions:
    - Most modern tools on modern Linux versions will automatically align file systems and partitions correctly.
    - The `relatime` mount flag is set by default, to reduce disk writes when a file is read.
    - For SSDs, don't enable TRIM (using neither the `discard` mount option nor `fstrim.timer`). TRIM typically don't provide much benefit and may actually reduce performance. Since SSDs are generally overprovisioned and may be overprovisioned further by the user (generally not needed), TRIM is generally not needed any more.
- Swap/page file: Generally, all systems should have a swap file or volume to avoid invoking the OOM killer when running out of memory for whatever reason. Its existance will not slow down the system and it will typically not even be used if the system has enough memory. It does not need to be super fast since it's only used in suboptimal conditions to begin with.

### SSDs

- Overprovisioning: SSDs can be overprovisioned by leaving unallocated/unpartitioned space at the end in order to improve wear leveling and performance, handled internally by the SSD.
  They're already overprovisioned internally, meaning newer SSDs generally don't *need* to be manually overprovisioned.
  Some enterprise SSDs allow the user specify how much overprovisioned it is.
- DRAM cache: Mid-to-high-end SSDs typically use a volatile DRAM cache, which significantly improves performance.
- Power loss protection:
  Higher-end SSDs typically provide power loss protection, which generally consists of an on-board capacitor used to flush the device cache in case of power loss.
  Typically DC-grade devices contain this mechanism but cheap consumer devices do not.

### RAID

- With HDDs: Use RAID 1 if only two and RAID 6/7 if three or more. Never RAID 5, it's too risky.
- With SSDs: Use RAID 1 if only two and RAID 5 if three or more.
- Use RAID 10 for high/extreme load (expecially IOPS). Typically for HDDs, as SSDs are already pretty "fast".
- For lots of devices, create stripes of RAIDs where each raid handles redundancy internally (e.g. RAID 10 and 60).
- When creating HDD arrays, try to use drives from different batches.
  If one if the batches has some kind of manufacturing fault, shipping damage etc., you don't want the entire array to die all at once.
- After replacing a bad drive, the resilvering of the new drive typically puts a high load on the other drives.
  It's not uncommon for other drives to fail during this process, which is why you never use RAID 5 with HDDs.

### System Storage

- The system drive doesn’t need to be super fast if not used a lot for service stuff. It's typically built from one SSD (optionally overprovisioned) or 2 mirrored HDDs (as they're less reliable).
- Set the boot flag on `/boot/efi` (UEFI) or `/boot` (BIOS). It's not used, but some hardware may require it to try booting the drive.
- Swap can be added either as a partition, as an LVM volume or not added at all.
- Preferred volume manager: LVM or ZFS.
- Preferred file system: EXT4 or ZFS.
- Optionally use only the first half of the disk for LVM/system stuff and the other half for ZFS.

#### System Volumes Suggestion

This is just a suggestion for how to partition your main system drive. Since LVM volumes can be expanded later, it's fine to make them initially small. Create the volumes during system installation and set the mount options later in `/etc/fstab`.

| Volume/Mount | Type | Minimal Size (GB) | Mount Options |
| :--- | :--- | :--- | :--- |
| `/proc` | Runtime | N/A | hidepid=2,gid=1500 |
| `/boot/efi` | FAT32 w/ boot flag (UEFI), none (BIOS) | 0.5 | nodev,nosuid,noexec |
| `/boot` | EXT4 (UEFI), FAT32 w/ boot flag (BIOS) | 0.5 | nodev,nosuid,noexec |
| Swap | Swap (optional) | N/A | N/A |
| `vg0` | LVM | 50% or 100% | N/A |
| Swap | Swap (LVM) (optional) | N/A | N/A |
| `/` | EXT4 (LVM) | 10 | nodev |
| `/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/lib` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/log` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var/log/audit` | EXT4 (LVM) | 1 | nodev,nosuid,noexec |
| `/var/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/home` | EXT4 (LVM) | 10 | nodev,nosuid |
| `/srv` | EXT4 (LVM) or none if external | 10 | nodev,nosuid |

## Disks

### Seagate

Attributes 1 (Raw Read Error Rate) and 7 (Seek Error Rate) can be a bit misleading, as a non-zero value does not mean there are errors. They are 48-bit values where the most significant 16 bits are the error count and the lower 32 bits are the number of operations (acting sort of like a fraction/rate).

## Applications

### SMART

See [smartmontools](/config/linux-server/applications/#smartmontools).

For HDDs, the following attributes should stay near 0 and should not be rising. If they are, it may indicate the drive is about to commit seppuku.

- 005 (Reallocated Sectors Count)
- 187 (Reported Uncorrectable Errors)
- 188 (Command Timeout)
- 197 (Current Pending Sector Count)
- 198 (Uncorrectable Sector Count)

### Intel SSD Data Center Tool (isdct)

#### Setup

1. Download the ZIP for Linux from Intel's site.
1. Install the AMD64 deb package.

#### Usage

- Command syntax: `isdct <verb> [options] [targets] [properties]`
    - Target may be either index (as seen in *show*) or serial number.
- Show all SSDs: `isdct show -intelssd`
- Show SSD properties: `isdct show -all -intelssd [target]`
- Show health: `isdct show -sensor`
- Upgrade firmware: `isdct load -intelssd <target>`
- Set physical sector size: `isdct set -intelssd <target> PhysicalSectorSize=<512|4096>`
    - 4k is generally the most optimal choice.
- Prepare a drive for removal by putting it in standby: `isdct start -intelssd <target> -standby`
- Show speed: `isdct show -a -intelssd [target] | grep -i speed`
- Fix SATA 3.0 speed: `isdct set -intelssd <target> PhySpeed=6`
    - Check before and after either with *isdct* or *smartctl*.

##### Change the Capacity

1. Remove all partitions from the drive.
1. Remove all data: `isdct delete -intelssd <target>`
1. (Optional) Set the physical sector size: `isdct set -intelssd <target> PhysicalSectorSize=<512|4096>`
1. Set the new size: `isdct set -intelssd <target> MaximumLBA=<size>`
    - If this fails, run `isdct set -system EnableLSIAdapter=true`.
      It will add another "version" of the SSDs, which you can try again with.
    - The size can be specified either as "native", the LBA count, percent (`x%`) or in gigabytes (`xGB`).
      Use "native" unless you have a reason not to.
1. Prepare it for removal: `isdct start -intelssd <target> -standby`
1. Reconnect the drives or restart the system.

## Volume Managers, File Systems, Etc.

### Autofs

Autofs automatically mounts directories when accessed and unmounts them after a period of inactivity.
Note that `ls` will not reveal an unmounted autofs mount.
To automount it, you need to actually enter it (or equivalent).

#### Setup

1. Install: `apt install autofs`
1. Configure master map config:
    - File: `/etc/auto.master`
    - Each line declares a direct or indirect map, which consists of a path and a set of mounts in a separate configuration file. Indirect maps mount the mountpoints inside the path in the master config, while direct maps (specified using path `/-` in the master config) mount the mountpoints using absolute paths.
    - Map line format: `<mountpoint> [options] <mapfile> [options]`
1. Configure map configs:
    - File path convention: `/etc/auto.<id>` (matching entry in master map config)
    - Mount line format: `<mountpoint> [options] <location>`
    - The location may e.g. be an NFS export.
1. (Optional) Automount home dirs or similar using wildcards:
    - As specifying all dirs would be cumbersome, wildcards may be used instead.
    - Add `/home /etc/auto.home` to the master map.
    - Add `* <server>:/home/&` to the home map (using NFS).
1. (Optional) Run in foreground for debugging:
    - Stop the daemon: `sudo service autofs stop`
    - Run in foreground: `sudo automount -f -v`
    - Test stuff in other terminal.

### LUKS

#### Setup

1. Install: `apt install cryptsetup`

#### Usage

##### Encrypt Normal Partition

1. Format the device/partition: `cryptsetup -v luksFormat <dev> [keyfile]`
    - If not keyfile is specified, a password is required instead.
    - Generate random keyfile: `dd if=/dev/random of=/root/.credentials/luks/<dev> bs=64 count=1`
1. (Optional) Add extra keys: `cryptsetup luksAddKey <dev> [--key-file <oldkeyfile>] [keyfile]`
    - Specify `oldkeyfile` to unlock it using a existing keyfile.
    - Omit `keyfile` to add a password.
1. (Optional) Check the result: `cryptsetup luksDump <dev>`
1. Mount the decrypted device: `cryptsetup open <dev> [--key-file <keyfile>] <name>`
    - Close: `cryptsetup close <name>`
    - Show status: `cryptsetup -v status <name>`
1. (Optional) Zeroize it to write random data to disk: `dd if=/dev/zero of=<mapper-dev> status=progress`
1. Format using some file system: `mkfs.ext4 <mapper-dev>` (for EXT4)
1. (Optional) Permanently mount device and FS using keyfile:
    1. In `/etc/crypttab`, add: `<name> UUID=<dev-uuid> <keyfile> luks`
    1. In `/etc/fstab`, add: `/dev/mapper/<name> <mountpoint> ext4 defaults 0 0` (for EXT4)
    1. Reload `/etc/crypttab`: `systemctl reload-daemons`
    1. Reload `/etc/fstab`: `mount -a`

### Ceph

See [Linux Server Storage: Ceph](../storage-ceph/).

### ZFS

See [Linux Server Storage: ZFS](../storage-zfs/).

{% include footer.md %}
