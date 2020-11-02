---
title: Slurm Workload Manager
breadcrumbs:
- title: Configuration
- title: IoT
---
{% include header.md %}

## Usage

### Basics

- Cluster information:
    - Show partitions: `scontrol show partition [-a]`
    - Show partition/node usage: `sinfo [-a]`
    - Show node capabilities: `sinfo -o "%20N    %8c    %10m    %25f    %10G"` (example)
- Accounting:
    - Show accounts for user: `sacctmgr show assoc where user=<username> format=account`
    - Show default account for user: `sacctmgr show user <username> format=defaultaccount`
- Job and job queue information:
    - Show job queue: `squeue [-u <user>] [-t <state>] [-p <partition>]`
    - Show job details: `scontrol show jobid -dd <jobid>`
- Job handling:
    - Create a job (overview): Make a Slurm script, make it executable and submit it.
    - Submit interactive/blocking job: `srun [--pty bash] <...>`
    - Submit batch/non-blocking job: `sbatch <...>`
    - Cancel specific job: `scancel <jobid>`
    - Cancel multiple jobs: `scancel [-t <state>] [-u <user>]`

{% include footer.md %}
