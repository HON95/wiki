---
title: ZFS
breadcrumbs:
- title: Linux Servers
---
{% include header.md %}

Using ZFS on Linux (ZoL).

## Info

- ZFS's history (Oracle) and license (CDDL, which is incompatible with the Linux mainline kernel) are acceptable reasons to avoid ZFS.
- Reasons ZFS is great:
    - Everything checksummed (RIP bit rot).
    - Copy-on-write (CoW).
    - Always consistent.
    - Integrated physical volume manager.
    - RAID.
    - Encryption.
    - Compression.
    - Deduplication.
    - Cloning.
    - Snapshots.
    - Extensible caching (ARC, L2ARC, SLOG, special devices).

## Setup (Debian)

### Installation (Debian 11)

1. Install: `apt install zfsutils-linux`

### Installation (Debian 10)

The backports repo is used to get the newest version of ZoL.

1. Enable the Buster backports repo: See [Backports (Debian Wiki)](https://wiki.debian.org/Backports)
    - Add the following lines to `/etc/apt/sources.list`
        ```
        deb http://deb.debian.org/debian buster-backports main contrib non-free
        deb-src http://deb.debian.org/debian buster-backports main contrib non-free
        ```
1. Install: `apt install -t buster-backports zfsutils-linux`

### Configuration (Debian)

1. (Typically not needed) Check that the cron scrub script exists:
    - Typical location: `/etc/cron.d/zfsutils-linux`
    - If it doesn't exist, add one which runs `/usr/lib/zfs-linux/scrub` e.g. monthly. It'll scrub all disks.
1. (Typically not needed) Check that ZED is working:
    - ZEDLET: `/etc/zfs/zed.d/history_event-zfs-list-cacher.sh` should point to `/usr/lib/zfs-linux/zed.d/history_event-zfs-list-cacher.sh`.
    - Email sending: In `/etc/zfs/zed.d/zed.rc`, make sure `ZED_EMAIL_ADDR="root"` is uncommented.,
    - Service: `zfs-zed.service` should be enabled.
1. (Optional) Set the max ARC size:
    - Command: `echo "options zfs zfs_arc_max=$((<gigabytes>*1024*1024*1024))" >> /etc/modprobe.d/zfs.conf`
    - It should typically be around 15-25% of the physical RAM size on general nodes. It defaults to 50%.
    - This is generally not required, ZFS should happily yield RAM to other processes that need it.
1. (Optional) Automatically load key (if encrypted) and mount pool/dataset on boot: See encryption section.
1. (Optional) Fix pool cache causing pool loading problems at boot:
    1. (Note) Do this if `systemctl status zfs-import-cache.service` shows that no pools were found. I had significant problems with this multiple times with Proxmox VE on an older server.
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

## Usage

### General

- Show version: `zfs --version` or `modinfo zfs | grep '^version:'`
    - The kernel module and userland tools should match.
- Be super careful when destroying stuff! ZFS never asks for confirmation.
    - When entering dangerous commands, considering adding a `#` to the start to prevent running it half-way by accident.

### Pools

- Create pool:
    - Format: `zpool create [options] <name> <levels-and-drives>`
    - Basic example: `zpool create [-f] [options] <name> {[mirror|raidz|raidz2|spare|...] <drives>}+`
        - Use `-f` (force) if the disks aren't clean.
        - See example above for recommended options.
    - Recommended example: `zpool create -o ashift=<9|12> -o autotrim=on -O compression=zstd -O xattr=sa -O dnodesize=auto -O atime=off -O relatime=on <pool> <disks>` (`autotrim` only for SSDs)
    - Specifying options during creation: For `zpool`/pools, use `-o` for pool options and `-O` for dataset options. For `zfs`/datasets, use `-o` for dataset options.
    - Set physical block/sector size (pool option): `ashift=<9|12>`
        - Use 9 for 512 (2^9) and 12 for 4096 (2^12). Use 12 if unsure (bigger is safer).
    - Enable TRIM (for SSDs): `autotrim=on`
        - Auto-trim is the continuous type (not periodic), but it avoids trimming if the deleted range is too small to avoid excessive load.
        - It's also somewhat recommended to create a cron job to run `zpool trim <pool>` periodically for the SSD pool.
    - Enable autoreplacement for new disks in the same physical slot as old ones (using ZED): `autoreplace=on`
    - Enable compression (dataset option): `compression=zstd`
        - Use `lz4` for boot drives (`zstd` booting isn't currently supported) or if `zstd` isn't yet available in the version you're using.
    - Store extended attributes in the inodes/dnodes (dataset option): `xattr=sa` and `dnodesize=auto`
        - The default for `xattr` is `on`, which stores them in a hidden file.
        - `dnodesize=auto` allows for bigger dnodes and is typically used with `xattr=sa`.
        - GRUB doesn't support `dnodesize=auto`, so never use it on ZFS boot pools.
    - Relax access times (dataset option): `atime=off` and `relatime=on`
    - Don't enable dedup.
    - Use absolute drive paths (`/dev/disk/by-id/` or similar), not `/dev/sdX`.
    - The pool definition is two-level hierarchical, where top-level elements are striped. Examples:
        - RAID 0 (striped): `<drives>`
        - RAID 1 (mirrored): `mirror <drives>`
        - RAID 10 (stripe of mirrors): `mirror <drives> mirror <drives>`
        - RAID 50 (stripe of mirrors): `raidz <drives> raidz <drives>`
    - Create encrypted pool: See encryption section.
    - Add special device: See special device section.
    - Add hot spare (if after creation): `zpool add <pool> spare <disks>`
        - Note that hot spares are currently a bit broken and don't automatically replace pool disks. Make sure to test the setup before relying on it.
- View pool activity: `zpool iostat [-v] [interval]`
    - Includes metadata operations.
    - If no interval is specified, the operations and bandwidths are averaged from the system boot. If an interval is specified, the very first interval will still show this.

#### L2ARC

- Info:
    - The L2ARC works as a second tier cache and is kept on a separate disk instead of in memory.
    - Dirty content is never stored in the L2ARC and all data in it is also kept on disk, so it doesn't _need_ any kind of redundancy and can die without causing significant trouble.
    - It works only as a read cache since it can't contain dirty data.
    - It's most useful running itself on a fast SSD with the rest of the pool on a slow HDD array.
    - Using an L2ARC requires more memory as well as some metadata about it must be stored in the ARC, so it's not meant as a direct replacement for getting more memory.
    - For encrypted pools, data in the L2ARC is always encrypted.
- Adding L2ARC device: `zpool add [-f] <pool> cache <drive>`

#### SLOG

- Info:
    - The separate intent log (SLOG) is a drive used to contain the ZFS intent log (ZIL) for a pool, effectively becoming a write cache.
    - It only has effect for synchronized writes (which generally aren't used for many use cases for pools), since unsynchronized writes are cached in memory.
    - It's most useful running itself on a fast SSD with the rest of the pool on a slow HDD array.
    - The drive must have high write durability.
    - Since data can get lost if it dies, it should have an appropriate level of redundancy, on par with the rest of the pool.
- Adding SLOG device: `zpool add [-f] <pool> log <drive-config>` (e.g. `mirror drive-1 drive-2`)

#### Special Device

- Info:
    - A _special_ drive may be added to a pool to store metadata (in order to speed up e.g. directory traversal) and optionally very small files.
    - It's most useful running itself on a fast SSD with the rest of the pool on a slow HDD array.
    - The special device generally needs the same kind of redundancy as the rest of the pool as it's not recoverable and will take the whole pool with it if it dies.
    - If it gets full, it simply overflows back into the data array of the pool.
    - More practical info: [ZFS Metadata Special Device: Z (Level1Techs Forums)](https://forum.level1techs.com/t/zfs-metadata-special-device-z/159954)
- **TODO**

### Datasets

- See the "pools" section for more info, especially the `-O` options there which actually apply to datasets and not pools.
- Basics:
    - List datasets: `zfs list [-t {filesystem|volume|snapshot|bookmark}] [-r] [dataset]`
    - Check if mounted: `zfs get mounted -t filesystem`
    - Check if unlocked (if encrypted): `zfs get keystatus`
- Recommended dataset options:
    - Set quota: `quota=<size>`
    - Set reservation: `reservation=<size>`
    - Disable data caching (in the ARC), if the upper layer already uses caching (databases, VMs, etc.): `primarycache=metadata`
    - Unset the mountpoint, e.g. if it will only be a parent of volumes: `mountpoint=none`
    - (See the recommended pool options since most are inherited.)
- Create dataset:
    - Format: `zfs create [options] <pool>/<name>`
    - Use `-p` to create parent datasets if they maybe don't exist.
    - Basic example: `zfs create -o quota=<size> -o reservation=<size> <pool>/<other-datasets>/<name>`
- Properties management:
    - Properties may have the following sources, as seen in the "source" column: Local, default, inherited, temporary, received and none.
    - Get: `zfs get {all|<property>} [-r] [dataset]` (`-r` for recursive)
    - Set: `zfs set <property>=<value> <dataset>`
    - Unset: `zfs set <property>=none <dataset>` (keeps source "local")
    - Inherit: `zfs inherit [-r] [dataset]` (`-r` for recursive, `-S` to use the received value if one exists)
        - See the encryption section for inheritance of certain encryption properties.
- Other useful dataset properties:
    - `canmount={on|off|noauto}`: If the dataset will be mounted by `zfs mount` or `zfs mount -a`. Set to no if it shouldn't be mounted automatically e.g. during boot.
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

- Info:
    - ZoL v0.8.0 and newer supports native encryption of pools and datasets. This encrypts all data except some metadata like pool/dataset structure, dataset names and file sizes.
    - Datasets can be scrubbed, resilvered, renamed and deleted without unlocking them first.
    - Datasets will by default inherit encryption and the encryption key from the parent pool/dataset (or the nearest "encryption root").
    - The encryption suite can't be changed after creation, but the keyformat can.
    - Snapshots and clones always inherit from the original dataset.
- Show stuff:
    - Encryption: `zfs get encryption` (`off` means unencrypted, otherwise it shows the alg.)
    - Encryption root: `zfs get encryptionroot`
    - Key format: `zfs get keyformat`
    - Key location: `zfs get keylocation` (only shows for the encryption root and `none` for encrypted children)
    - Key status: `zfs get keystatus` (`available` means unlocked, `unavailable` means locked and `-` means not encrypted or snapshot)
    - Mount status: `zfs get mountpoint` and `zfs get mounted`.
- Locking and unlocking:
    - Manually unlock: `zfs load-key <dataset>`
    - Manually lock: `zfs unload-key <dataset>`
    - Automatically unlock and mount everything: `zfs mount -la` (`-l` to load key, `-a` for all)
- Create a password encrypted pool:
    - Create: `zpool create -O encryption=aes-128-gcm -O keyformat=passphrase ...`
- Create a raw key encrypted pool:
    - Generate the key: `dd if=/dev/urandom of=/var/keys/zfs/<tank> bs=32 count=1` (and fix permissions)
    - Create: `zpool create <normal-options> -O encryption=aes-128-gcm -O keyformat=raw -O keylocation=file:///var/keys/zfs/<tank> <name> ...`
- Encrypt an existing dataset by sending and receiving:
    1. Rename the old dataset: `zfs rename <dataset> <old-dataset>`
    1. Snapshot the old dataset: `zfs snapshot -r <dataset>@<snapshot-name>`
    1. Command: `zfs send [-R] <snapshot> | zfs recv -o encryption=aes-128-gcm -o keyformat=raw -o keylocation=file:///var/keys/zfs/<tank> <new-dataset>`
    1. Test the new dataset.
    1. Delete the snapshots and the old dataset.
    1. (Note) All child datasets will be encrypted too (if `-r` and `-R` were used).
    1. (Note) The new dataset will become its own encryption root instead of inheriting from any parent dataset/pool.
- Change encryption property:
    - The key must generally already be loaded.
    - The encryption properties `keyformat`, `keylocation` and `pbkdf2iters` are inherited from the encryptionroot instead, unlike normal properties.
    - Show encryptionroot: `zfs get encryptionroot`
    - Change encryption properties: `zfs change-key -o <property>=<value> <dataset>`
    - Change key location for locked dataset: `zfs set keylocation=file://<file> <dataset>` (**TODO** difference between `zfs set keylocation= ...` and `zfs change-key -o keylocation= ...`?)
    - Inherit key from parent (join parent encryption root): `zfs change-key -i <dataset>`
- Send raw encrypted snapshot:
    - Example: `zfs send -Rw <dataset>@<snapshot> | <...> | zfs recv <dataset>`
    - As with normal sends, `-R` is useful for including snapshots and metadata.
    - Sending encrypted datasets requires using raw (`-w`).
    - Encrypted snapshots sent as raw may be sent incrementally.
    - Make sure to check the encryption root, key format, key location etc. to make sure they're what they should be.
- Automatically load key (if encrypted) and mount on boot:
    - (Note) This will load all keys and mount everything (unless `canmount=off`) within the pool by generating mounting and key-load services at boot. Key-load services for encrypted roots will be generated regardless of `canmount`, use `org.openzfs.systemd:ignore=on` to avoid creating any services for the dataset.
    - Make sure ZED is set up correctly (see config section).
    - Enable tracking for the pool: `mkdir /etc/zfs/zfs-list.cache && touch /etc/zfs/zfs-list.cache/<pool>`
    - Trigger an update of the stale cache file: `zfs set canmount=on <pool>`
    - (Optional) Don't automatically decrypt and mount a dataset: Set `org.openzfs.systemd:ignore=on` on it.

### Error Handling and Replacement

- Clear transient drive error counters: `zpool clear <pool> [drive]`
- If a pool is "UNAVAIL", it means it can't be recovered without corrupted data.
- Replace a drive and begin resilvering: `zpool replace [-f] <pool> <old-drive> <new-drive>`
- Bring a drive online or offline: `zpool (online|offline) <pool> <drive>`
- Re-add drive that got wiped: Take it offline and then online again.
- Spares:
    - (See the pool section.)
    - Note that hot spares are currently a bit broken and don't automatically replace pool disks. Make sure to test the setup before relying on it.
    - When replacing pool disks with spare disks, they will show both as part of the pool and as "INUSE" spares. This is becayse spares are meant as _temporary_ replacements.
- Enable or disable automatically formatting and using a new disk physically installed in the same slot as a previous disk (using ZED): `zpool set autoreplace=on <pool>`
    - This does the same as `zpool replace [-f] <pool> <device>` (no new device specified, the paths are the same), but automatically.
    - This feature is broken in ZED version 0.8-something ([bug](https://github.com/openzfs/zfs/pull/10730)).

### Events

- Events are handled by ZED (ZFS Event Daemon).
- ZED hangles e.g. sending emails when disks go bad, replacing disks, custom scripts, etc.
- See event log: `zpool events [-vf] [pool]`
    - `-v` for verbose.
    - `-f` for follow.

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
    - Using `/dev/sdX` may degrade/fail the pool if the active disks are swapped or the numbering is shuffled for some reason.
    - Pool info is stored on the disks themselves, so running an `zpool export <pool> && zpool import <pool>` may fix disks that got degraded due to number shuffling.
    - If you want auto-replacement wrt. physical slots, you need to use whatever naming works for the physical slots.
- Always manually set the correct ashift for pools.
    - Should be the log-2 of the physical block/sector size of the drive.
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
    - Disable data caching (in the ARC) with `primarycache=metadata`. DMBSes typically handle caching themselves.
        - For InnoDB.
        - For PostgreSQL if the working set fits in RAM.
    - Disable the ZIL with `logbias=throughput` to prevent writing twice.
        - For InnoDB and PostgreSQL.
        - Consider not using it for high-traffic applications.
    - PostgreSQL:
        - Use the same dataset for data and logs.
        - Use one dataset per database instance, if practically possible. Requires you to specify it when creating the database.
        - Don't use PostgreSQL checksums or compression.
        - Example: `su postgres -c 'initdb --no-locale -E=UTF8 -n -N -D /db/pgdb1'`

## Extra Notes

- ECC memory is recommended but not required. It does not affect data corruption on disk.
- It does not require large amounts of memory, but more memory allows it to cache more data. A minimum of around 1GB is suggested. Memory caching is termed ARC. By default it's limited to 1/2 of all available RAM. Under memory pressure, it releases some of it to other applications.
- Compressed ARC is a feature which compresses and checksums the ARC. It's enabled by default.
- Intel Optane is a perfect choice as both L2ARCs and SLOGs due to its high throughput, low latency and high durability.
- Some SSD models come with a build-in cache. Make sure it actually flushes it on power loss.
- ZFS is always consistent, even in case of data loss.
- Bitrot is real.
    - 4.2% to 34% of SSDs have a UBER (uncorrectable bit error rate) of at least 1 per year.
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
