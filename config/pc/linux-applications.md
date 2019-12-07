---
title: Linux Applications
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: PC
---
{% include header.md %}

### Using
Kubuntu 19.10+

## Fancontrol

**Warning:** Fancontrol is unreliable and should probably not be used. The fan controller IDs like to change on every reboot which breaks the config.

#### Configure Sensors

1. Install `lm-sensors`.
2. Run `sensors-detect`.
   1. Answer with the default answers.
   2. At the end, allow it to add the modules to `/etc/modules`.
3. Reload the `kmod` service to reload the modules.

#### Configure Fancontrol

1. Install `fancontrol`.
2. \(Optional\) Install `gnuplot` if you want `pwmconfig` to generate graphical plots.
3. Run `pwmconfig`.
   1. Use manual mode for when asked.
   2. Generate detailed correlations when asked.
   3. Set up the config file when asked \(`/etc/fancontrol`\).
   4. Decide which sensor each controller should depend on.
   5. Configure all fan controllers.
   6. Save and quit.
4. Tweak the config:
   1. Open `/etc/fancontrol`.
   2. Round up all numbers, just to make it a little cleaner.
   3. Set `interval` to around 2 seconds.
5. Restart the `fancontrol` service.

## Nvidia Settings

- To save, use the "save current configuration" button and save it to `/etc/X11/xorg.conf`.

## Piper

GUI for configuring gaming mice.

#### Setup

1. Install the piper [PPA](https://launchpad.net/~libratbag-piper/+archive/ubuntu/piper-libratbag-git).
2. Install `piper`.
3. Configure the mouse using the GUI.

## Shell

### ZSH \(Oh-My-ZSH\)

1. Install ZSH.
2. Install Oh-My-ZSH:
   1. See: [https://ohmyz.sh/](https://ohmyz.sh/)
3. Install the Powerlevel9k theme:
   1. `git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k`
   2. In `~/.zshrc`: `ZSH_THEME="powerlevel9k/powerlevel9k"`
4. Install the Hack font from Nerd Fonts:
   1. If it's already installed.
   2. Install it if not: [https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack)
   3. Change your terminal's font to it.
   4. In `~/.zshrc`, set `POWERLEVEL9K_MODE="nerdfont-complete"`.
5. Configure `~/.zshrc`: See below.
6. Make zprofile include profile:
   1. In `/etc/zprofile`, add: `emulate sh -c "source /etc/profile"`
   2. Prevents Snaps and other profile stuff from breaking.

```bash
# File: ~/.zshrc

CASE_SENSITIVE="true"

ZSH_THEME="powerlevel9k/powerlevel9k"

POWERLEVEL9K_MODE="nerdfont-complete"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs)
POWERLEVEL9K_STATUS_CROSS="true"
```

## Steam

- Windows appdata dir: `steamapps/compatdata/<number>/pfx/drive_c/users/steamuser/AppData/`

{% include footer.md %}
