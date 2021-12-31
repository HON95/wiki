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
1. Watch the kernel log to check for sensor errors. If so, try to remove the modules added to `/etc/modules` with `modprobe -r <module>` to see if the error goes away. If so, remove it from the modules file.

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

- Disable middle mouse paste by setting `middlemouse.paste` to false in `about:config`.
- Enable middle mouse "drag scrolling" by setting `general.autoScroll` to true in `about:config`.
- Disable external media keys by setting `media.hardwaremediakeys.enabled` to false in `about:config`.
- (Linux) Install missing language support: `apt install $(check-language-support)`

## CUPS

### Setup for SMB

**For Manjaro. Assumes CUPS is already installed.

1. Install required programs: `pacman -Sy smbclient cifs-utils`
1. Enable SMB authentication: In `/etc/cups/printers.conf`, set `AuthInfoRequired username,password`.
1. Add the printer using the `smb://` schema. It should prompt for authentication when printing stuff.

## Git

### Config

- Location: `~/.gitconfig`
- [Example](https://github.com/HON95/configs/blob/master/git/config).

## Nvidia Settings (Linux)

- To save, use the "save current configuration" button and save it to `/etc/X11/xorg.conf`.

## i3

### Installation

See my [Arch setup with i3](../arch-i3/).

### Configuration

#### Keyboard Bindings

- Specified using the `bindsym` statements for key symbols (`a` etc.) or `bindcode` statements for physical button numbers.
- Use `exec <executable> [args]` to run an application. Use `exec --no-startup-id` to avoid startup notifications ("loading" cursor etc.), for programs that don't support that (the "loading" cursor doesn't go away).

### Usage

Assuming default keybinds.

#### Files

- User config: `~/.config/i3/config`

#### Basics

- Exit: `Mod+Shift+E`
- Reload: `Mod+Shift+R`
- Open terminal: `Mod+Enter`
- Open application (using dmenu/rofi): `Mod+D`
- Exit application: `Mod+Shift+Q`

#### Navigation and Layout

- Move between windows: `Mod+ArrowKey`
- Change mode:
    - Tiling mode (standard): `Mod+E`
    - Stacking mode: `Mod+S`
    - Tabbed mode: `Mod+W`
- Workspaces:
    - Change workspace: `Mod+<1-9>`
    - Move window to another workspace: `Mod+Shift+<1-9>`

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

## Screen

### Usage

#### Serial

- Open serial session: `screen /dev/ttyUSB0 38400,-crtscts` (38400 baud, no flow control)
- End session: `Ctrl+A, \`
- Note: For some devices, you may need to use `Ctrl+H` instead of backspace.

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
- [Example](https://github.com/HON95/configs/blob/master/ssh/config).

## Steam (Linux)

### Installation (Kubuntu)

#### Using Kubuntu Repos or Downloading the Officlal DEB File

Note: Since Steam requires 32-bit (i386) variants of certain NVIDIA packages, and NVIDIA not releasing i386 variants any more as of driver version 465 ish, any normal installation is impossible. The Ubuntu dudes have a PPA containing unofficial i386 variants for the relevant NVIDIA driver packages, but it conflicts with official CUDA packages, which is not nice if you need CUDA.

#### Using Flatpak

- See [Steam (Flatpak)](https://flathub.org/apps/details/com.valvesoftware.Steam).
- This doesn't require the dumb i386 NVIDIA driver packages.
- As long as [ValveSoftware/steam-for-linux #7847](https://github.com/ValveSoftware/steam-for-linux/issues/7847) isn't fixed, make sure to _not_ enable "remember my password". If you do and it crashes on the next start, run `flatpak run com.valvesoftware.Steam --reset` (if using Flatpak) to reset the user config and then lanuch it normally afterward.

### Miscellanea

- Proton Windows home dir: `~/.local/share/Steam/steamapps/compatdata/<some_id>/pfx/drive_c/users/steamuser/`
- Proton Windows home dir (Flatpak): `~/.var/app/com.valvesoftware.Steam/.steamlib/steamapps/compatdata/374320/pfx/drive_c/users/steamuser/`

## tmux

### Setup

- Config files:
    - User: `~/.tmux.conf`
    - Global: `/etc/tmux.conf`
- Set/fix default shell and colors (using ZSH as example):
    - In `~/.tmux.conf`, set `set-option -g default-shell /bin/zsh` (for ZSH).
    - In `~/.zshrc`, set `export TERM=xterm-256color`.

### Usage

- Sessions:
    - Start new session: `tmux new [-s <name>] [-d]`
        - `-d` to start detached.
    - Detach from session: `Ctrl+B D`
    - List sessions: `tmux ls`
    - Attach to session: `tmux attach [-d] [-t <session>]`
        - `-d` to detach any other attached clients.
- Enter command: `Ctrl+B :<command> Enter`
- Windows:
    - Switch to window: **TODO**
- Panes:
    - Split horizontally: `Ctrl+B "`
    - Split vertically: `Ctrl+B %`
    - Switch active pane: `Ctrl+B <arrow>`
    - Show pane numbers: `Ctrl+B Q`
    - Kill pane: `Ctrl+B X` (or exit normally)
