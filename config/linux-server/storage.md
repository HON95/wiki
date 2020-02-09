---
title: Storage
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

### Using
{:.no_toc}

- Debian 10 Buster

## Notes

- Storage typically uses base-10 prefixes like speed but unlike memory.

## Guidelines

- Higher-end SSDs provide power loss protection which generally consists of an on-board capacitor used to flush the device cache in case of power loss.
  Typically DC-grade devices do but cheap consumer devices to not.
- SSDs can be overprovisioned in order to improve performance by leaving unused space the SSD can use internally.
  Factories typically reserve some minimum size appropriate to the drive, but users can overprovision further by leaving space unallocated/unpartitioned at the end of the drive.
  It's typically not needed to overprovision newer SSDs.

### RAID

- HDDs: RAID 1 or RAID 6/7. Never RAID 5. RAID 10 for high load (especially IO).
- SSDs: RAID 5 if three or more and RAID 1 of only two. RAID 10 for extreme load (especially IO).
- For lots of devices, create stripes of RAIDs where each raid handles redundancy internally (e.g. RAID 10 and 60).
- When creating HDD arrays, try to use drives from different batches.
  If one if the batches has some kind of manufacturing fault, shipping damage etc., you don't want the entire array to die all at once.

## Monitoring

### smartmontools (SMART)

See [smartmontools](../../linux-general/applications/#smartmontools).

#### Some HDD SMART Attributes

These should stay near 0 and should not be rising. If they are, it may indicate the drive is about to commit seppuku.

- 005: Reallocated Sectors Count
- 187: Reported Uncorrectable Errors
- 188: Command Timeout
- 197: Current Pending Sector Count
- 198: Uncorrectable Sector Count

## System Storage

- The system drive doesn’t need to be super fast if not used a lot for service stuff. It's typically built from one SSD (optionally overprovisioned) or 2 mirrored HDDs (as they're less reliable).
- Set the boot flag on `/boot/efi` (UEFI) or `/boot` (BIOS). It's not used, but some hardware may require it to try booting the drive.
- Swap can be added either as a partition, as an LVM volume or not added at all.
- Preferred volume manager: LVM or ZFS.
- Preferred file system: EXT4 or ZFS.
- Optionally use only the first half of the disk for LVM/system stuff and the other half for ZFS.

### System Volumes Suggestion

This is just a suggestion for how to partition your main system drive. Since LVM volumes can be expanded later, it's fine to make them initially small. Create the volumes during system installation and set the mount options later in `/etc/fstab`.

