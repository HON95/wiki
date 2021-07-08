---
title: Computer Testing
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## CPU

### Prime95

- For stress testing.
- For most OSes.
- Install: [Download](https://www.mersenne.org/download/).

## RAM

### MemTest86 (Standalone)

- Runs multiple tests and passes over (almost) all the memory to test for errors.
- Useful for testing bad DIMMs and overclocking stability.
- Install: [Download](https://www.memtest86.com/download.htm)
    - Use v4 for systems without UEFI support.
- Not the same as "Memtest86+". Memtest86+ is an old fork of Memtest86.

### stress-ng (Linux)

- Among other usages, it can test a part of the memory (since the OS is running it obviously can't use everything).
- Useful for quickly finding severe memory errors without e.g. rebooting into MemTest.

Example usage:

```sh
# 1 stressor, 75% of memory (TODO this also works fine with 100% for some reason, find out what it actually means), with verification, for 10 minutes
stress-ng --vm 1 --vm-bytes 75% --vm-method all --verify -t 10m -v
```

### Error Detection and Correction (EDAC) (Linux)

- Only available on systems with ECC RAM, AFAIK.
- Check the syslog: `journalctl | grep 'EDAC' | grep -i 'error'`
- Show corrected (CE) and uncorrected (UE) errors per memory controller and DIMM slot: `grep '.*' /sys/devices/system/edac/mc/mc*/dimm*/dimm_*_count`
- Show DIMM slot names to help locate the faulty DIMM: `dmidecode -t memory | grep 'Locator:.*DIMM.*'`
- When changing the DIMM, make sure to run Memtest86 or similar both before and after to validate that the errors go away.

## Storage

### Fio (Linux)

- "Flexible I/O tester".
- For file-based disk benchmarking.
- Install (Debian): `apt install fio`
- Usage:
    - Add `--fsync=1` for synchronous IO.
    - Add `--time_based --runtime=<seconds>` to repeat the test for the provided duration.
    - Configuration arguments may be placed in a config file instead, specified as a positional argument to fio.
    - Note that write performance may sharply degrade after a while when the hardware write cache(s) fill up, so make sure the tests are run for long enough.
    - Examples: See below.

Examples usage:

```sh
# Sequential, asynchronous, 4kiB, random write
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=4G --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1

# 16 parallel, asynchronous, 64kiB, random write
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=64k --size=256M --numjobs=16 --iodepth=16 --runtime=60 --time_based --end_fsync=1

# Sequential, asynchronous, 1MiB, random write
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=1m --size=16G --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1
```

### smartmontools (Linux)

- For health testing.
- See [smartmontools](/config/linux-general/applications/#smartmontools).

## Miscellanea

### Linux

- Show CPU vulnerabilities: `tail -n +1 /sys/devices/system/cpu/vulnerabilities/*`
- PCIe link speed for device:
    - Make sure the device is doing something intensive so that the PCIe speed isn't degraded.
    - Run `sudo lspci -vv`, find the device (e.g. `NVIDIA Corporation TU102 [GeForce RTX 2080 Ti Rev. A]`) and look for the `LnkCap` and `LnkSta` lines under "Capabilities".
    - `LnkCap` is the device capability and `LnkSta` is the current status. Both show the (max and current) PCIe speed/version (speed for _around_ 8 lanes wrt. the specific version) and the number of lanes.
    - Example `LnkSta` (1): `Speed 16GT/s (ok), Width x16 (ok)`, meaning PCIe 4.0, using 16 lanes.
    - Example `LnkSta` (2): `Speed 8GT/s (ok), Width x4 (downgraded)`, meaning PCIe 3.0, downgraded to 4 lanes, e.g. if the motherboard doesn't support that many PCIe devices running at full widths.
    - PCIe speed cheat sheet:
        - PCIe 1 (2.5GT/s, 250MB/s per lane)
        - PCIe 2 (5GT/s, 500MB/s per lane)
        - PCIe 3 (8GT/s, 985MB/s per lane)
        - PCIe 4 (16GT/s, 1.97GB/s per lane)
        - PCIe 5 (32GT/s, 3.94GB/s per lane)
        - PCIe 6 (64GT/s, 7.88GB/s per lane)

{% include footer.md %}
