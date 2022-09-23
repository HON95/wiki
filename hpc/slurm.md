---
title: Slurm
breadcrumbs:
- title: High-Performance Computing (HPC)
---
{% include header.md %}

## Usage

### Cluster Information and Accounting

- Show partitions: `scontrol show partition [-a]`
- Show partition/node usage: `sinfo [-a]`
- Show node capabilities: `sinfo -o "%20N    %10A    %8c    %10m    %25f    %25G"` (example)
- Show GUI (requires X11 session/forwarding): `sview`
- Show accounts for user: `sacctmgr show assoc where user=<username> format=account`
- Show default account for user: `sacctmgr show user <username> format=defaultaccount`

### Job Submission and Queueing

- Create a job (overview): Make a Slurm script, make it executable and submit it.
- Using GPUs: See example Slurm-file, using `--gres=gpu[:<type>]:<n>`.
- Submit batch job: `sbatch <slurm-file>`
- Start interactive job: `srun <job options> [--pty] <bash|app>`
- Create allocation (without connecting to it): `salloc <job options>`
    - Use e.g. `srun --jobid=<id> --pty bash` to connect to it.
- Cancel specific job: `scancel <jobid>`
- Cancel set of jobs: `scancel [-t <state>] [-u <user>]`
- Show job queue: `squeue [-u <user>] [-t <state>] [-p <partition>]`
- Show job details: `scontrol show jobid -dd <jobid>`

### Example Slurm Job File

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

# Run some program on one processor on all nodes
srun uname -a
```

{% include footer.md %}