| Volume/Mount | Type | Minimal Size (GB) | Mount Options |
| :--- | :--- | :--- | :--- |
| `/proc` | Runtime | N/A | hidepid=2,gid=1500 |
| `/boot/efi` | FAT32 w/ boot flag (UEFI), none (BIOS) | 0.5 | nodev,nosuid,noexec |
| `/boot` | EXT4 (UEFI), FAT32 w/ boot flag (BIOS) | 0.5 | nodev,nosuid,noexec |
| Swap | Swap (optional) | 4, 8, 16 | N/A |
| `vg0` | LVM | 50% or 100% | N/A |
| Swap | Swap (LVM) (optional) | 4, 8, 16 | N/A |
| `/` | EXT4 (LVM) | 10 | nodev |
| `/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/lib` | EXT4 (LVM) | 5 | nodev,nosuid |
| `/var/log` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/var/log/audit` | EXT4 (LVM) | 1 | nodev,nosuid,noexec |
| `/var/tmp` | EXT4 (LVM) | 5 | nodev,nosuid,noexec |
| `/home` | EXT4 (LVM) | 10 | nodev,nosuid |
| `/srv` | EXT4 (LVM) or none if external | 10 | nodev,nosuid |
  
## ZFS

### Info

#### Features

- Filesystem and physical storage decoupled
- Always consistent
- Intent log
- Synchronous or asynchronous
- Everything checksummed
- Compression
- Deduplication
- Encryption
- Snapshots
- Copy-on-write (CoW)
- Clones
- Caching
- Log-strucrured filesystem
- Tunable

#### Terminology

- Vdev
- Zpool
- Zvol
- ZFS POSIX Layer (ZPL)
- ZFS Intent Log (ZIL)
- Adaptive Replacement Cache (ARC)
- Dataset

### Setup

#### Installation

The installation part is highly specific to Debian 10.
Some guides recommend using backport repos, but this way doesn't require that.

1. Enable the `contrib` and `non-free` repo areas.
1. Install (it might give errors): `zfs-dkms zfsutils-linux zfs-zed`
1. Load the ZFS module: `modprobe zfs`
1. Fix the ZFS install: `apt install`

#### Configuration

1. Make the import service wait for iSCSI:
    1. **TODO** Test if this is actually working.
    1. `cp /lib/systemd/system/zfs-import-cache.zervice /etc/systemd/system`
    1. Add `After=iscsid.service` in `/etc/systemd/system/zfs-import-cache.service`.
    1. `systemctl enable zfs-import-cache.service`
1. Set the max ARC size: `echo "options zfs zfs_arc_max=<bytes>" >> /etc/modprobe.d/zfs.conf`
    - It should typically be around 15-25% of the physical RAM size on general nodes. It defaults to 50%.
1. Check that the cron scrub script exists.
    - Typical location: `/etc/cron.d/zfsutils-linux`
    - If it doesn't exist, add one which runs `/usr/lib/zfs-linux/scrub` e.g. monthly. It'll scrub all disks.

### Usage

- Create a pool: `zpool create -o ashift=<9|12> [level] <drives>+`
- Create an encrypted pool:
  - The procedure is basically the same for encrypted datasets.
  - Children of encrypted datasets can't be unencrypted.
  - The encryption suite can't be changed after creation, but the keyformat can.
  - Using a password: `zpool create -O encryption=aes-128-gcm -O keyformat=passphrase ...`
  - Using a raw key:
    - Generate the key: `dd if=/dev/random of=/root/keys/zfs/<tank> bs=32 count=1`
    - Create the pool: `zpool create -O encryption=aes-128-gcm -O keyformat=raw -O keylocation=file:///root/keys/zfs/<tank> ...`
    - Automatically unlock at boot time: Add and enable [zfs-load-keys.service](https://github.com/HON95/misc-configs/blob/master/linux-server/zfs/zfs-load-keys.service).
  - Reboot and test.
  - Check the key status with `zfs get keystatus`.
- Send and receive snapshots:
  - `zfs send [-R] <snapshot>` and `zfs recv <snapshot>`.
  - Uses STDOUT.
  - Use `zfs get receive_resume_token` and `zfs send -t <token>` to resume an interrupted transfer.
- View activity: `zpool iostat [-v]`
- Clear transient device errors: `zpool clear <pool> [device]`
- If a pool is "UNAVAIL", it means it can't be recovered without corrupted data.
- Replace a device and automatically copy data from the old device or from redundant devices: `zpool replace <pool> <device> [new-device]`
- Bring a device online or offline: `zpool (online|offline) <pool> <device>`
- Re-add device that got wiped: Take it offline and then online again.

### Best Practices and Suggestions

- As far as possible, use raw disks and HBA disk controllers (or RAID controllers in IT mode).
- Always use `/etc/disk/by-id/X`, not `/dev/sdX`.
- Always manually set the correct ashift for pools.
  - Should be the log-2 of the physical block/sector size of the device.
  - E.g. 12 for 4kB (Advanced Format (AF), common on HDDs) and 9 for 512B (common on SSDs).
  - Check the physical block size with `smartctl -i <dev>`.
  - Keep in mind that some 4kB disks emulate/report 512B. They should be used as 4kB disks.
- Always enable compression.
    - Generally `lz4`. Maybe `zstd` when implemented. Maybe `gzip-9` for archiving.
    - For uncompressable data, worst case it that it does nothing (i.e. no loss for enabling it).
    - The overhead is typically negligible. Only for super-high-bandwidth use cases (large NVMe RAIDs), the compression overhead may become noticable.
- Never use deduplication.
    - It's generally not useful, depending on the use case.
    - It's expensive.
    - It may brick your ZFS server.
- Generally always use quotas and reservations.
- Avoid using more than 80% of the available space.
- Make sure regular automatic scrubs are enabled.
    - There should be a cron job/script or something.
    - Run it e.g. every 2 weeks or monthly.
- Snapshots are great for incremental backups. They're easy to send places too. If the dataset is encrypted then so is the snapshot.
- Enabling features like encryption, compression, deduplication is not retro-active. You'll need to move the old data away and back for the features to apply to the data.

### Tuning

- Use quotas, reservations and compression.
- Very frequent reads:
  - E.g. for a static web root.
  - Set `atime=off` to disable updating the access time for files.
- Database:
  - Disable `atime`.
  - Use an appropriate recordsize with `recordsize=<size>`.
    - InnoDB should use 16k for data files and 128k on log files (two datasets).
    - PostgreSQL should use 8k (or 16k) for both data and WAL.
  - Disable caching with `primarycache=metadata`. DMBSes typically handle caching themselves.
    - For InnoDB.
    - For PostgreSQL if the working set fits in RAM.
  - Disable the ZIL with `logbias=throughput` to prevent writing twice.
    - For InnoDB and PostgreSQL.
    - Consider not using it for high-traffic applications.
  - PostgreSQL:
    - Use the same dataset for data and logs.
    - Use one dataset per database instance. Requires you to specify it when creating the database.
    - Don't use PostgreSQL checksums or compression.
    - Example: `su postgres -c 'initdb --no-locale -E=UTF8 -n -N -D /db/pgdb1'`

### Troubleshooting

**TODO** Test if this is actually working.

- `zfs-import-cache.service` fails to import pools because disks are not found:
  - Set `options scsi_mod scan=sync` in `/etc/modprobe.d/zfs.conf` to wait for iSCSI disks to come online before ZFS starts.
  - Add `After=iscsid.service` to `zfs-import-cache.service`

### Extra Notes

- ECC memory is recommended but not required. It does not affect data corruption on disk.
- It does not require large amounts of memory, but more memory allows it to cache more data. A minimum of around 1GB is suggested. Memory caching is termed ARC. By default it's limited to 1/2 of all available RAM. Under memory pressure, it releases some of it to other applications.
- Compressed ARC is a feature which compresses and checksums the ARC. It's enabled by default.
- A dedicated disk (e.g. an NVMe SSD) can be used as a secondary read cache. This is termed L2ARC (level 2 ARC). Only frequently accessed blocks are cached. The memory requirement will increase based on the size of the L2ARC. It should only be considered for pools with high read traffic, slow disks and lots of memory available.
- A dedicated disk (e.g. an NVMe SSD) can be used for the ZFS intent log (ZIL), which is used for synchronized writes. This is termed SLOG (separate intent log). The disk must have low latency, high durability and should preferrably be mirrored for redundancy. It should only be considered for pools with high synchronous write traffic on relatively slow disks.
- Intel Optane is a perfect choice as both L2ARCs and SLOGs due to its high throughput, low latency and high durability.
- Some SSD models come with a build-in cache. Make sure it actually flushes it on power loss.
- ZFS is always consistent, even in case of data loss.
- Bitrot is real.
  - 4.2% to 34% of SSDs have one UBER (uncorrectable bit error rate) per year.
  - External factors:
    - Temperature.
    - Bus power consumption.
    - Data written by system software.
    - Workload changes due to SSD failure.
- Signs of drive failures:
  - `zpool status <pool>` shows that a scrub has repaired any data.
  - `zpool status <pool>` shows read, write or checksum errors (all values should be zero).
- Database conventions:
  - One app per database.
  - Encode the environment and DMBS version into the dataset name, e.g. `theapp-prod-pg10`.

{% include footer.md %}
