---
title: Team Fortress 2 (TF2)
breadcrumbs:
- title: Configuration
- title: Game Servers
---
{% include header.md %}

## Installation

Use Pterodactyl.

## Configuration

- App ID: 440 (Steam Game Server Account Management) or 232250 (Pterodactyl)
- Game name: `tf`
- Resource usage:
    - vCPUs: **???**
    - RAM: **???**
    - Storage: **8GB**

### Command Line

In addition to the default Pterodactyl command arguments.

- `+sv_setsteamaccount <token>`

### Configuration Files

(Examples)

**`tf/cfg/autoexec.cfg`:**
```
hostname ""
// Optional, set to an email address
sv_contact ""
// Leave empty to disable rcon
rcon_password ""
sv_password ""
```

**`tf/cfg/server.cfg`:**
```
// Time in minutes per map, use 0 to disable time limit
mp_timelimit 30
// Maximum number of rounds to play per map before forcing a mapchange
mp_maxrounds 10
```

**`tf/cfg/motd.txt`:**

Use `tf/cfg/motd_default.txt` as a reference.

**`tf/cfg/mapcycle.txt`:**

Use `tf/cfg/mapcycle_default.txt` as a reference.

{% include footer.md %}
