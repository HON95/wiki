---
title: Linux Server Storage
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

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
  See [smartmontools](../../linux-general/applications/#smartmontools).
- Alignment and block sizes:
    - Using a logical block size smaller than the physical one or misaligning logical and physical blocks will cause reduced performance, mainly for small writes.
    - Typical options:
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
    - `vm.swappiness` should possibly be set to some reasonable value to reduce swapping pressure on the swap disk(s).

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

## Monitoring

### SMART

See [smartmontools](../../linux-general/applications/#smartmontools).

For HDDs, the following attributes should stay near 0 and should not be rising. If they are, it may indicate the drive is about to commit seppuku.

- 005 (Reallocated Sectors Count)
- 187 (Reported Uncorrectable Errors)
- 188 (Command Timeout)
- 197 (Current Pending Sector Count)
- 198 (Uncorrectable Sector Count)

#### Seagate

Attributes 1 (Raw Read Error Rate) and 7 (Seek Error Rate) can be a bit misleading, as a non-zero value does not mean there are errors. They are 48-bit values where the most significant 16 bits are the error count and the lower 32 bits are the number of operations (acting sort of like a fraction/rate).

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

## Ceph

### Resources

- (Ceph: Ceph PGs per Pool Calculator)[https://ceph.com/pgcalc/]
- (Ceph Documentation: Placement Group States)[https://docs.ceph.com/docs/mimic/rados/operations/pg-states/]

### Info

- Distributed storage for HA.
- Redundant and self-healing without any single point of failure.
- The Ceph Storeage Cluster consists of:
    - Monitors (typically one per node) for monitoring the state of itself and other nodes.
    - Managers (at least two for HA) for serving metrics and statuses to users and external services.
    - OSDs (object storage daemon) (one per disk) for handles storing of data, replication, etc.
    - Metadata Servers (MDSs) for storing metadata for POSIX file systems to function properly and efficiently.
- At least three monitors are required for HA, because of quorum.
- Each node connects directly to OSDs when handling data.
- Pools consist of a number of placement groups (PGs) and OSDs, where each PG uses a number of OSDs.
- Replication factor (aka size):
    - Replication factor *n*/*m* (e.g. 3/2) means replication factor *n* with minimum replication factor *m*. One of them is often omitted.
    - The replication factor specifies how many copies of the data will be stored.
    - The minimum replication factor describes the number of OSDs that must have received the data before the write is considered successful and unblocks the write operation.
    - Replication factor *n* means the data will be stored on *n* different OSDs/disks on different nodes,
      and that *n-1* nodes may fail without losing data.
- When an OSD fails, Ceph will try to rebalance the data (with replication factor over 1) onto other OSDs to regain the correct replication factor.
- A PG must have state *active* in order to be accessible for RW operations.
- The number of PGs in an existing pool can be increased but not decreased.
- Clients only interact with the primary OSD in a PG.
- The CRUSH algorithm is used for determining storage locations based on hashing the pool and object names. It avoids having to index file locations.
- BlueStore (default OSD back-end):
    - Creates two partitions on the disk: One for metadata and one for data.
    - The metadata partition uses an XFS FS and is mounted to `/var/lib/ceph/osd/ceph-<osd-id>`.
    - The metadata file `block` points to the data partition.
    - The metadata file `block.wal` points to the journal device/partition if it exists (it does not by default).
    - Separate OSD WAL/journal and DB devices may be set up, typically when using HDDs or a mix of HDDs and SSDs.
    - One OSD WAL device can serve multiple OSDs.
    - OSD WAL devices should be sized according to how much data they should "buffer".
    - OSD DB devices should be at least 4% as large as the backing OSDs. If they fill up, they will spill onto the OSDs and reduce performance.
    - If the fast storage space is limited (e.g. less than 1GB), use it as an OSD WAL. If it is large, use it as an OSD DB.
    - Using a DB device will also provide the benefits of a WAL device, as the journal is always placed on the fastest device.
    - A lost OSD WAL/DB will be equivalent to lose all OSDs. (For the older Filestore back-end, it used to be possible to recover it.)

### Guidelines

- Use at least 3 nodes.
- CPU: Metadata servers and partially OSDs are somewhat CPU intensive. Monitors are not.
- RAM: OSDs should have ~1GB per 1TB storage, even though it typically doesn't use much.
- Use a replication factor of at least 3/2.
- Run OSes, OSD data and OSD journals on separate drives.
- Network:
    - Use an isolated separete physical network for internal cluster traffic between nodes.
    - Consider using 10G or higher with a spine-leaf topology.
- Pool PG count:
    - \<5 OSDs: 128
    - 5-10 OSDs: 512
    - 10-50 OSDs: 4096
    - \>50 OSDs: See (pgcalc)[https://ceph.com/pgcalc/].

### Usage

- General:
    - List pools: `rados lspools` or `ceph osd lspools`
    - Show pool utilization: `rados df`
- Pools:
    - Create: `ceph osd pool create <pool> <pg-num>`
    - Delete: `ceph osd pool delete <pool> [<pool> --yes-i-really-mean-it]`
    - Rename: `ceph osd pool rename <old-name> <new-name>`
    - Make or delete snapshot: `ceph osd pool <mksnap|rmsnap> <pool> <snap>`
    - Set or get values: `ceph osd pool <set|get> <pool> <key>`
    - Set quota: `ceph osd pool set-quota <pool> [max_objects <count>] [max_bytes <bytes>]`
- PGs:
    - Status of PGs: `ceph pg dump pgs_brief`
- Interact with pools directly using RADOS:
    - Ceph is built on based on RADOS.
    - List files: `rados -p <pool> ls`
    - Put file: `rados -p <pool> put <name> <file>`
    - Get file: `rados -p <pool> get <name> <file>`
    - Delete file: `rados -p <pool> rm <name>`
- Manage RBD (Rados Block Device) images:
    - Images are spread over multiple objects.
    - List images: `rbd -p <pool> ls`
    - Show usage: `rbd -p <pool> du`
    - Show image info: `rbd info <pool/image>`
    - Create image: `rbd create <pool/image> --object-size=<obj-size> --size=<img-size>`
    - Export image to file: `rbd export <pool/image> <file>`
    - Mount image: TODO

#### Failure Handling

**Down + peering:**

The placement group is offline because an is unavailable and is blocking peering.

1. `ceph pg <pg> query`
1. Try to restart the blocked OSD.
1. If restarting didn't help, mark OSD as lost: `ceph osd lost <osd>`
    - No data loss should occur if using an appropriate replication factor.

**Active degraded (X objects unfound):**

Data loss has occurred, but metadata about the missing files exist.

1. Check the hardware.
1. Identify object names: `ceph pg <pg> query`
1. Check which images the objects belong to: `ceph pg <pg list_missing>`
1. Either restore or delete the lost objects: `ceph pg <pg> mark_unfound_lost <revert|delete>`

**Inconsistent:**

Typically combined with other states. May come up during scrubbing.
Typically an early indicator of faulty hardware, so take note of which disk it is.

1. Find inconsistent PGs: `ceph pg dump pgs_brief | grep -i inconsistent`
    - Alternatively: `rados list-inconsistent pg <pool>`
1. Repair the PG: `ceph pg repair <pg>`

#### OSD Replacement

1. Stop the daemon: `systemctl stop ceph-osd@<id>`
    - Check: `systemctl status ceph-osd@<id>`
1. Destroy OSD: `ceph osd destroy osd.<id> [--yes-i-really-mean-it]`
    - Check: `ceph osd tree`
1. Remove OSD from CRUSH map: `ceph osd crush remove osd.<id>`
1. Wait for rebalancing: `ceph -s [-w]`
1. Remove the OSD: `ceph osd rm osd.<id>`
    - Check that it's unmounted: `lsblk`
    - Unmount it if not: `umount <dev>`
1. Replace the physical disk.
1. Zap the new disk: `ceph-disk zap <dev>`
1. Create new OSD: `pveceph osd create <dev> [options]` (PVE)
    - Specify any WAL or DB devices.
    - See [PVE: pveceph(1)](https://pve.proxmox.com/pve-docs/pveceph.1.html).
    - Without `pveceph osd create`, a series of steps are required.
    - Check that the new OSD is up: `ceph osd tree`
1. Start the OSD daemon: `systemctl start ceph-osd@<id>`
1. Wait for rebalancing: `ceph -s [-w]`
1. Check the health: `ceph health`

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

#### Encryption

- ZoL v0.8.0 and newer supports native encryption of pools and datasets. This encrypts all data except some metadata like pool/dataset structure, dataset names and file sizes.
- Datasets can be scrubbed, resilvered, renamed and deleted without unlocking them first.
- Datasets will by default inherit encryption and the encryption key (the "encryption root") from the parent pool/dataset.
- The encryption suite can't be changed after creation, but the keyformat can.

### Setup

#### Installation

The installation part is highly specific to Debian 10.
Some guides recommend using backport repos, but this way avoids that.

1. Enable the `contrib` and `non-free` repo areas.
1. Install (will probably stall a bit because of errors): `apt install zfs-dkms zfsutils-linux zfs-zed`
1. Load the ZFS module: `modprobe zfs`
1. Fix the ZFS install: `apt install`

#### Configuration

1. (Optional) Set the max ARC size: `echo "options zfs zfs_arc_max=<bytes>" >> /etc/modprobe.d/zfs.conf`
    - It should typically be around 15-25% of the physical RAM size on general nodes. It defaults to 50%.
    - This is generally not required, ZFS should happily yield RAM to other processes that need it.
1. Check that the cron scrub script exists.
    - Typical location: `/etc/cron.d/zfsutils-linux`
    - If it doesn't exist, add one which runs `/usr/lib/zfs-linux/scrub` e.g. monthly. It'll scrub all disks.
1. Check that ZED is set up to send emails.
    - In `/etc/zfs/zed.d/zed.rc`, make sure `ZED_EMAIL_ADDR="root"` is uncommented.

### Usage

- Create pool: `zpool create -o ashift=<9|12> <name> <levels-and-drives>`
    - Realistic example: `zpool create -o ashift=<9|12> -o compression=lz4 <name> [mirror|raidz|raidz2|...] <drives>`
- Create dataset: `zfs create <pool>/<name>`
    - Realistic example: `zfs create -o quota=<size> -o reservation=<size> <pool>/<other-datasets>/<name>`
- Create and destroy snapshots:
    - Create: `zfs snapshot [-r] <dataset>@<snapshot>` (`-r` for "recursive")
    - Destroy: `zfs destroy [-r] <dataset>@<snapshot>` (Careful!)
- Send and receive snapshots:
    - Send to STDOUT: `zfs send [-R] <snapshot>` (`-R` for "recursive")
    - Receive from STDIN: `zfs recv <snapshot>`
    - Resume interrupted transfer: Use `zfs get receive_resume_token` and `zfs send -t <token>`.
    - Consider running it in a screen session or something to avoid interruption.
    - If you want transfer information (throughput), pipe it through `pv`.
- View activity: `zpool iostat [-v]`

#### Error Handling and Replacement

- Clear transient device errors: `zpool clear <pool> [device]`
- If a pool is "UNAVAIL", it means it can't be recovered without corrupted data.
- Replace a device and automatically copy data from the old device or from redundant devices: `zpool replace <pool> <old-device> <new-device>`
- Bring a device online or offline: `zpool (online|offline) <pool> <device>`
- Re-add device that got wiped: Take it offline and then online again.

#### Encryption

- Check stuff:
    - Encryption root: `zfs get encryptionroot`
    - Key status: `zfs get keystatus`. `unavailable` means locked and `-` means not encrypted.
    - Mount status: `zfs get mountpoint` and `zfs get mounted`.
- Fix automatic unlock when mounting at boot time:
    1. Copy `/lib/systemd/system/zfs-mount.service` to `/etc/systemd/system/`.
    1. Change `ExecStart=/sbin/zfs mount -a` to `ExecStart=/sbin/zfs mount -l -a` (add `-l`), so that it loads encryption keys.
    1. Reboot and test. It may fail due to dependency/boot order stuff.
- Create a password encrypted pool: `zpool create -O encryption=aes-128-gcm -O keyformat=passphrase ...`
- Create a raw key encrypted pool:
    - Generate the key: `dd if=/dev/random of=/root/.credentials/zfs/<tank> bs=32 count=1`
    - Create the pool: `zpool create -O encryption=aes-128-gcm -O keyformat=raw -O keylocation=file:///root/.credentials/zfs/<tank> ...`
- Encrypt an existing dataset by sending and receiving:
    1. Rename the old dataset: `zfs rename <dataset> <old-dataset>`
    1. Snapshot the old dataset: `zfs snapshot -r <dataset>@<snapshot>`
    1. Command: `zfs send [-R] <old-dataset> | zfs recv -o encryption=aes-128-gcm -o keyformat=raw -o keylocation=file:///root/.credentials/zfs/<tank> <new-dataset>`
    1. Test the new dataset.
    1. Delete the snapshots and the old dataset.
    - All child datasets will be encrypted too (if `-r` and `-R` were used).
    - The new dataset will become its own encryption root instead of inheriting from any parent dataset/pool.

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