- Killing:
    - Kill session: `tmux kill-session -t <session>`
    - Kill server with all sessions: `tmux kill-server`
- Miscellanea:
    - Type into all panes (command): `:setw synchronize-panes`

## Vim

### Config
- Location:
    - Global: `/etc/vim/vimrc`
    - User: `~/.vimrc`
- [Example](https://github.com/HON95/configs/blob/master/vim/vimrc).

## VS Code

### Setup

1. Install it.
1. (Linux) Increase the handle count limit:
    1. Ref.: ["Visual Studio Code is unable to watch for file changes in this large workspace" (error ENOSPC)](https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc).
    1. Get current limit: `cat /proc/sys/fs/inotify/max_user_watches`
    1. In `/etc/sysctl.conf`, set `fs.inotify.max_user_watches=524288`.
    1. Reload the config: `sysctl -p`

### Some Extensions

- HTML CSS Support (`ecmel.vscode-html-css`): Adds better CSS support.
- GitLens (`eamodio.gitlens`): Show more git info (like authorship) in editor. Can be a bit verbose/annoying.
- Vuln Cost (`snyk-security.vscode-vuln-cost`): Show inline security vulnerabilities for imports. Only JS support for now.

### Config

- Location:
    - Linux (Ubuntu): `~/.config/Code/User/settings.json`
    - Linux (Arch): `~/.config/Code - OSS/User/settings.json`
    - Windows: `%APPDATA%\Code\User\settings.json`
- [Example](https://github.com/HON95/configs/blob/master/vscode/settings.json).

## ZSH (Linux)

This is my ZSH setup preference, using Oh-My-ZSH with the Powerlevel10k theme and some recommended font.

1. Install ZSH:
    1. `apt install zsh`
1. Install Oh-My-ZSH:
    1. See [ohmyz.sh](https://ohmyz.sh/).
    1. When it asks, set it as your default shell. This won't take effect until the next login.
1. Setup Powerlevel10k theme:
    1. Download and install the suggested fonts: [Fonts (powerlevel10k)](https://github.com/romkatv/powerlevel10k#fonts)
        - For KDE Plasma, download and open with the font installer.
        - For manual installation, move the `.ttf` files to `/usr/share/fonts/TTF/`.
    1. Open a new terminal window and set change the profile to use the new font.
    1. Clone the theme: `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k`
    1. In `~/.zshrc`, set `ZSH_THEME="powerlevel10k/powerlevel10k"`.
    1. Open a new ZSH session (or restart your terminal).
    1. Configure the theme (if it didn't automatically start): `p10k configure`
1. Make zprofile include profile (to avoid breaking certain things):
    1. In `~/.zprofile`, add: `emulate sh -c "source /etc/profile"`
1. Setup plugins:
    1. In `.zshrc`, set e.g. `plugins=(git docker docker-compose golang rust)`.
1. Setup syntax highlighting plugin:
    1. Clone it: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
    1. Add `zsh-syntax-highlighting` it to `plugins` in `.zshrc`.
1. Configure `~/.zshrc`:
    1. Example [zshrc](https://github.com/HON95/configs/blob/master/zsh/zshrc).

{% include footer.md %}
