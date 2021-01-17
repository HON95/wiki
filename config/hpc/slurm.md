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
    - Using GPUs: See example Slurm-file, using `--gres=gpu[:<type>]:<n>`.
    - Submit batch/non-blocking job: `sbatch <slurm-file>`
    - Start interactive/blocking job: `srun <job options> [--pty] <bash|app>`
    - Cancel specific job: `scancel <jobid>`
    - Cancel set of jobs: `scancel [-t <state>] [-u <user>]`

## Example Slurm-File

```sh
#!/bin/sh

#SBATCH --partition=<partition>
#SBATCH --time=03:00:00
#SBATCH --nodes=2
# #SBATCH --nodelist=compute-2-0-[17-18],compute-5-0-[20-21]
#SBATCH --ntasks-per-node=2
# #SBATCH --exclusive
# #SBATCH --mem=64G
#SBATCH --gres=gpu:V100:2
#SBATCH --job-name="xxx"
#SBATCH --output=log.txt
## SBATCH --mail-user=user@example.net
# #SBATCH --mail-type=ALL

# Run some program on all processors using mpirun
mpirun uname -a
```

{% include footer.md %}
