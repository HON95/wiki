---
title: Cisco IOS
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

### Related Pages
{:.no_toc}

- [Cisco IOS Routers](../cisco-ios-routers/)
- [Cisco IOS Switches](../cisco-ios-switches/)

## General Configuration

### Simple Actions

- Save running config: `copy run start` or `write mem`
- Restore startup config: `copy start run`
- Show configurations: `show [run|start]`
    - `| section <section>` can be used to show a specific section.

### AAA

- Disable the `password-encryption` service, use encrypted passwords instead.
- Use type 9 (scrypt) secrets.

## Version String Convention

- Running example: `15.0(2)SE11`
- Train (`15.0SE`): Like the major versjon number.
- Throttle (`2`): Like the minor version number.
- Rebuild (`11`): Like the patch version number. Omitted for rebuild zero. May be specified as a letter directly after the throttle for old versions.


## Theory

### CLI

#### Modes

- User EXEC mode (`Router>`).
- Privileged EXEC mode (`Router#`).
- Configuration modes:
    - Global configuration mode (`Router(config)#`).
    - Interface, line, etc. configuration mode (`Router(config-xxx)#`).
- Setup mode.
- ROMMON mode.

#### Using the CLI

- Tab: Auto-complete.
- `?`: Prints the allowed keywords.
- `|`: Can be used to filter the output.

##### Configuration Mode

- Select range of interfaces: `int range g1/0/1-52` (example)
- Reset interface(s): `default int [range] <if>[-<end>]`

{% include footer.md %}
