---
title: "Counter-Strike: Global Offensive (CS:GO)"
breadcrumbs:
- title: Configuration
- title: Game Servers
---
{% include header.md %}

## Installation

Use Pterodactyl.

## Configuration

- App ID: 730 (not 740)
- Resource usage:
    - vCPUs: 1 (min)
    - RAM: 1GiB
    - Storage: 30GB

### Command Line

In addition to the default Pterodactyl command arguments.

- `-tickrate 128`: Use tick rate 128. Must be set in the config as well.

### Configuration Files

Config dir: `csgo/cfg/`

**`autoexec.cfg`**
Loaded when the server starts.

Example:
```
hostname ""
//rcon_password ""
sv_password ""
sv_cheats 0
sv_lan 0
exec banned_user.cfg
exec banned_ip.cfg
```

**`csgo/cfg/server.cfg`**
Loaded when a map is loaded (I think).

Example:
```
// Auto balance teams
mp_autoteambalance 1
// Max member count difference wrt. joining a team
mp_limitteams 1
// Save banned IDs to banned_user.cfg
writeid
// Save banned IPs to banned_ip.cfg
writeip

// 128-tick
// In addition, add "-tickrate 128" to the command line
sv_mincmdrate "128"
sv_maxcmdrate "128"
sv_minupdaterate "128"
sv_maxupdaterate "128"
sv_minrate "62500"
sv_maxrate "786432"
```

{% include footer.md %}
