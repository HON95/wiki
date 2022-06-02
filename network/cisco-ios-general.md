---
title: Cisco IOS General
breadcrumbs:
- title: Network
---
{% include header.md %}

Software configuration for Cisco switches and routers running IOS or derivatives.

### Related Pages
{:.no_toc}

- [Cisco Hardware](/config/network/cisco-hardware/)
- [Cisco IOS Routers](/config/network/cisco-ios-routers/)
- [Cisco IOS Switches](/config/network/cisco-ios-switches/)

## Resources

- [Cisco Config Analysis Tool (CCAT)](https://github.com/cisco-config-analysis-tool/ccat)

## General Configuration

### CLI Usage

- Most commands take effect immediately.
- Select range of interfaces: `int range g1/0/1-52` (example)
- Reset interface(s): `default int [range] <if>[-<end>]`
- CLI interaction:
    - Tab: Auto-complete.
    - `?`: Prints the allowed keywords.
    - `| <filter>`: Can be used to filter the output using one of the filter commands.
- Show configurations: `show [run|start]`
    - `| section <section>` can be used to show a specific section.

### Basics

- Save/load config:
    - Save running config: `copy run start` or `write mem`
    - Restore startup config: `copy start run`
- System status:
    - Show alarms: `show facility-alarm status`
- Interface status:
    - L2/L3 oiverview: `sh ip int br`
- Optics:
    - Show transceivers: `sh interfaces transceiver`

### AAA

- Disable the `password-encryption` service, use encrypted passwords instead. Perferrably type 9 (scrypt) secrets if available.
- Set enable secret (for entering privileged EXEC mode): `enable algorithm-type scrypt secret <secret>`
- Enable user auth: `aaa new-model`
- Local user database:
    - Enable local database: `aaa authentication login default local`
    - Add user: `username <username> privilege 15 algorithm-type scrypt secret <password>`
        - `privilege 15` means the user will enter directly into privileged EXEC mode.
        - `algorithm-type scrypt` means it will use the secure scrypt password hashing algorithm.
- TACACS+:
    - **TODO**

### Lines

- Includes the console line and vty (telnet/SSH) lines.
- Configured using line conf. mode: `line <con|vty> <n>`
- Set inactivity logout: `exec-timeout <min> <sec>`
    - `0 0` disables it, which is practical for labs.
- Enabel synchronous logging for console: `logging synchronous`
- (Not recommended) Enable simple password-based console login:
    1. Enter line conf. mode.
    1. Enable login: `login`
    1. Set console password: `password [alg] <password>`
- (Recommended) Enable user-based console login:
    1. Enter line conf. mode.
    1. Enable login: `login`
    1. Set to use the local database: `login authentication default`

## Tasks

### Reset Password

1. Power off the device.
1. Connect using serial.
1. Power on the device and immediately prepare for the next step.
1. Press Ctrl+Break to enter ROMMON.
1. Type `confreg 0x2142` to make it ignore the startup config.
1. (Required?) Type `sync` to save the environment.
1. Type `boot` to start booting the IOS image. Wait for it to boot.
1. Log in using default (no) credentials and make the necessary changes.
    - To reset the startup config, run `erase startup-config`.
1. Enter config mode and run `config-register 0x2102` to re-enable loading the startup config.
1. Reboot: `reload`

### Copy Config to Device Using SCP

Note: Copying to the running config will merge it into it instead of overwriting it. Copying it to the startup config instead and restarting is one way around that.

1. Enable SSH, SCP, default login authentication and default exec authorization.
1. Backup the old startup config: `copy startup-config flash:startup-config.backup`
1. Copy from PC to device: `scp new-config.txt admin@10.10.10.10:flash:/new-config` (example)
1. Copy new config to running config to validate it: `copy flash:new-config running-config`
    - Note that this will merge the two configs, which may lead to some new warnings or errors.
1. Copy new config to startup config: `copy flash:new-config startup-config`
1. Reload: `reload`

## Information

- Memories:
    - ROM: For bootstrap stuff.
    - Flash: For IOS images.
    - NVRAM: For startup configuration files.
    - RAM: For running config, tables, etc.

### Boot

- IOS image sources (in default order): Flash, TFTP, ROM.
- Startup config sources (in default order): NVRAM, TFTP, system configuration dialog.
- Some details may be configured using the configuration register.

### Modes

- User EXEC mode (`Router>`):
    - Used to run basic, non-privileged commands, like `ping` or `show` (limited).
    - Entered when logging in as "not very privileged" users.
- Privileged EXEC mode (`Router#`) (aka enable mode):
    - Used to run more privileged (all) commands.
    - Entered when logging in as "privileged" users or when running `enable` from user EXEC mode.
- Global configuration mode (`Router(config)#`) and special configuration mode (`Router(config-xxx)#`):
    - Used to configure the unit.
    - Global configuration mode is entered by running `configure terminal` in privileged EXEC mode.
    - "Special" configuration mode (it's not actually collectively called that) is entered when configuring an interface, a virtual router interface, a console line, a VLAN etc. from global configuration mode.
- Setup mode:
    - Used to interactivly configure some the "basics".
    - Entered when loggin into a factory reset unit or when running `setup`.
    - Completely useless, never use it.
- ROM monitor mode (aka ROMMON).

### Features

#### Port Aggregation Protocol (PAgP)

- Cisco-proprietary protocol for link aggregation.
- Use LACP instead.

#### Link Aggregation Control Protocol (LACP)

- An IEEE protocol (aka 802.3ad) for link aggregation.

#### UniDirectional Link Detection (UDLD)

- A Cisco-proprietary protocol for detecting unidirectional links.
- Disabled by default.
- This can happen when one fiber strand has been damaged but the other one works, which would make it hard to know that the link is down and it could cause STP loops.
- It's mostly used for fiber ports, but can also be used for copper ports.
- Use aggressive mode to err-disable the port when it stops receiving periodic UDLD messages.
- A partial alternative is to use single member LACP.
- Configuration:
    - Set message interval: `udld message time <seconds>`
    - Enable in normal og aggressive mode globally on all fiber ports: `udld <enable|aggressive>`
    - Enable per-interface: `udld port <enable|aggressive>`

#### Cisco Discovery Protocol (CDP)

- A Cisco-proprietary protocol for interchanging device information to neighbor devices.
- Use LLDP instead.
- Disable globally: `no cdp run`

#### Link Layer Discovery Protocol (LLDP)

- An IEEE protocol (defined in IEEE 802.1AB) for interchanging device information to neighbor devices.
- **TODO** LLDP and LLDP-MED

### Version and Image String Notations

- Version 12 notation (e.g. `12.4(24a)T1`):
    - Major release (`12`).
    - Minor release (`4`).
    - Maintenance number (`24`).
    - Rebuild number (alt. 1) (`a`).
    - Train identifier (`T`).
    - Rebuild number (alt. 2) (`1`).
- Version 15 notation (e.g. `15.0(1)M1`):
    - Major release (`15`).
    - Minor release (`0`).
    - Feature release (`1`).
    - Release type (`M`).
    - Rebuild number (`1`).
- If it has `K9` in the image name, it has cryptographic features included. Some images don't because of US export laws.

{% include footer.md %}
