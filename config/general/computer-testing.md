---
title: Computer Testing
breadcrumbs:
- title: Configuration
- title: General
---
{% include header.md %}

## Information Gathering

### Linux

- Show CPU vulnerabilities: `tail -n +1 /sys/devices/system/cpu/vulnerabilities/*`

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
# 1 stressor, 75% of memory, with verification, for 10 minutes
stress-ng --vm 1 --vm-bytes 75% --vm-method all --verify -t 10m -v
```

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

{% include footer.md %}
