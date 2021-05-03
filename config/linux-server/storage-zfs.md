---
title: 'Linux Server Storage: ZFS'
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

Using ZFS on Linux (ZoL) running on Debian.

## Info

Note: ZFS's history (Oracle) and license (CDDL, which is incompatible with the Linux mainline kernel) are pretty good reasons to avoid ZFS.

### Features

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

### Terminology

- Vdev
- Pool
- Dataset
- Zvol
- ZFS POSIX Layer (ZPL)
- ZFS Intent Log (ZIL)
- Adaptive Replacement Cache (ARC) and L2ARC
- ZFS Event Daemon (ZED)

### Encryption

- ZoL v0.8.0 and newer supports native encryption of pools and datasets. This encrypts all data except some metadata like pool/dataset structure, dataset names and file sizes.
- Datasets can be scrubbed, resilvered, renamed and deleted without unlocking them first.
- Datasets will by default inherit encryption and the encryption key (the "encryption root") from the parent pool/dataset.
- The encryption suite can't be changed after creation, but the keyformat can.

## Setup

### Installation

The installation part is highly specific to Debian 10 (Buster). The backports repo is used to get the newest version of ZoL.

1. Enable the Buster backports repo: See [Backports (Debian Wiki)](https://wiki.debian.org/Backports)
    - Add the following lines to `/etc/apt/sources.list`
        ```
        deb http://deb.debian.org/debian buster-backports main contrib non-free
        deb-src http://deb.debian.org/debian buster-backports main contrib non-free
        ```
1. Install: `apt install -t buster-backports zfsutils-linux`
1. Fix automatic unlocking of encrypted pools/datasets:
    1. Copy `/lib/systemd/system/zfs-mount.service` to `/etc/systemd/system/`.
    1. In `zfs-mount.service`, change `ExecStart=/sbin/zfs mount -a` to `ExecStart=/sbin/zfs mount -l -a`, so that it loads encryption keys.
    1. Reboot and test. It may fail due to dependency/boot order stuff.
1. (Optional) Fix pool cache causing pool loading problems at boot:
    1. Note: Do this if `systemctl status zfs-import-cache.service` shows that no pools were found. I had significant problems with this multiple times with Proxmox VE on an older server.
    1. Make sure the pools are not set to use a cache file: `zpool get cachefile` and `zpool set cachefile=none <pool>`
    1. Copy `/lib/systemd/system/zfs-import-scan.service` to `/etc/systemd/system/`.
    1. In `zfs-mount.service`, comment the `ConditionFileNotEmpty=!/etc/zfs/zpool.cache` line (the file tends to find a way back to existance).
    1. Update systemd files: `systemctl daemon-reload`
    1. Disable the caching import service: `systemctl disable zfs-import-cache.service`
    1. Enable the scanning import service: `systemctl enable zfs-import-scan.service`
    1. Delete the existing cache file: `rm /etc/zfs/zpool.cache`
    1. In `/etc/default/zfs`, set:
        - `ZPOOL_CACHE=''` (no cache file)
        - `ZFS_INITRD_PRE_MOUNTROOT_SLEEP='5'` (or higher)
        - `ZFS_INITRD_POST_MODPROBE_SLEEP='5'` (or higher)
    1. Update initramfs: `update-initramfs -u -k all`
    1. Reboot.
    1. Check if the pools are loaded correctly _at boot_ (see `systemctl status zfs-import-cache.service`).

### Configuration

1. (Optional) Set the max ARC size:
    - Command: `echo "options zfs zfs_arc_max=<bytes>" >> /etc/modprobe.d/zfs.conf`
    - It should typically be around 15-25% of the physical RAM size on general nodes. It defaults to 50%.
    - This is generally not required, ZFS should happily yield RAM to other processes that need it.
1. Check that the cron scrub script exists:
    - Typical location: `/etc/cron.d/zfsutils-linux`
    - If it doesn't exist, add one which runs `/usr/lib/zfs-linux/scrub` e.g. monthly. It'll scrub all disks.
1. Check that ZED is set up to send emails:
    - In `/etc/zfs/zed.d/zed.rc`, make sure `ZED_EMAIL_ADDR="root"` is uncommented.

## Usage

### General

- Show version: `zfs --version` or `modinfo zfs | grep '^version:'`
    - The kernel module and userland tools should match.
- Be super careful when destroying stuff! ZFS never asks for confirmation.
    - When entering dangerous commands, considering adding a `#` to the start to prevent running it half-way by accident.

### Pools

- Recommended pool options:
    - Set physical block/sector size: `ashift=<9|12>`
        - Use 9 for 512 (2^9) and 12 for 4096 (2^12). Use 12 if unsure (bigger is safer).
    - Enable compression: `compression=zstd`
        - Use `lz4` for boot drives (`zstd` booting isn't currently supported) or if `zstd` isn't yet available in the version you're using.
    - Store extended attributes in the inodes: `xattr=sa`
        - `on` is default and stores them in a hidden file.
    - Relax access times: `atime=off` and `relatime=on`
    - Don't enable dedup.
- Create pool:
    - Format: `zpool create [options] <name> <levels-and-drives>`
    - Basic example: `zpool create -o ashift=<9|12> -O compression=zstd -O xattr=sa <name> [mirror|raidz|raidz2|...] <drives>`
    - Create encrypted pool: See encryption section.
    - Use absolute drive paths (`/dev/disk/by-id/` or similar).
- View pool activity: `zpool iostat [-v] [interval]`
    - Includes metadata operations.
    - If no interval is specified, the operations and bandwidths are averaged from the system boot. If an interval is specified, the very first interval will still show this.

### Datasets

- List datasets: `zfs list [-t {filesystem|volume|snapshot|bookmark}] [-r] [dataset]`
- Recommended dataset options:
    - Set quota: `quota=<size>`
    - Set reservation: `reservation=<size>`
    - (See the recommended pool options since most are inherited.)
- Create dataset:
    - Format: `zfs create [options] <pool>/<name>`
    - Use `-p` to create parent datasets if they maybe don't exist.
    - Basic example: `zfs create -o quota=<size> -o reservation=<size> <pool>/<other-datasets>/<name>`
- Properties:
    - Properties may have the following sources, as seen in the "source" column: Local, default, inherited, temporary, received and none.
    - Get: `zfs get {all|<property>} [-r] [dataset]` (`-r` for recursive)
    - Set: `zfs set <property>=<value> <dataset>`
    - Reset to default/inherit: `zfs inherit -S [-r] <property> <dataset>` (`-r` for recursive, `-S` to use the received value if one exists)
- Don't store anything in the root dataset itself, since it can't be replicated.

### Snapshots

- Create snapshot: `zfs snapshot [-r] <dataset>@<snapshot>`
    - `-r` for "recursive".
- Destroy snapshot: `zfs destroy [-r] <dataset>@<snapshot>`

### Transfers

- `zfs send` sends to STDOUT and `zfs recv` receives from STDIN.
- Send basic: `zfs send [-R] <snapshot>`
    - `-R` for "replication" to include descendant datasets, snapshots, clones and properties.
- Receive basic: `zfs recv -Fus <snapshot>`
    - `-F` to destroy existing datasets and snapshots.
    - `-u` to avoid mounting it.
    - `-s` to save a resumable token in case the transfer is interrupted.
- Send incremental: `zfs send {-i|-I} <first-snapshot> <last-snapshot>`
    - `-i` sends the delta for a between two snapshots while `-I` sends for the whole range of snapshots between the two mentioned.
    - The first snapshot may be specified without the dataset name.
- Resume interrupted transfer started with `recv -s`: Use `zfs get receive_resume_token` and `zfs send -t <token>`.
- Send encrypted snapshots: See encryption subsection.
- Send encrypted snapshot over SSH (full example): `sudo zfs send -Rw tank1@1 | pv | ssh node2 sudo zfs recv tank2/tank1`
    - Make sure you don't need to enter a sudo password on the other node, that would break the piped transfer.
- Consider running it in a screen session or something to avoid interruption.
- To show transfer info (duration, size, throughput), pipe it through `pv`. To rate limit, specify e.g. `-L 8M` (8MiB/s).

### Encryption

- Show stuff:
    - Encryption root: `zfs get encryptionroot`
    - Key status: `zfs get keystatus`. `unavailable` means locked and `-` means not encrypted.
    - Mount status: `zfs get mountpoint` and `zfs get mounted`.
- Create a password encrypted pool:
    - Create: `zpool create -O encryption=aes-128-gcm -O keyformat=passphrase ...`
- Create a raw key encrypted pool:
    - Generate the key: `dd if=/dev/urandom of=/root/keys/zfs/<tank> bs=32 count=1`
    - Create: `zpool create <normal-options> -O encryption=aes-128-gcm -O keyformat=raw -O keylocation=file:///root/keys/zfs/<tank> <name> ...`
- Encrypt an existing dataset by sending and receiving:
    1. Rename the old dataset: `zfs rename <dataset> <old-dataset>`
    1. Snapshot the old dataset: `zfs snapshot -r <dataset>@<snapshot-name>`
    1. Command: `zfs send [-R] <snapshot> | zfs recv -o encryption=aes-128-gcm -o keyformat=raw -o keylocation=file:///root/keys/zfs/<tank> <new-dataset>`
    1. Test the new dataset.
    1. Delete the snapshots and the old dataset.
    1. Note: All child datasets will be encrypted too (if `-r` and `-R` were used).
    1. Note: The new dataset will become its own encryption root instead of inheriting from any parent dataset/pool.
- Change encryption property:
    - The key must generally already be loaded.
    - Change `keyformat`, `keylocation` or `pbkdf2iters`: `zfs change-key -o <property>=<value> <dataset>`
    - Inherit key from parent: `zfs change-key -i <dataset>`
- Send raw encrypted snapshot:
    - Example: `zfs send -Rw <dataset>@<snapshot> | <...> | zfs recv <dataset>`
    - As with normal sends, `-R` is useful for including snapshots and metadata.
    - Sending encrypted datasets requires using raw (`-w`).
    - Encrypted snapshots sent as raw may be sent incrementally.

### Error Handling and Replacement

- Clear transient device errors: `zpool clear <pool> [device]`
- If a pool is "UNAVAIL", it means it can't be recovered without corrupted data.
- Replace a device and automatically copy data from the old device or from redundant devices: `zpool replace <pool> <old-device> <new-device>`
- Bring a device online or offline: `zpool (online|offline) <pool> <device>`
- Re-add device that got wiped: Take it offline and then online again.

### Miscellanea

- Add bind mount targeting ZFS mount:
    - fstab entry (example): `/bravo/abc /export/abc none bind,defaults,nofail,x-systemd.requires=zfs-mount.service 0 0`
    - The `x-systemd.requires=zfs-mount.service` is required to wait until ZFS has mounted the dataset.
- Upgrade pool to support new features: `zpool upgrade <pool>`
    - `zpool status` shows if any pool required upgrades.
    - This is needed/recommended after upgrading ZFS.
- For automatic creation and rotation of periodic snapshots, see the zfs-auto-snapshot subsection.

## Best Practices and Suggestions

- As far as possible, use raw disks and HBA disk controllers (or RAID controllers in IT mode).
- Always use `/etc/disk/by-id/X`, not `/dev/sdX`.
- Always manually set the correct ashift for pools.
    - Should be the log-2 of the physical block/sector size of the device.
    - E.g. 12 for 4kB (Advanced Format (AF), common on HDDs) and 9 for 512B (common on SSDs).
    - Check the physical block size with `smartctl -i <dev>`.
    - Keep in mind that some 4kB disks emulate/report 512B. They should be used as 4kB disks.
- Always enable compression on datasets (or pools so all datasets inherit it).
    - Generally `zstd`, but `lz4` for bootable pools or old installations without `zstd` support.
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
- Snapshots are great for incremental backups. They're easy to send places.
- Use quotas, reservations and compression.
- Database:
    - Set `atime=off` and `relatime=on` instead (avoid updating access time way too often due to frequent reads).
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

## Extra Notes

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

## Troubleshooting

**"cannot create 'pool': URI scheme is not supported"**:

Reboot.

## Related Software

### zfs-auto-snapshot

See [zfsonlinux/zfs-auto-snapshot (GitHub)](https://github.com/zfsonlinux/zfs-auto-snapshot/).

- zfs-auto-snapshot automatically creates and rotates a certain number of snapshots for all/some datasets.
- The project seems to be pretty dead, but it still works. Most alternatives are way more complex.
- It uses a `zfs-auto-snapshot` script in each of the `cron.*` dirs, which may be modified to tweak things.
- It uses the following intervals to snapshot all enabled datasets: `frequent` (15 minutes), `hourly`, `daily`, `weekly`, `monthly`
- Installation: `apt install zfs-auto-snapshot`
- By default it's enabled for all datasets. To disable it by default, add `--default-exclude` to each of the cron scripts, so that it's only enabled for datasets with property `com.sun:auto-snapshot` set to true.

{% include footer.md %}
