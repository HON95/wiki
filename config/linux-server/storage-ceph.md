---
title: 'Linux Server Storage: Ceph'
breadcrumbs:
- title: Configuration
- title: Linux Server
---
{% include header.md %}

Using Debian.

## Resources

- (Ceph: Ceph PGs per Pool Calculator)[https://ceph.com/pgcalc/]
- (Ceph Documentation: Placement Group States)[https://docs.ceph.com/docs/mimic/rados/operations/pg-states/]

## Info

- Distributed storage for HA.
- Redundant and self-healing without any single point of failure.
- The Ceph Storeage Cluster consists of:
    - Monitors (typically one per node) for monitoring the state of itself and other nodes.
    - Managers (at least two for HA) for serving metrics and statuses to users and external services.
    - OSDs (object storage daemon) (one per disk) for handles storing of data, replication, etc.
    - Metadata Servers (MDSes) for storing metadata for POSIX file systems to function properly and efficiently.
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

## Guidelines

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

## Usage

- General:
    - List pools: `rados lspools` or `ceph osd lspools`
- Show utilization:
    - `rados df`
    - `ceph df [detail]`
    - `deph osd df`
- Show health and status:
    - `ceph status`
    - `ceph health [detail]`
    - `ceph osd stat`
    - `ceph osd tree`
    - `ceph mon stat`
    - `ceph osd perf`
    - `ceph osd pool stats`
    - `ceph pg dump pgs_brief`
- Pools:
    - Create: `ceph osd pool create <pool> <pg-num>`
    - Delete: `ceph osd pool delete <pool> [<pool> --yes-i-really-mean-it]`
    - Rename: `ceph osd pool rename <old-name> <new-name>`
    - Make or delete snapshot: `ceph osd pool <mksnap|rmsnap> <pool> <snap>`
    - Set or get values: `ceph osd pool <set|get> <pool> <key>`
    - Set quota: `ceph osd pool set-quota <pool> [max_objects <count>] [max_bytes <bytes>]`
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

### Failure Handling

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

### OSD Replacement

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
1. Create new OSD: `pveceph osd create <dev> [options]` (Proxmox VE)
    - Optionally specify any WAL or DB devices.
    - See [PVE: pveceph(1)](https://pve.proxmox.com/pve-docs/pveceph.1.html).
    - Without PVE's `pveceph(1)`, a series of steps are required.
    - Check that the new OSD is up: `ceph osd tree`
1. Start the OSD daemon: `systemctl start ceph-osd@<id>`
1. Wait for rebalancing: `ceph -s [-w]`
1. Check the health: `ceph health [detail]`

{% include footer.md %}
