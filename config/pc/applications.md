---
title: PC Applications
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

## Fancontrol (Linux)

**Warning:** Don't use this. The fan controller IDs may change on every reboot which breaks the config.

### Configure Sensors

1. Install `lm-sensors`.
1. Run `sensors-detect`.
    1. Answer with the default answers.
    1. At the end, allow it to add the modules to `/etc/modules`.
1. Reload the `kmod` service to reload the modules.

### Configure Fancontrol

1. Install `fancontrol`.
1. (Optional) Install `gnuplot` if you want `pwmconfig` to generate graphical plots.
1. Run `pwmconfig`.
    1. Use manual mode for when asked.
    1. Generate detailed correlations when asked.
    1. Set up the config file when asked (`/etc/fancontrol`).
    1. Decide which sensor each controller should depend on.
    1. Configure all fan controllers.
    1. Save and quit.
1. Tweak the config:
    1. Open `/etc/fancontrol`.
    1. Round up all numbers, just to make it a little cleaner.
    1. Set `interval` to around 2 seconds.
1. Restart the `fancontrol` service.

## Firefox

### Config

- (Linux) Disable middle mouse paste:
    - Go to `about:config`.
    - Set `middlemouse.paste` to false.

## Git

### Config

- Location: `~/.gitconfig`
- [Example](https://github.com/HON95/configs/blob/master/pc/common/gitconfig).

## Nvidia Settings (Linux)

- To save, use the "save current configuration" button and save it to `/etc/X11/xorg.conf`.

## Piper (Linux)

GUI for configuring gaming mice.

### Setup

1. Install the piper [PPA](https://launchpad.net/~libratbag-piper/+archive/ubuntu/piper-libratbag-git).
1. Install `piper`.
1. Configure the mouse using the GUI application.

## PuTTY (Windows)

- In `Terminal > Features`, activate `Disable application keypad mode`.
- In `Window > Appearance`, change font to Consolas, regular, size 10.
- In `Window > Colours`, set all ANSI non-bold colors to the same as the bold ones.

## SMB

### Troubleshooting

- If using DNS instead of NetBIOS and the client freezes while connecting to a share, try enabling the "Routing and Remote Access" service.

## Speedfan (Windows)

- **Warning:** The controller symlinks likes to change on boot, meaning the config may break every boot. This makes it literally useless.
- Manually add startup shortcut.
- Disable `Do SMART Summary Error Log scan on startup` since it may cause the PC to freeze.
  - Alternatively, use the CLI argument `/NOSMARTSCAN`.
- Set the PWM mode for fans which will be controlled by Speedfan to manual.

## SSH

### Usage

- New key (RSA): `ssh-keygen -t rsa -b 4096`

### Config

- Location: `~/.ssh/config`
- [Example](https://github.com/HON95/configs/blob/master/pc/common/ssh_config).

## Steam (Linux)

- Windows appdata dir: `steamapps/compatdata/<some_id>/pfx/drive_c/users/steamuser/AppData/`

## Vim

### Config
- Location:
    - Global: `/etc/vim/vimrc`
    - User: `~/.vimrc`
- [Example](https://github.com/HON95/configs/blob/master/pc/common/vimrc).

## VS Code

### Setup

1. Install it.
1. (Linux) Increase the handle count limit:
    1. Ref.: ["Visual Studio Code is unable to watch for file changes in this large workspace" (error ENOSPC)](https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc).
    1. Get current limit: `cat /proc/sys/fs/inotify/max_user_watches`
    1. In `/etc/sysctl.conf`, set `fs.inotify.max_user_watches=524288`.
    1. Reload the config: `sysctl -p`

### Some Extensions

- GitLens (eamodio.gitlens)
- HTML CSS Support (ecmel.vscode-html-css)

### Config

- Location:
    - Linux: `~/.config/Code/User/settings.json`
    - Windows: `%APPDATA%\Code\User\settings.json`
- [Example](https://github.com/HON95/configs/blob/master/pc/common/vscode_settings.json).

## ZSH (personal) (Linux)

This is my personal ZSH setup using Oh-My-ZSH with the Powerlevel9k theme and Hack font.

1. Install ZSH:
    1. `apt install zsh`
1. Make zprofile include profile (to avoid breaking certain things):
    1. In `/etc/zprofile` or `/etc/zsh/zprofile` (whichever exists), add: `emulate sh -c "source /etc/profile"`
1. Install Oh-My-ZSH:
    1. See [ohmyz.sh](https://ohmyz.sh/).
    1. When it asks, set it as your default shell. This won't take effect until the next login.
1. Setup Powerlevel10k theme:
    1. (Optional) Setup font: [Fonts](https://github.com/romkatv/powerlevel10k#fonts)
    1. Clone it: `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k`
    1. In `~/.zshrc`, set `ZSH_THEME="powerlevel10k/owerlevel10k"`.
    1. Restart ZSH/your terminal.
    1. Configure the theme: `p10k configure`
1. Setup syntax highlighting plugin:
    1. Clone it: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
    1. Add it to `plugins` in `.zshrc` (e.g. `plugins=(git zsh-syntax-highlighting)`).
1. Configure `~/.zshrc`:
    1. See the example below.

[Example zshrc](https://github.com/HON95/configs/blob/master/pc/common/zshrc).

{% include footer.md %}
