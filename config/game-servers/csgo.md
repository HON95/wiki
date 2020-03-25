---
title: "Counter-Strike: Global Offensive (CS:GO)"
breadcrumbs:
- title: Configuration
- title: Game Servers
---
{% include header.md %}

## Installation

- It's huge. Like 30GB huge.
- Using a server manager like [Pterodactyl](/config/linux-servers/applications/#pterodactyl) makes hosting easier.

## Configuration

### Configuration Files

**`csgo/cfg/autoexec.cfg`** (example)
```
hostname ""
//rcon_password ""
sv_password ""
sv_cheats 0
sv_lan 0
exec banned_user.cfg
exec banned_ip.cfg
```

**`csgo/cfg/server.cfg`** (lacking example)
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
sv_mincmdrate "128"
sv_maxcmdrate "128"
sv_minupdaterate "128"
sv_maxupdaterate "128"
sv_minrate "62500"
sv_maxrate "786432"
```

{% include footer.md %}
