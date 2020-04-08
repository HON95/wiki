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
    - vCPUs: 1 (min)
    - RAM: 1GiB
    - Storage: 10GB

### Command Line

In addition to the default Pterodactyl command arguments.

- `+sv_setsteamaccount <token>`

### Configuration Files

Config dir: `tf/cfg/`

**`autoexec.cfg`:**

Example:
```
hostname ""
// Optional, set to an email address
sv_contact ""
// Leave empty to disable rcon
rcon_password ""
sv_password ""
```

**`server.cfg`:**

Example:
```
// Time in minutes per map, use 0 to disable time limit
mp_timelimit 30
// Maximum number of rounds to play per map before forcing a mapchange
mp_maxrounds 10
```

**`motd.txt` and `motd_text.txt`:**
Contains the full MOTD shown to players when joining the server.
`motd.txt` may contain HTML and is used by default.
`motd_text.txt` is used if the player has disabled HTML MOTDs.
If `motd.txt` contains *any* HTML/CSS/JS, it will be rendered using some ugly default font and opaque background.

**`mapcycle.txt`:**
Lists the all maps in the map pool.
Use `tf/cfg/mapcycle_default.txt` as a reference.

{% include footer.md %}
