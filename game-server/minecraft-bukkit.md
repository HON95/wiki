---
title: Minecraft (Bukkit)
breadcrumbs:
- title: Game Servers
---
{% include header.md %}

This page is intended for the Bukkit server software or any of its derivatives, like SpigotMC, PaperMC and Tuinity.

## Resource Requirements

### Memory Usage

- Allocate 1-10 GB per server, with 1G for tiny servers with few players and 10G+ for large servers with many players and worlds.
- The usage scales with the number of worlds, players and plugins, as well as how scattered throughout the world(s) the players are.
- Memory allocation for Minecraft or more about GC pressure than running completely out of memory, so deciding how much is enough can be hard.
- Memory usage is set using the `Xmx` parameter, which specified how much memory the JVM is allowed to use (excluding internal usage). The server is expected to use all of it, which does *not* mean that the server is out of memory. `Xms`, the initial memory allocation, should be the same as `Xmx` to avoid unused memory.
- Leave some of the available memory unused when setting `Xmx`, as the JVM internals, OS etc. requires memory too.
- See [Tuning the JVM – G1GC Garbage Collector Flags for Minecraft (Aikar)](https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/).

## Server Managers

- [Pterodactyl](https://pterodactyl.io/):
    - See [Linux Server Applications: Pterodactyl](/config/linux-server/applications/#pterodactyl)).
    - Open-source.
    - Free to use.
    - Modern.
    - Generalized for many games and apps.
    - Somewhat complex setup.
- [McMyAdmin 2](https://www.mcmyadmin.com/):
    - Requires cheap license, but has a restricted free version.
    - Old, very common back in the day.
    - Replaced by AMP.
- [AMP](https://cubecoders.com/AMP):
    - Haven't tested it.

## Server Variants

- [Bukkit](https://bukkit.org/):
    - An open-source modification of the vanilla Minecraft server with a rich plugin API, increased configurability and other improvements.
    - Acquired by Mojang as part of hiring parts of the Bukkit team. Although, Mojang did not attempt to control the project.
    - Discontinued in 2014 due to project retirement and a following DMCA takedown from one of its biggest contributors ([unofficial explanation](https://www.spigotmc.org/wiki/unofficial-explanation-about-the-dmca/)). Due to the DMCA takedown, all pre-built images were removed and similar active projects had to find a way to provide the modified images without redistributing the vanilla Minecraft server.
    - The API (and project) is called "Bukkit", while the implementation and modified vanilla server (`net.minecraft.server` or native Minecraft server (NMS)) is called "CraftBukkit".
- [SpigotMC](https://www.spigotmc.org/):
    - A fork of Bukkit with enhancements.
- [PaperMC](https://papermc.io/):
    - A fork of SpigotMC with enhancements.
- [Tuinity](https://github.com/Spottedleaf/Tuinity):
    - A fork of PaperMC (or EmpireCraft (EMC)) with enhancements.
    - Attempts to merge enhancements back into PaperMC, but with some resistance due to personal disagreements.

## Configuration

### JVM Tuning

From [Tuning the JVM – G1GC Garbage Collector Flags for Minecraft (Aikar)](https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/) (updated Apr 25 2020 3:30PM EST):

```text
-Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true
```

`-Xmx` and `-Xms` should be equal and set to an appropriate size. Remember to leave memory for JVM internals, the OS and other progrems.

{% include footer.md %}
