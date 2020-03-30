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

## Resources

- [Cisco Config Analysis Tool (CCAT)](https://github.com/cisco-config-analysis-tool/ccat)

## CLI

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

### General Usage

- Most commands take effect immediately.
- Select range of interfaces: `int range g1/0/1-52` (example)
- Reset interface(s): `default int [range] <if>[-<end>]`
- CLI interaction:
    - Tab: Auto-complete.
    - `?`: Prints the allowed keywords.
    - `| <filter>`: Can be used to filter the output using one of the filter commands.

## Configuration

### Basics

- Save running config: `copy run start` or `write mem`
- Restore startup config: `copy start run`
- Show configurations: `show [run|start]`
    - `| section <section>` can be used to show a specific section.

### AAA

- Disable the `password-encryption` service, use encrypted passwords instead. Perferrably type 9 (scrypt) secrets if available.

## Miscellaneous

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
