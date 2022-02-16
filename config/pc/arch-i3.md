---
title: Arch (i3)
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

For Arch with LUKS encrypted root (and boot), using the i3 (gaps) window manager.

### Related Pages
{:.no_toc}

- [Applications: i3](../applications/#i3)

## Resources

### Arch

- [Installation guide (Arch Wiki)](https://wiki.archlinux.org/title/Installation_guide)
- [General recommendations (Arch Wiki)](https://wiki.archlinux.org/title/General_recommendations)
- [Frequently asked questions (Arch Wiki)](https://wiki.archlinux.org/title/Frequently_asked_questions)
- [List of applications (Arch Wiki)](https://wiki.archlinux.org/title/List_of_applications)
- [dm-crypt/Encrypting an entire system (Arch Wiki)](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)

### i3

- [i3 User's Guide](https://i3wm.org/docs/userguide.html)

## TODO

- The "i3 User's Guide"
- Plymouth
- LightDM "Multiple-monitor setup"
- picom compositor
- https://wiki.archlinux.org/title/Power_management
- https://wiki.archlinux.org/title/Display_Power_Management_Signaling
- Screen snippet tool
- xautolock?

## Installation

### Live Image Install

1. (Pre install) Download and burn an Arch ISO:
    - [Arch downloads](https://archlinux.org/download/).
    - Always verify the ISO's hash or PGP signature found on the Arch download page (not from the download mirrors).
1. (Pre install) Disable secure boot in the BIOS settings.
1. Boot into the Arch live image:
    1. Make sure you're in UEFI BIOS mode. Disable CSM in the BIOS settings if you don't need legacy BIOS for anything, to avoid future complications.
    1. Avoid broken display drivers: In the GRUB bootloader menu, press `E` on the main entry, add `nomodeset` at the end, and press enter to boot.
1. Set the keymap:
    1. List available keymaps: `ls /usr/share/kbd/keymaps/**/*.map.gz | less`
    1. Find the appropriate keymap, e.g. the Norwegian `no` for `/usr/share/kbd/keymaps/i386/qwerty/no.map.gz`
    1. Load: `loadkeys <keymap>` (e.g. `loadkeys no`)
1. Verify the (UEFI) boot mode:
    1. Check `efivar --list` or `ls /sys/firmware/efi/efivars`. If either exists, it's in UEFI mode.
1. Setup networking:
    1. (Note) For cabled Ethernet with DHCP, it should already be working. For WLAN or exotic setups, check the wiki.
    1. Test it somehow (e.g. with `ping` or `curl`).
1. Setup time:
    1. Enable NTP: `timedatectl set-ntp true`
    1. Check the "synchronized" line from `timedatectl`.
1. Partition the main disk (for LUKS encryption):
    1. Find the main disk: `lsblk`
    1. (Optional) Overwrite the full disk to get rid of all traces of the previous install: `dd if=/dev/zero of=/dev/<disk> bs=1M conv=fsync status=progress`
    1. See the main disk partition table below for an overview of the partition to create.
    1. Setup and partition the disk: `fdisk /dev/<disk>`
        1. Create a new GPT partition table: `g`
        1. Start the new partition wizard (for each partition): `n`
            - Partition number: See table.
            - First sector: Default.
            - Last sector (effectively partition size): See table. e.g. `+512M` for a 512MiB volume or nothing to fill it all.
        1. Set the partition type (for each partition): `t`
            - Partition number and type: See table.
        1. Show partitions: `p`
        1. Write to disk and exit: `w`
1. Format the ESP:
    1. `mkfs.fat -F32 /dev/<partition-1>`
1. Create encrypted root volume:
    1. (Note) GRUB has limited support for LUKS2, so use LUKS1.
    1. Check which cryptohash and encryption algorithms are fastest on the system: `cryptsetup benchmark`
    1. Create: `cryptsetup luksFormat --type=luks1 --use-random -h sha256 -i 5000 -c aes-xts-plain64 -s 256 /dev/<partition-2>` (example parameters)
    1. Enter the password to unlock the system during boot.
    1. (Note) See the step way down for avoiding entering the password twice during boot.
1. Unlock the encrypted root volume:
    1. `cryptsetup luksOpen /dev/<partition> crypt_root` (for example name `crypt_root`)
1. Format the root volume:
    1. `mkfs.ext4 /dev/mapper/crypt_root`
1. Mount the volumes:
    - Mount root: `mount /dev/mapper/crypt_root /mnt`
    - Mount ESP: `mkdir -p /mnt/boot/efi && mount /dev/<partition> /mnt/boot/efi`
1. Install packages to the new root:
    - Base command and packages: `pacstrap /mnt base linux linux-firmware vim sudo bash-completion man-db man-pages xdg-utils xdg-user-dirs`
    - **TODO** Maybe for laptops: `wpa_supplicant networkmanager`
1. Generate the fstab file:
    1. `genfstab -U /mnt >> /mnt/etc/fstab`
    1. Check it for errors or duplicates.
1. Chroot into the new root:
    1. `arch-chroot /mnt`
1. Setup localization:
    1. Set time zone: `ln -sf /usr/share/zoneinfo/<region>/<city> /etc/localtime`
    1. Update the hardware clock (using UTC): `hwclock --systohc`
    1. Uncomment locales to generate: `vim /etc/locale.gen`
        - Always include `en_US.UTF-8 UTF-8`.
    1. Generate selected locales: `locale-gen`
    1. Set the locale: In `/etc/locale.conf`, set `LANG=<locale>` (e.g. `LANG=en_US.UTF-8`).
    1. Set the keyboard layout: In `/etc/vconsole.conf`, set `KEYMAP=<keymap>` (e.g. `KEYMAP=no`).
1. Set hostname:
    1. `echo <hostname> > /etc/hostname`
1. Set the root password:
    1. `passwd`
1. Create the initial ramdisk:
    1. Add extra hooks: In `/etc/mkinitcpio.conf`, find the `HOOKS=()` line. Add `encrypt` after `block` and `keymap` after `keyboard` (ordering matters).
    1. Create the initial ramdisk: `mkinitcpio -P`
1. Setup GRUB:
    1. Install bootloader: `pacman -S grub efibootmgr`
    1. Install CPU microcode updates: `pacman -S X-ucode` (for `X={amd, intel}`)
    1. Enable encrypted disk support: In `/etc/default/grub`, set `GRUB_ENABLE_CRYPTODISK=y`.
    1. Find the UUID of the encrypted root partition: `blkid`
    1. Add kernel parameters for the encrypted root (e.g. `/dev/sda2`): In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptdevice=UUID=<device-UUID>:crypt_root root=/dev/mapper/crypt_root`.
    1. Install GRUB to ESP: `grub-install --target=x86_64-efi --efi-directory=/boot/efi`
    1. Generate GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`
1. Exit the chroot and reboot:
    1. `exit`
    1. `reboot`
1. Wait for the GRUB screen.

### Post Install Setup

1. Boot into the newly installed system:
    1. Avoid broken display drivers: In the GRUB bootloader menu, press `E` on the main entry and add `nomodeset` at the end of the `linux` line. Press `Ctrl+X` to continue. After proper display drivers are installed, this is no longer required.
1. (Optional) Disable the beeper:
    1. Unload the module: `rmmod pcspkr`
    1. Blacklist the module: `echo blacklist pcspkr > /etc/modprobe.d/nobeep.conf`
1. Setup default editor:
    - Create a new profile file: `/etc/profile.d/editor.sh`
    - Set the editor: `export EDITOR=vim`
    - Set the visual editor: `export VISUAL=vim`
1. Setup wired networking:
    1. Enable and start: `systemctl enable --now systemd-networkd`
    1. Add a config for the main interface (or all interfaces): See the section with an example below.
    1. Restart: `systemctl restart systemd-networkd`
    1. Wait for connectivity (see `ip a`).
1. Setup DNS server(s):
    1. `echo nameserver 1.1.1.1 >> /etc/resolv.conf` (Cloudflare)
    1. `echo nameserver 2606:4700:4700::1111 >> /etc/resolv.conf` (Cloudflare)
1. Setup Pacman:
    1. Enable color: In `/etc/pacman.conf`, uncomment `Color`.
1. Update the system and install useful stuff:
    1. Upgrade: `pacman -Syu`
    1. Install useful tools: `pacman -S --needed most zsh vim man-db man-pages htop bash-completion p7zip git jq rsync openssh tmux screen reflector usbutils`
1. Install display driver:
    - (Note) For AMD GPUs, Intel GPUs, older NVIDIA GPUs etc., check the Arch wiki.
    - For NVIDIA Maxwell and newer GPUs: `pacman -S nvidia nvidia-utils nvidia-settings`.
    - (Optional) For NVIDIA CUDA (in addition to driver): `pacman -S cuda`
1. Avoid having to enter the encryption password twice during boot:
    1. (Note) To avoid entering the password once for GRUB and then for the initramfs, we can create a keyfile and embed it into the initramfs. If the keyfile fails, it will fall back to asking for a password again.
    1. Secure the boot dir: `chmod 700 /boot`
    1. Generate keyfile:
        1. `mkdir -p /root/.keys && chmod 700 /root/.keys`
        1. `dd if=/dev/random of=/root/.keys/crypt_root bs=2048 count=1 iflag=fullblock`
        1. `chmod 600 /root/.keys/crypt_root`
    1. Add key to LUKS: `cryptsetup luksAddKey /dev/<partition> /root/.keys/crypt_root`
    1. Add key to initramfs: In `/etc/mkinitcpio.conf`, set `FILES=(/root/.keys/crypt_root)`.
    1. Recreate initramfs: `mkinitcpio -P`
    1. Add extra kernel parameters for the keyfile: In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptkey=rootfs:/root/.keys/crypt_root`.
    1. Update GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`
    1. Reboot to make sure it works. If not, it should fall back to the extra password prompt.
1. Setup sudo:
    1. (Note) Both the `wheel` and `sudo` groups are commonly used for giving sudo access, but I personally prefer `sudo` since `wheel` _may_ also be used by polkit rules, su (`pam_wheel`), etc.
    1. Install: `pacman -S sudo`
    1. Add the sudo group: `groupadd -r sudo`
    1. Enter the config: `EDITOR=vim visudo`
    1. Add line to allow sudo group without password: `%sudo ALL=(ALL) NOPASSWD: ALL`
    1. (Later) Give users sudo access through the group: `usermod -aG sudo <user>`
1. Add a personal user:
    1. Create the user and add it to relevant groups: `useradd -m -G sudo,adm,sys,uucp,proc,systemd-journal <user>`
    1. Set its password: `passwd <user>`
    1. Relog as the new user, both to make sure that it's working and because some next steps require a non-root user.
1. Install yay to access the AUR:
    1. (Note) This needs to be done as non-root.
    1. Install requirements: `sudo pacman -S --needed base-devel git`
    1. Clone and enter: `git clone https://aur.archlinux.org/yay.git && cd yay`
    1. Install: `makepkg -si`
    1. Remove the tmp. repo: `cd .. && rm -rf yay`
    1. Idk (once): `yay -Y --gendb`
1. Enable early numlock (initramfs phase):
    1. Install package: `yay -S mkinitcpio-numlock`
    1. Add `numlock` to the `HOOKS` list in `/etc/mkinitcpio.conf` before `encrypt` (assuming the system is encrypted) (e.g. before `modconf`).
    1. Regenerate the initramfs: `mkinitcpio -P`
1. Tweak the PAM login faillock:
    1. (Note) It applies to password logins only, not SSH keys.
    1. (Note) To unlock a user, run `faillock --reset --user <user>`.
    1. Increase the failed login count threshold: In `/etc/security/faillock.conf`, set `deny = 5`.
1. Setup the local DNS resolver (systemd):
    1. (Note) The systemd-resolve config is `/etc/systemd/resolved.conf`.
    1. (Optional) Configure static upstream DNS servers (don't use any provided by DHCP/SLAAC): In the confug, set `DNS=1.1.1.1 2606:4700:4700::1111`.
    1. (Optional) Set the domain/search string: In the config, set `Domains=<domain>`.
    1. Enable or disable DNSSEC validation (do if the upstream servers don't): In the config, set `DNSSEC=<yes|no>`.
    1. Enable and start it: `systemctl enable --now systemd-resolved`
    1. Setup `resolv.conf`: `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
    1. Check: `curl google.com`
1. Setup the NTP client (systemd):
    1. (Note) The default server pool is fine.
    1. Enable: `timedatectl set-ntp true`
    1. Check: `timedatectl` (see the "synchronized" field)
1. Setup firewall (IPTables):
    1. Install IPTables: `sudo pacman -S iptables`
    1. Enable the IPTables services: `sudo systemctl enable --now iptables.service ip6tables.service`
    1. Download my IPTables script (or do it yourself): `curl https://raw.githubusercontent.com/HON95/scripts/master/iptables/iptables.sh -o /etc/iptables/config.sh`
    1. Make it executable: `chmod +x /etc/iptables/config.sh`
    1. Modify it.
    1. Run it: `/etc/iptables/config.sh`
1. Setup colored man pages:
    1. Install the most pager: `sudo pacman -S most`
    1. Set it as the default pager: In `.bashrc` and/or `.zshrc`, set `export PAGER=most`

### Setup the Xorg Display Server

1. Install: `sudo pacman -S xorg-server xorg-xinit xorg-xrandr`
1. Fix the keyboard layout for X11: `sudo localectl set-x11-keymap <keymap>` (e.1. `no`)

### Setup the LightDM or Ly Display Manager

Note: Install either the LightDM (GUI) or Ly (TUI) display manager, not both.

#### LightDM

1. Setup LightDM:
    1. (Note) User-local configuration/profile-stuff should be placed in `~/.xprofile`.
    1. Install: `sudo pacman -S lightdm`
    1. Enable: `systemctl enable lightdm`
1. Setup the LightDM GTK+ greeter (aka login screen) (one of many):
    1. (Note) The GTK+ greeter may be configured in `/etc/lightdm/lightdm-gtk-greeter.conf` or using the `lightdm-gtk-greeter-settings` GUI.
    1. Install: `sudo pacman -S lightdm-gtk-greeter`
    1. Set it as the default: In `/etc/lightdm/lightdm.conf`, under the `[Seat:*]` section, set `greeter-session=lightdm-gtk-greeter`.
    1. (Optional) Set the background: In `/etc/lightdm/lightdm-gtk-greeter.conf`, under the `[greeter]` section, set `background=<image-path>`. The `/usr/share/pixmaps` dir is recommended for storing backgrounds.
1. Enable numlock on by default in X11:
    1. Install: `sudo pacman -S numlockx`
    1. Configure: In `/etc/lightdm/lightdm.conf`, under the `[Seat:*]` section, set `greeter-setup-script=/usr/bin/numlockx on`.

#### Ly

1. Setup Ly:
    1. (Note) The config file is `/etc/ly/config.ini`.
    1. Install: `yay -S ly`
    1. Enable: `systemctl enable ly`
    1. Add fire background: In the config, set `animate = true` and `hide_borders = true`.
1. Enable numlock on by default in X11:
    1. Install: `sudo pacman -S numlockx`
    1. Configure: Create `/etc/X11/xinit/xinitrc.d/90-numlock.sh`, containing `#!/bin/sh` and `numlockx &`. Make it executable.

### Setup the i3 Window Manager and Stuff

1. Install i3:
    1. (Note) The "gaps" part will be set up later, i3-gaps will work just like plain i3 for now.
    1. Install: `sudo pacman -S i3-gaps`
1. Setup the Polybar system bar:
    1. (Note) i3bar, the default i3 system bar, shows workspaces and tray icons. It can include extra info like IP addresses and resource usage using i3status or i3blocks. Polybar is a replacement for i3bar.
    1. Disable i3bar: Comment the whole `bar` section of the i3 config.
    1. Install polybar: `yay -S polybar`
    1. Create the config: `mkdir ~/.config/polybar && cp /usr/share/doc/polybar/config ~/.config/polybar/config`
    1. Customize config:
        - Rename the "example" bar to e.g. "main" (or create one from scratch).
        - Set the font: In the bar section, remove the existing `font-<n>` statements. Set `font0 = <family>:style=<s>:size=<n>;<vertical-offset>` (e.g. `font-0 = "MesloLGS NF:style=Regular:size=9;2"`). Use `fc-list | grep <font-name>` (the part after the first colon) to search for fonts. Make sure to use a Unicode-compatible font (which the default may not be.
        - For the bar, set `bottom = true` to move it to the bottom.
        - For the bar, comment `radius` to disable rounded corners.
        - For the bar, comment `border-size` to disable the padding/border around the bar.
        - For the date module, customize how time should appear. "Alt" variants are swapped to when the module is clicked.
        - For the network/"eth" module, use `%local_ip6%` for the IPv6 address (one of them). Maybe clone the module to have one for IPv4 and one for IPv6. Maybe change the color to purple (`#800080`), so it doesn't clash with the Spotify module (if added).
        - Update the panel modules in the `modules-{left,center,right}` variables.
    1. Create a startup script: See the section below to use the new "main" bar.
    1. Add to i3: In the i3 config, add `exec_always --no-startup-id $HOME/.config/polybar/launch.sh`.
1. Setup the Alacritty terminal emulator (or some other):
    1. Install: `sudo pacman -S alacritty`
    1. Create the config dir: `mkdir ~/.config/alacritty/`
    1. (Optional) Download the Dracula theme: `curl https://raw.githubusercontent.com/dracula/alacritty/master/dracula.yml -o ~/.config/alacritty/dracula.yml`
    1. Configure: Setup `~/.config/alacritty/alacritty.yml`, see the example config below.
    1. Setup i3: In the i3 config, replace the `bindsym $mod+Return ...` line with `bindsym $mod+Return exec alacritty`
    1. Fix `TERM` for SSH (since the remote probably don't have Alacritty terminal support): In `.zshrc` (or `.bashrc` if using BASH), set `alias ssh="TERM=xterm-256color ssh"`.
    1. (Note) Press `Ctrl+Shift+Space` to enter vi mode, allowing you to e.g. move around (and scroll up) using arrow keys and select text using `V` or `Shift+V`. Press `Ctrl+Shift+Space` again to exit.
1. Setup the Rofi application launcher:
    1. Install: `sudo pacman -S rofi`
    1. Install rofimoji for emoji menu: `sudo pacman -S rofimoji xdotool`
    1. Find a theme interactively (without selecting any): `rofi-theme-selector` (e.g. `glue_pro_blue`)
    1. Configure Rofi: Create `~/.config/rofi/config.rasi`, see the example below.
    1. Configure Rofimoji: Create `~/.config/rofimoji.rc` and set `action = copy` (copy to clipboard by default).
    1. Disable old i3 dmenu shortcut: In the i3 config, comment the `bindsym $mod+d` line.
    1. Setup i3 drun shortcut: In the i3 config, set `bindsym $mod+d exec rofi -show drun`.
    1. Setup i3 window shortcut: In the i3 config, set `bindsym $mod+shift+d exec rofi -show window`.
    1. Setup i3 emoji shortcut: In the i3 config, set `bindsym $mod+mod1+d exec rofi -modi "emoji:rofimoji" -show emoji`.
1. Setup fonts:
    1. `sudo pacman -S noto-fonts notn-fonts-emoji`
1. (Optional) Test the display server, display manager and and window manager:
    1. Restart LightDM/Ly and get pulled into it: `systemctl restart lightdm` or `[...] ly`
    1. Select the i3 WM and log in.
    1. Follow the basic i3 setup wizard:
        1. Generate a new config.
        1. `Win` as default modifier.
    1. Test i3: `Mod+Return` to open terminal, `Mod+D` to open app launcher, etc.
1. Setup background image:
    1. Download a desktop image.
    1. Install the FEH image viewer: `sudo pacman -S feh`
    1. Update i3: In the i3 config, set `exec_always --no-startup-id feh --bg-scale $HOME/Pictures/mc.jpg` (example image).
1. (Optional) Disable mouse hover window focus (you can still click windows to focus):
    1. In the i3 config, set `focus_follows_mouse no`.
1. Setup i3 gaps:
    1. Disable window title bar (required): In the i3 config, add `for_window [class=".*"] border pixel 4` to only show the border and no title bar, or `0` to remove the border too.
    1. Add gaps around windows: In the i3 config, add `gaps inner 8`.
1. Install clipboard manager:
    1. `sudo pacman -S xsel`
1. Setup media keys:
    1. (Note) Install e.g. Spotify (`aur/spotify`) to test with.
    1. Install the playerctl utility for easy control: `sudo pacman -S playerctl`
    1. Add the following to the i3 config: See the i3 media keys config snippet below.
1. Tweak audio volume keys:
    1. Install `pamixer` (like ALSA's `amixer` but for PulseAudio): `sudo pacman -S pamixer`
    1. Open the i3 config and find the `bindsym XF86AudioRaiseVolume` and similar lines.
    1. See the config i3 volume keys snippet below.
1. Setup screen locking:
    1. **TODO** Multi-monitor support? Haven't tested yet.
    1. Install the `i3lock-fancy` screen locker: `yay -S i3lock-fancy-git`
    1. Install the `xss-lock` automatic locker trigger: `sudo pacman -S xss-lock`
    1. Update i3 to use `i3lock-fancy`: In the i3 config, find the example `xss-lock` line and replace it with `exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock-fancy --nofork`. i3 needs to be completely restarted for this to start.
    1. Set a locking keybind in i3: In the i3 config, add `bindsym $mod+l exec --no-startup-id i3lock-fancy --nofork`. This may conflict with some `focus` keybinds you probably don't need, so just remove those.
1. Setup a Spotify module for Polybar:
    1. Install: `yay -S polybar-spotify-git`
    1. In the Polybar config (`~/.config/polybar/config`), add a module `spotify` (see config snipper below) and add it to some bar module section.

### Setup Multiple Displays and Stuff

1. (Optional) Try `xrandr` to get familiar with the displays:
    1. (Note) Changes made using the command line are not persistent.
    1. Show current config: `xrandr`
    1. (Note) The resolution with `+` is the oreferred and the one with `*` is the active one.
    1. Activate/update a display: `xrandr --output <display> [--primary] [--right-of <other-display>] [--rotate left] --auto` (auto selects the preferred resolution and frame rate)
    1. Deactivate a display: `xrandr --output <display> --off`
1. Persistent config:
    1. Get display output names and stuff: `xrandr`
    1. Open `/etc/X11/xorg.conf.d/10-monitor.conf` for editing.
    1. For each connected monitor, create a section. See below for an example.

### Setup Audio

Note: We're using the PipeWire sound server, a modern, security-focused and compatible replacement for both PulseAudio and JACK.

1. Install ALSA stuff:
    1. (Note) ALSA itself is already provided as built-in kernel modules and ALSA drivers will just work.
    1. Install ALSA utils and firmware: `sudo pacman -S alsa-utils alsa-firmware`
1. Install PipeWire (including WirePlumber and adapters):
    1. Install: `sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 wireplumber pavucontrol`
    1. Start the PulseAudio adapter (to avoid relogging): `systemctl start --user pipewire-pulse`
1. Configure inputs and outputs:
    1. Run `pavucontrol` to configure volumes, inputs, outputs and stuff.
1. Test it:
    1. Try playing something from the browser or whatever. It should work.
1. **TODO** Bluetooth support. Check the PipeWire page.
1. Install useful audio applications:
    1. Install the Helvum patchbay to patch nodes and endpoints (inputs and outputs for all audio devices): `sudo pacman -S helvum`
    1. See the [PipeWire page (Arch Wiki)](https://wiki.archlinux.org/title/PipeWire).

### Setup Applications

1. Setup terminal emulator: Already done.
1. Setup the ZSH shell: See [Applications: ZSH](../applications/#zsh-linux) (includes font, theme and plugins).
1. Setup the VLC video and audio player: `sudo pacman -S vlc`
1. Setup the Mirage image viewer: `yay -S mirage`
1. Setup the Thunar graphical file manager: `sudo pacman -S thunar`
1. Setup the Ranger terminal file explorer: `sudo pacman -S ranger`
1. Setup the VS Code text editor/IDE: `sudo pacman -S code`
    - Alternatively `visual-studio-code-bin` (AUR) for the Microsoft binary distribution with tracking and Microsoft extensions.
1. Setup the LibreOffice office document suite: `sudo pacman -S libreoffice-fresh`
1. Setup the Okular PDF reader: `sudo pacman -S okular`

### Setup Bluetooth

1. (Note) Make sure `rfkill` or some hardware switch isn't disabling/blocking the adapter.
1. Setup the base stack:
    1. (Note) The canonical Bluetooth implementation is BlueZ.
    1. Install: `sudo pacman -S bluez bluez-utils`
    1. Enable and start: `sudo systemctl enable --now bluetooth.service`
    1. (Optional) Allow users to use Bluetooth networking or something: Add the users to the `lp` group.
    1. (Optional) Enable auto power-on after boot and resume: In `/etc/bluetooth/main.conf`, in the `Policy` section, set `AutoEnable = true`.
1. Setup audio:
    1. (Note) Using PipeWire and its PulseAudio adapter (`pipewire-pulse`), which should already have been set up and includes support for Bluetooth.
1. **TODO** See https://wiki.archlinux.org/title/bluetooth_headset
1. Setup Blueman:
    1. **TODO** This broke for some reason, the GUIs won't open and the tray icon won't show. I haven't bothered fixing it yet.
    1. (Note) Blueman is a Bluetooth manager with a practical tray icon.
    1. Install: `pacman -S blueman`
    1. Enable tray icon on i3 start: In the i3 config, add `exec --no-startup-id blueman-applet`. (**TODO** Test.)
    1. (Optional) Try to run it. It's the "Bluetooth Manager" entry in e.g. Rofi.
1. (Example) Connect a device using `bluetoothctl`:
    1. Note: To avoid entering the interactive TUI and run single commands instead, use `bluetoothctl -- <cmd>`.
    1. Enter the TUI: `bluetoothctl`
    1. List controllers: `list`
    1. (Optional) Select a controller: `select <mac>`
    1. Enable the controller: `power on`
    1. Enable scanning: `scan on`
    1. List available devices: `devices`'
    1. Enable the pairing agent: `agent on`
    1. Set the agent as default: `default-agent`
    1. Pair with device: `pair <mac>`
    1. Trust it, maybe (**TODO** required?): `trust <mac>`
    1. Connect to device: `connect <mac>`
    1. Disable scanning (**TODO** required?): `scan off`
    1. Exit: `Ctrl+D`

### Extra (Optional)

- Setup secure boot using your own keys.

### Notes and Snippets

#### Main Disk Partitions

| Partition Number | Size | Type | Description | Mountpoint |
| - | - | - | - | - |
| 1 | 512MiB | ESP, 1 (fdisk), EF00 (gdisk) | EFI system partition (ESP) | `/boot/efi/` |
| 2 | Remaining | Doesn't matter | LUKS | `/` |

**Swap**:

Avoid creating an unencrypted swap partition. Just use a swap file in the (encrypted) root filesystem instead.

#### systemd-networkd Network Config

File: `/etc/systemd/network/eno1.network` (example)

This example sets up interface `eno1` (the main interface, see `ip a`) to use DHCPv4 and SLAAC/DHCPv6. The `DHCP` and `IPV6ACCEPTRA` sections are optional, the default values are typically fine.

```
[Match]
Name=eno1

[Network]
DHCP=yes

[DHCP]
UseDNS=yes
UseNTP=no
UseHostname=no
UseDomains=yes

[IPV6ACCEPTRA]
UseDNS=yes
UseDomains=yes
```

#### Alacritty Config

File: `~/.config/alacritty/alacritty.yml`

```yaml
font:
  # normal:
  #   family: MesloLGS NF
  #   style: Regular
  size: 9

import:
  # Theme
  - ~/.config/alacritty/dracula.yml
```

#### Polybar Launch Script

File: `~/.config/polybar/launch.sh`

```bash
#!/bin/bash

killall -q polybar

polybar main &>>/tmp/polybar.log

echo "Polybar launched"
```

#### Polybar Spotify Module

File: `~/.config/polybar/config`

```
[module/spotify]
type = custom/script
interval = 1
format = <label>
exec = python /usr/share/polybar/scripts/spotify_status.py -f '[{artist}] {song}'
format-underline = #1db954
```

#### Rofi Config

file: `~/.config/rofi/config.rasi`

```
configuration {
    font: "MesloLGS NF 10";
}
@theme "glue_pro_blue"
```

#### Xorg Displays

File: `/etc/X11/xorg.conf.d/10-monitor.conf`

```
Section "Monitor"
    Identifier "DP-4"
    Option "Primary" "true"
EndSection

Section "Monitor"
    Identifier "DVI-I-1"
    Option "RightOf" "DP-4"
    Option "Rotate" "left"
EndSection
```

#### i3 Media Keys

File: `~/.config/i3/config`

Requires `community/playerctl`.

```
# Media keys
bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause
bindsym XF86AudioStop exec --no-startup-id playerctl stop
bindsym XF86AudioPrev exec --no-startup-id playerctl previous
bindsym XF86AudioNext exec --no-startup-id playerctl next
```

#### i3 Volume Keys

File: `~/.config/i3/config`

Requires `community/pamixer`.

```
# Volume keys
bindsym XF86AudioRaiseVolume exec --no-startup-id pamixer -i 5
bindsym XF86AudioLowerVolume exec --no-startup-id pamixer -d 5
bindsym XF86AudioMute exec --no-startup-id pamixer -t
bindsym XF86AudioMicMute exec --no-startup-id pamixer --default-source -t
```

{% include footer.md %}
