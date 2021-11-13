---
title: Betzy (Supercomputer)
breadcrumbs:
- title: Miscellanea
---
{% include header.md %}

Norway's most powerful supercomputer as of its inauguration in late 2020.
Managed by UNINETT Sigma2 and partially NTNU Trondheim.

## Resources

- [Betzy (TOP500)](https://www.top500.org/system/179861/)
- [Betzy documentation (Sigma2)](https://documentation.sigma2.no/hpc_machines/betzy.html)

## History

- 2018: Procurement started. \[13\]
- June 2020: Placed #55 on the TOP500 list. \[12\]
- 7 December 2020: Inauguration. \[11\]
- April 2021: Four new X2415 blades (A100) and 5.3PB more storage (from 2.5PB to 7.8PB). \[10\]

## Specifications

A mix of general XH2000 specifications and specific Betzy specifications.

- Betzy overall specifications \[1\]\[2\]\[5\]\[9\]\[10\]:
    - System: Atos BullSequana XH2000 with X2410 (AMD EPYC) and X2415 (NVIDIA A100) blades.
    - OS: RHEL
    - Compute nodes: 1344 X2410 (AMD EPYC) (448 blades) + 4 X2415 (NVIDIA A100)
    - CPUs total (excluding A100 nodes): 2688 CPUs, 172032 cores
    - Memory: 336TiB total (excluding A100 nodes)
    - Storage: 7.8PB (2.5PB before 2021 upgrade), DNN powered, Lustre, 51GB/s bandwidth, 500k+ metadata OPS (before 2021 upgrade)
    - Interconnect topology: DragonFly+ topology
    - Queueing system: Slurm
    - Footprint: 14.78m2 (before 2021 upgrade)
    - Power: 952kW, 95% of heat captured to water (before 2021 upgrade)
    - Cooling: Liquid cooled
- CPU node specifications (CPU nodes) \[1\]\[2\]\[4\]:
    - AMD EPYC Rome 7742
        - 64 cores, 128 threads (per CPU)
        - Clock: 2.25GHz base, 3.4GHz max boost
        - Memory: DDR4, 8 channels, 3200MHz, 204.8GB/s per-socket BW
        - PCIe: 4.0, x128
    - Memory: 256GiB, split into 8 NUMA nodes
    - Storage: 3x SATA or NVMe M.2 drives
    - NIC: InfiniBand HDR 100
- CPU node specifications (GPU nodes) \[0\]\[14\]:
    - CPUs: 2x AMD EPYC Rome 7452
        - 32 cores, 64 threads (per CPU)
        - Clock: 2.35GHz base, 3.35GHz max boost
        - Memory: DDR4, 8 channels, 3200MHz, 204.8GB/s per-socket BW
        - PCIe: 4.0, x128
- Blade specifications \[9\]:
    - Betzy uses mainly X2410 blades (AMD), but also 4x X2415 blades (A100) (after the 2021 upgrade) \[10\].
    - Size: 1U
    - Cooling: Fanless, active liquid cooling.
    - All blades types (both used and not used):
        - X2410: 3x nodes (side-by-side) with 2x AMD EPYC Rome/Milan CPUs (6 CPUs total).
        - X2415: 1x node with 2x AMD EPYC Rome/Milan CPUs and 4x Nvidia A100 SXM4 GPUs.
        - X1120: 3x nodes (side-by-side) with 2x Intel Xeon CPUs (6 CPUs total).
        - X1125: 1x node with 2x Intel CPUs and 4x Nvidia V100 SXM2 GPUs.
- Cabinet specifications (general, not Betzy specific) \[8\]\[9\]:
    - Number of blades: 4-20 in front, 4-12 in back
    - Management switches:
        - Up to 2.
        - Up to 48 1Gb/s or 10Gb/s ports.
    - Interconnect switches:
    - Up to 10.
    - Infiniband HDR100: 80 ports, 100Gb/s (Betzy)
    - Alternative technologies:
        - Bull eXascale Interconnect (BXI): 48 ports, 100Gb/s
        - High-speed Ethernet: Up to 48 ports, up to 100Gb/s
    - Supported interconnect topologies:
        - DragonFly+
        - Full Fat Tree
    - PSU: 6x 15kW shelves
    - Power input: 3x 63A 3-phase 400V (for EU)
    - Cooling:
        - Direct Liquid Cooling (DLC)
        - Hydraulic chassis (HYC)
        - Primary (external) loop connected to customer water loop.
        - Secondary (internal) loop connected to blades, management switches, interconnect switches and PSUs.

## References

- \[0\] Unofficial sources.
- \[1\] UNINETT Sigma2. "Betzy." (Accessed 2020-09-03.) https://documentation.sigma2.no/hpc_machines/betzy.html
- \[2\] UNINETT Sigma2. "Betzy Pilot Projects." (Accessed 2020-09-03.) https://documentation.sigma2.no/hpc_machines/betzy/betzy_pilot.html
- \[3\] SPEC CPU 2017 Integer Rate Result for Atos BullSequana XH2000 (1 socket)
- \[4\] AMD EPYC 7742. (Accessed 2020-09-03.) https://www.amd.com/en/products/cpu/amd-epyc-7742
- \[5\] Atos. "Atos to deliver most powerful supercomputer in Norway to national e-infrastructure provider Uninett Sigma2." (Accessed 2020-09-03.) https://atos.net/en/2019/press-release_2019_06_06/atos-to-deliver-most-powerful-supercomputer-in-norway-to-national-e-infrastructure-provider-uninett-sigma2
- \[6\] Atos. "Atos expands BullSequana X supercomputer range to include AMD processors." (Accessed 2020-09-03.) https://atos.net/en/2018/news_2018_11_12/atos-expands-bullsequana-x-supercomputer-range-include-amd-processors
- \[8\] Atos. "BullSequana XH2000 brochure." (Accessed 2020-09-03.) https://atos.net/wp-content/uploads/2019/11/BullSequana_XH2000_Brochure_Atos.pdf
- \[9\] Atos. "BullSequana XH2000 features." (Accessed 2020-09-03.) https://atos.net/wp-content/uploads/2020/07/BullSequanaXH2000_Features_Atos_supercomputers.pdf
- \[10\] Digi.no. "Sigma2 skal utvide to av de norske superdatamaskinene." (Accessed 2021-04-21.) https://www.digi.no/artikler/sigma2-skal-utvide-to-av-de-norske-superdatamaskinene/509303
- \[11\] UNINETT Sigma2. "Betzy Inauguration." (Accessed 2021-04-21.) https://www.sigma2.no/betzy-inauguration
- \[12\] TOP500. "Betzy." (Accessed 2021-04-25.) https://top500.org/system/179861/
- \[13\] UNINETT Sigma2. "Procurement Project HPC B1 (Betzy)." (Accessed 2021-04-25.) https://www.sigma2.no/procurement-project-hpc-b1
- \[14\] AMD EPYC 7452. (Accessed 2021-05-03.) https://www.amd.com/en/products/cpu/amd-epyc-7452

{% include footer.md %}
