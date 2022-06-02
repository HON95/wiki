---
title: Team Fortress 2 (TF2)
breadcrumbs:
- title: Game Servers
---
{% include header.md %}

## Resources

- [CFG.TF](https://cfg.tf/)

## Installation

Use Pterodactyl.

## General Configuration

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

**`autoexec.cfg` (example):**

```
hostname ""
// Optional, set to an email address
sv_contact ""
// Leave empty to disable rcon
rcon_password ""
sv_password ""
```

**`server.cfg` (example):**

```
// Time in minutes per map, use 0 to disable time limit
mp_timelimit 30
// Maximum number of rounds to play per map before forcing a mapchange
mp_maxrounds 10
```

**`motd.txt` and `motd_text.txt`:**

- Contains the full MOTD shown to players when joining the server.
- `motd.txt` may contain HTML and is used by default.
- `motd_text.txt` is used if the player has disabled HTML MOTDs.
- If `motd.txt` contains *any* HTML/CSS/JS, it will be rendered using some ugly default font and opaque background.

**`mapcycle.txt`:**

- Lists the all maps in the map pool.
- Use `tf/cfg/mapcycle_default.txt` as a reference.

## MvM Configuration

For more info: [Steam Support: TF2 Mann vs Machine Server Overview](https://support.steampowered.com/kb_article.php?ref=6656-IAZN-7933)

1. Set `+maxplayers 32` on the command line.
1. Add only MvM maps to `mapcycle.txt`.
1. Set `+map mvm_decoy` (or another MvM map from the map pool) on the command line.
1. (Optional) To allow matchmaking, see the Steam Support link above.

{% include footer.md %}
