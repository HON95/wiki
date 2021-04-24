---
title: Headless Linux ETH Mining
breadcrumbs:
- title: Guides
- title: Mining
---
{% include header.md %}

## Overview

This brief guide shows how to setup an ETH miner in a Docker container on a headless Linux (Debian) server using an NVIDIA GPU, as well as how to apply OC and power limiting to the GPU.
For appropriate values for the GPU clocks and power limit, google it for your specific card to see what others are using.
Note that I'm using an RTX 3080, [lolMiner](https://github.com/Lolliedieb/lolMiner-releases/releases), [ethermine.org](https://ethermine.org) and my own address for the examples.

## Installation

### NVIDIA Driver (or CUDA)

1. Install the latest NVIDIA driver (or CUDA Toolkit, which includes the driver).
    - See the [CUDA Toolkit downloads](https://developer.nvidia.com/cuda-downloads).
    - Using the "deb (network)" method is the simplest IMO.
1. Make sure the driver works and the GPU is detected: `nvidia-smi`

### X11 (For Fake Display)

1. Install X11 (required for NVIDIA settings): `apt install xorg`
1. Generate an "empty" X11 configuration (to allow running the NVIDIA settings without a physical screen): `sudo nvidia-xconfig --cool-bits=31 --allow-empty-initial-configuration`

### Docker & NVIDIA Container Runtime

1. Install [Docker](https://docs.docker.com/engine/install/debian/).
1. Install the [NVIDIA Container Runtime](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).

## Download the Miner

1. See the example script below.
1. Try running it manually (lolMiner example): `lolminer/lolMiner --algo=ETHASH --pool=stratum+ssl://eu1.ethermine.org:5555 --user=0xF6403152cAd46F2224046C9B9F523d690E41Bffd`

Example script:

```sh
#!/bin/bash

# Script to download and prepare lolMiner.

set -eu

ARCHIVE_DOWNLOAD_URL="https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.26/lolMiner_v1.26_Lin64.tar.gz"
ARCHIVE_LOCAL_FILE="lolminer.tar.gz"
LOCAL_DIR="lolminer"

rm -rf "$LOCAL_DIR"
mkdir "$LOCAL_DIR"
wget "$ARCHIVE_DOWNLOAD_URL" -O "$ARCHIVE_LOCAL_FILE"
tar xvf "$ARCHIVE_LOCAL_FILE" -C "$LOCAL_DIR" --strip-components=1
rm -rf "$ARCHIVE_LOCAL_FILE"
```

## Overclocking, Power Limiting Etc.

### Manually Doing It

These are also present in the example script below so you don't have to run them manually, but you should run them once manually first to make sure they work regardless.
To see if they work, run the miner while changing the settings and monitor the hashrate in the miner and the power usage in `nvidia-smi`.
Note that the `[4]` used in some of the commands may be different for you (it's related to the performance level AFAIK).

1. Start an X11 server in the background or some place (again, for NVIDIA settings): `xinit &`
1. Enable persistent mode for the card to avoid dropping the settings when nothing is running: `nvidia-smi -i 0 -pm 1`
1. Set power limit to avoid using more power than needed: `nvidia-smi -i 0 -pl 220` (220W)
1. Enable PowerMizer mode for preferring maximum performance: `DISPLAY=:0.0 nvidia-settings -c :0 -a "[gpu:0]/GPUPowerMizerMode=1"`
1. Set GPU memory clock offset: `DISPLAY=:0.0 nvidia-settings -c :0 -a "[gpu:0]/GPUMemoryTransferRateOffset[4]=1000"` (1000MHz)
1. Set GPU core clock offset: `DISPLAY=:0.0 nvidia-settings -c :0 -a "[gpu:0]//GPUGraphicsClockOffset[4]=-200"` (-200MHz)
1. (Optional) Set constan fan speed: `DISPLAY=:0.0 nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=100"` (100%)

### Scripting It

- The script below may be used to automatically apply the OC/power limiting, based on the manual commands above.
- Since the details depend on the specific system and GPU, run the manual commands first to discover what must be changed and then apply those changes to the script below.
- In order to apply there on boot you may create a crontab file for it (e.g. `/etc/cron.d/lolminer`), containing something like `@reboot root /srv/lolminer/oc.sh >/dev/null` in order to run the script below.

Example script:

```sh
#!/bin/bash

# Script to apply OC, power limiting etc.

set -eu

GPU_ID=0
GPU_POWER_LIMIT=220
GPU_CORE_CLOCK_OFFSET=-200
GPU_MEMORY_CLOCK_OFFSET=1000
XINIT_SLEEP=2

echo
echo "Starting X11 session in background ..."
pkill xinit || :
sleep $XINIT_SLEEP
xinit >/dev/null 2>&1 &
sleep $XINIT_SLEEP

echo
echo "Applying settings ..."
export DISPLAY=:0.0
nvidia-smi -i $GPU_ID -pm 1
nvidia-smi -i $GPU_ID -pl $GPU_POWER_LIMIT
nvidia-settings -c :0 -a "[gpu:$GPU_ID]/GPUPowerMizerMode=1"
nvidia-settings -c :0 -a "[gpu:$GPU_ID]/GPUMemoryTransferRateOffset[4]=$GPU_MEMORY_CLOCK_OFFSET"
nvidia-settings -c :0 -a "[gpu:$GPU_ID]/GPUGraphicsClockOffset[4]=$GPU_CORE_CLOCK_OFFSET"
#nvidia-settings -a "[gpu:$GPU_ID]/GPUFanControlState=1" -a "[gpu:$GPU_ID]/GPUTargetFanSpeed=100"

echo
echo "Killing the X11 session ..."
pkill xinit
sleep $XINIT_SLEEP

echo
echo "Done!"
```

## Setup Docker Container

- See the example script below.
- Setting `--restart=always` will cause it to restart if it crashes as well as starting automatically on system boot.

```sh
#!/bin/bash

# Script to start the miner inside a container.

set -eu

DOCKER_NAME="lolminer"
DOCKER_IMAGE="nvidia/cuda:11.2.2-base"
DOCKER_COMMAND="\
/opt/lolminer/lolMiner \
--nocolor \
--algo=ETHASH \
--pool=stratum+ssl://eu1.ethermine.org:5555 \
--user=0xF6403152cAd46F2224046C9B9F523d690E41Bffd.worker-1 \
"
DOCKER_VOLUME="$PWD/lolminer:/opt/lolminer/:ro"

docker run -d --init --gpus all -v "$DOCKER_VOLUME" --restart=unless-stopped --name="$DOCKER_NAME" "$DOCKER_IMAGE" $DOCKER_COMMAND
```

{% include footer.md %}
