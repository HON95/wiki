---
title: Vilje (Supercomputer)
breadcrumbs:
- title: Miscellanea
---
{% include header.md %}

Norway's most powerful supercomputer as of when its procurement finished in 2012.
Managed by UNINETT Sigma2 and NTNU Trondheim.
In addition to research, it was used for numerical weather prediction for MET.

## Resources

- [Vilje (TOP500)](https://www.top500.org/system/177817/)
- [About Vilje (NTNU HPC)](https://www.hpc.ntnu.no/ntnu-hpc-group/vilje/about-vilje)

## History

- 2012: Procurement finished as a cooperation between NTNU, Norwegian Meteorological Institute (MET) and UNINETT Sigma (not Sigma2?). \[2\]
- June 2012: Placed #44 on TOP500. \[4\]
- November 2016: Last appearance on TOP500, placed #442. \[4\]
- Q4 2020: Decommission in connection with Betzy being inaugurated. \[5\]
- Q1 2021: Login nodes closed. \[1\]\[5\]
- Q1 2021: Dismantled. \[1\]

## Specifications

- System: SGI Altix 8600 \[2\], SGI Altix ICE X \[3\] or SGI ICE X \[4\].
- Overview \[2\]\[3\]:
    - Racks: 19.5
    - Nodes total: 1404
    - Cores total: 22 464
    - Memory total: 44TB
    - Interconnect: Mellanox FDR infiniband, enhanced hypercube topology
- Performance \[3\]:
    - Theoretical peak performance: 467 TFLOPS
    - Linpack performance: 396.70 TFLOPS
- Operating environment \[3\]:
    - OS: SUSE Linux Enterprise Server 11
    - Scheduler: PBS
    - Compilers: Intel and GNU C and Fortran
    - MPI library: SGI MPT
- Node details \[1\]\[3\]:
    - Nodes total: 1404
    - Sockets per node: 2
    - CPUs: Intel Xeon E5-2670 (8C16T, 2.6-3.3GHz)
    - Memory per node: 32GiB (8x4GiB, 1600MHz)
    - DIMMs: 4GiB 2Rx4 PC3-12800R ECC
    - Interconnect HCA: Infiniband FDR

## References

- \[1\] First-hand inspection of a node.
- \[2\] UNINETT Sigma2. "HPC and storage hardware." (Accessed 2021-04-25.) https://www.sigma2.no/systems
- \[3\] NTNU HPC Group. "About Vilje." (Accessed 2021-04-25.) https://www.hpc.ntnu.no/ntnu-hpc-group/vilje/about-vilje
- \[4\] TOP500. "SGI ICE X." (Accessed 2021-04-25.) https://top500.org/system/177817/
- \[5\] UNINETT Sigma2. "Migrating from Stallo and Vilje." (Accessed 2021-04-25.) https://www.sigma2.no/migrating-stallo-and-vilje

{% include footer.md %}
