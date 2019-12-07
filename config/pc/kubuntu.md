---
title: Kubuntu
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: PC
---
{% include header.md %}

Using: Kubuntu 19.10+

## Installation

1. Use the guided installer. The manual installer is broken and can't create encrypted volumes.

## After Installation

1. Install `vim` and change the default editor to vim by running `update-alternatives --config editor` and selecting `vim.basic`.
2. Disable password for the sudo group by running `visudo` and changing the sudo group line to `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`.
3. Enable numlock on boot \(search for it\).
4. Appearance:
   1. Change to the dark theme.
   2. Make all fonts 1 size smaller.
5. Shortcuts:
   1. Disable web shortcuts.
   2. Add a keyboard shortcut for Dolphin \(e.g. `Meta+E`\) by running `kmenuedit` and changing System, Dolphin.
6. Setup panels for all screens. Only show tasks for the current screen.
7. Install and configure a \(persistent\) firewall.

## Troubleshooting

#### Screen Tearing on the Desktop or Applications

1. In the Nvidia settings, disable "Sync to VBlank".
2. Create a file `/etc/profile.d/kwin.sh` containing `KWIN_TRIPLE_BUFFER=1`.

{% include footer.md %}
