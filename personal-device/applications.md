---
title: PC Applications
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

*Note: Unless specified, Debian/Ubuntu is assumed.*

## Companion (for Streamdeck) (Linux)

Installed such that its run by logged in users (no system service).

*Using v3 beta.*

### Install

1. Download:
    1. Download: [Bitfocus downloads](https://user.bitfocus.io/download)
        - Requires Bitfocus user.
    1. Unzip: `tar xvf companion-linux-x64*`
    1. Move to permanent dir: `sudo mv companion-64* /opt/companion`
    1. Fix owner: `sudo chown -R root:root /opt/companion`
1. Add group:
    1. Create group: `sudo groupadd -r companion`
    1. Add youtself to it: `sudo usermod -aG companion $USER`
    1. Update your groups for the current shell: `newgrp companion`
1. Setup udev rules:
    1. Find your USB vendor and product ID: `lsusb | grep -i elgato` (look for `ID <idVendor>:<idProduct>`)
    1. Create `/etc/udev/rules.d/50-companion.rules`, containing the udev rules snippet below, with updated `idVendor` and `idProduct` values.
    1. Reload the udev rules: `sudo udevadm control --reload-rules`
    1. Connect/reconnect the device.
    1. Make sure at least one of the `hidraw` devices has the `companion` group: `ls -l /dev/hidraw*`
1. Manually start the application to make sure it's working:
    1. Run (as your user): `/opt/companion/companion-launcher`
    1. A taskbar icon and GUI should appear.
    1. Make sure it's running on `127.0.0.1` only.
    1. Open the webpage (`localhost:8000`).
    1. Go to "surfaces" and check that the device has appeared. Press "rescan USB" if not. Check the output if nothing appears.
1. Run on login (using i3 WM in my case):
    1. Add the app to your i3 config: `exec --no-startup-id /opt/companion/companion-launcher >>$HOME/.log/companion.txt 2>>$HOME/.log/companion.err` (create `$HOME/.log`)
    1. Relog and make sure it started correctly.

**Udev rules (`50-companion.rules`):

```udev
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", GROUP="companion"
KERNEL=="hidraw*", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", GROUP="companion"
```

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

- (Note) The config is available at address `about:config`.
- Disable middle mouse paste: `middlemouse.paste = false`
- Enable middle mouse "drag scrolling": `general.autoScroll = true`
- Disable external media keys: `media.hardwaremediakeys.enabled = false`
- Show punycode/IDNs to avoid IDN homograph attacks: `IDN_show_punycode = true`
- (Debian) Install missing language support: `apt install $(check-language-support)`

## CUPS

### Setup for SMB

**For Manjaro. Assumes CUPS is already installed.**

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

## Kdenlive (Linux)

### Setup

Arch Linux:

1. Install: `sudo pacman -S kdenlive breeze`
1. Open Kdenlive.
1. Fix theme:
    1. "Settings" > "Color Scheme" > "Breeze Dark".

## Piper (Linux)

GUI for configuring gaming mice.

### Setup

1. Install the piper [PPA](https://launchpad.net/~libratbag-piper/+archive/ubuntu/piper-libratbag-git).
1. Install `piper`.
1. Configure the mouse using the GUI application.

### Project

1. Press "new project".
1. Select a profile (e.g. "4K UHD 2160p 30fps").
1. Import media to use.
1. Add image:
    1. Import as "clip".
    1. Add to video track.
    1. Add transform effect to scale and move it (make sure to "show edit mode" in the video preview).
1. Etc.
1. Export to video file.

## PipeWire (Linux)

A modern audio server replacement for PulseAudio, JACK and ALSA.
Comes with adapters for compatibility with existing applications and such that existing tools can be used.

### Resources

- [[Pipewire Wiki] Config PipeWire](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire)
- [[Pipewire Wiki] Virtual devices](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Virtual-Devices)

### Usage

- Open audio control panel:
    - GUI: `pavucontrol`
    - TUI: `alsamixer -c <card-id>`
- Show stuff:
    - Show audio server info: `pactl info`
    - Show cards: `pactl list cards`
    - Show inputs: `pactl list sources`
    - Show outputs: `pactl list sinks`
    - Show sound card info: `cat /proc/asound/UMC1820/stream0` (for card UMC1820)

### Installation

See the [Arch (i3)](../arch-i3/) or [Kubuntu](../kubuntu/) config notes.

### Configuration

#### General

1. Set the sample rate:
    1. Find the card's current rate and supported rates: `cat /proc/asound/UMC1820/stream0` (for card UMC1820)
    1. Create `/etc/pipewire/pipewire.conf.d/10-clock-rate.conf` containing the snippet below, with your chosen sample rate.
1. Set sample depth:
    1. **TODO**
1. **TODO** Fix stuttering. When using loopback module only? Weird playback of old buffer for a split second when opening new audio application?
1. Restart PipeWire to apply changes: `systemctl --user restart pipewire.service`

Example contents of `/etc/pipewire/pipewire.conf.d/10-clock-rate.conf`:

```
context.properties = {
   default.clock.rate = 96000
}
```

#### Disable ALSA Card Profiles (ACP) for a Card

Disabling ACP for an ALSA card means that all of its inputs and outputs will be provided as raw channels without surround mixing etc.
The same result (seemingly) may also be achieved by setting the card profile to "pro audio" in e.g. pavucontrol,
although the pro audio profile seems to mess up my sink/source routing.

1. In `/etc/pipewire/media-session.d/alsa-monitor.conf`, add the snippet below in the `rules` list.
    - `device.vendor.id` should be set to the vendor ID of the USB device. Use `lsusb` to find it. Behringer typically uses `1397`.
1. Restart PipeWire: `systemctl --user restart pipewire.service`

Snippet for `/etc/pipewire/media-session.d/alsa-monitor.conf`:

```
# Add into the existing section below
# rules = [
    # ...
    {
        matches= [
            {
                # Behringer
                device.name = "~alsa_card.*"
                device.vendor.id = "1397"
            }
        ]
        actions = {
            update-props = {
                api.alsa.use-acp = false
            }
        }
    }
# ]
```

#### Setup Virtual Sinks and Sources Using Channels from a Multi-Channel Card

Split e.g. an 8-channel output device into four stereo devices.
Requires PipeWire v3.27 or newer.

1. (Note) See [Virtual Devices (PipeWire Wiki)](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Virtual-Devices).
1. Disable ACP for the card (see above). (Or change to the "pro audio" profile, but that didn't work for me.)
1. In `/etc/pipewire/media-session.d/media-session.conf`, add the snippet below in the `context.modules` list.
    - Add a module instance for each virtual input/output device.
    - Find the target device using `pactl list sinks` or `pactl list sources`.
1. Restart PipeWire: `systemctl --user restart pipewire.service`

Snippets for `/etc/pipewire/media-session.d/media-session.conf`:

```
# Add into the existing section below
# context.modules = [
    # ...

    # Virtual output example
    {   name = libpipewire-module-loopback
        args = {
            node.name = "BEHRINGER_UMC1820_0102"
            node.description = "Behringer UMC1820 (1-2)"
            capture.props = {
                media.class = "Audio/Sink"
                audio.position = [ FL FR ]
            }
            playback.props = {
                audio.position = [ AUX0 AUX1 ]
                node.target = "alsa_output.usb-BEHRINGER_UMC1820_B572BD9B-00.pro-output-0"
                stream.dont-remix = true
                node.passive = true
            }
        }
    }

    # Virtual input example
    # TODO

#]
```

## PuTTY (Windows)

- In `Terminal > Features`, activate `Disable application keypad mode`.
- In `Window > Appearance`, change font to Consolas, regular, size 10.
- In `Window > Colours`, set all ANSI non-bold colors to the same as the bold ones.

## Screen

### Usage

#### Serial

- Open serial session: `screen /dev/ttyUSB0 38400,-crtscts` (38400 baud, no flow control)
- End session: `Ctrl+A, \`
- (Note) For some devices, you may need to use `Ctrl+H` instead of backspace.

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

- New key (RSA): `ssh-keygen -t rsa -b 2048`
- New key (EdDSA): `ssh-keygen -t ed25519`
- New key (RSA + comment + file + no-pass): `ssh-keygen -t rsa -b 2048 -C "yolo" -f ~/.ssh/id_rsa -N ""`

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
    - Global (Debian): `/etc/vim/vimrc`
    - Global (Arch): `/etc/vimrc`
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
1. Setup fonts:
    1. Download and install the suggested fonts (MesloLGS NF): [Fonts (powerlevel10k)](https://github.com/romkatv/powerlevel10k#fonts)
        - For manual installation, move the `.ttf` files to `/usr/share/fonts/TTF/`.
        - For KDE Plasma, download and open with the font installer.
    1. Configure your terminal to use the font.
1. Setup Powerlevel10k theme:
    1. Clone the theme: `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k`
    1. In `~/.zshrc`, set `ZSH_THEME="powerlevel10k/powerlevel10k"`.
    1. Open a new ZSH session (or restart your terminal).
    1. Configure the theme (if it didn't automatically start): `p10k configure`
1. Make zprofile include profile (to avoid breaking certain things):
    1. In `~/.zprofile`, add: `emulate sh -c "source /etc/profile"`
1. (Optional) Setup syntax highlighting plugin:
    1. Clone it: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
    1. Add `zsh-syntax-highlighting` it to `plugins` in `~/.zshrc`.
1. (Optional) Setup fuzzy search plugin:
    1. Install: `yay -S fzf-git`
    1. Add to your zshrc: `source /etc/profile.d/fzf.zsh`
1. Setup plugins:
    1. In `~/.zshrc`, set e.g. `plugins=(git docker docker-compose golang rust)`.
1. Further customize configs:
    1. Example [zsh configs](https://github.com/HON95/configs/blob/master/zsh/zshrc).

{% include footer.md %}
