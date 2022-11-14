---
title: Arch (i3)
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

For Arch with LUKS encrypted root (and boot), using the i3 window manager.

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
- picom compositor

## Installation

Note: The use of `sudo` in the text below is a bit inconsistent, but you should know when you need it and when you don't.

### Live Image Install

1. (Pre install) Download and burn an Arch ISO:
    - [Arch downloads](https://archlinux.org/download/).
    - Always verify the ISO's hash or PGP signature found on the Arch download page (not from the download mirrors).
1. (Pre install) Disable secure boot in the BIOS settings.
1. Boot into the Arch live image:
    1. Make sure you're in UEFI BIOS mode. Disable CSM in the BIOS settings if you don't need legacy BIOS for anything, to avoid future complications.
    1. Avoid broken display drivers: In the GRUB bootloader menu, press `E` on the main entry, add `nomodeset` at the end, and press enter to boot.
1. Set the keymap:
    1. (Optional) List available keymaps: `ls /usr/share/kbd/keymaps/**/*.map.gz | less`
    1. (Optional) Find the appropriate keymap, e.g. the Norwegian `no` for `/usr/share/kbd/keymaps/i386/qwerty/no.map.gz`
    1. Load: `loadkeys <keymap>` (e.g. `loadkeys no`)
1. Verify the (UEFI) boot mode:
    1. Check `efivar --list` or `ls /sys/firmware/efi/efivars`. If either exists, it's in UEFI mode.
1. Setup live-OS networking:
    1. (Note) For cabled Ethernet with DHCP, it should already be working. For WLAN or exotic setups, check the wiki.
    1. (Optional) Test it somehow (e.g. with `ping` or `curl`).
1. Setup live-OS time:
    1. Enable NTP: `timedatectl set-ntp true`
    1. (Optional) Check the "synchronized" line from `timedatectl`.
1. If your live-OS is outdated, update the keyring: `pacman -Sy && pacman -S archlinux-keyring`
1. Partition the main disk (for LUKS encryption):
    1. Find the main disk: `lsblk`
    1. (Optional) Overwrite the full disk to get rid of all traces of the previous install: `dd if=/dev/zero of=/dev/<disk> bs=1M conv=fsync status=progress`
    1. (Note) Create these partitions by repeatedly running the steps below:
        - Partition 1: Size 512MiB, type ESP (type 1 in fdisk and EF00 in gdisk), mountpoint `/boot/efi/`.
        - Partition 2: Remaining space, type doesn't matter (leave as-is). Will contain the encrypted root filesystem.
        - **TODO** Maybe add an _encrypted_ swap partition. For hibernation support and stuff, idk.
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
1. Format the ESP (first partition):
    1. `mkfs.fat -F32 /dev/<partition-1>`
1. Create encrypted root volume (second partition):
    1. (Note) GRUB currently has limited support for LUKS2, so use LUKS1.
    1. Check which cryptohash and encryption algorithms are fastest on the system: `cryptsetup benchmark`
    1. Create: `cryptsetup luksFormat --type=luks1 --use-random -h sha256 -i 1000 -c aes-xts-plain64 -s 256 /dev/<partition-2>` (example parameters)
    1. Enter the password to unlock the system during boot.
    1. (Note) There is a later step for avoiding entering the password twice during boot.
1. Unlock the encrypted root volume:
    1. `cryptsetup luksOpen /dev/<partition> crypt_root` (for example name `crypt_root`)
1. Format the root volume:
    1. `mkfs.ext4 /dev/mapper/crypt_root`
1. Mount the volumes:
    - Mount root: `mount /dev/mapper/crypt_root /mnt`
    - Mount ESP: `mkdir -p /mnt/boot/efi && mount /dev/<partition> /mnt/boot/efi`
1. Install packages to the new root:
    - Base command and packages: `pacstrap /mnt <packages>`
    - Base packages: `base linux linux-firmware intel-ucode amd-ucode archlinux-keyring sudo bash-completion man-db man-pages xdg-utils xdg-user-dirs vim tar zip unzip`
    - Extra packages: `smartmontools lm_sensors hwloc zsh htop base-devel git jq rsync openssh tmux screen usbutils tcpdump nmap inetutils`
    - Wireless networking packages: `iwd`
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
        - Norway is `nb_NO.UTF-8 UTF-8`.
    1. Generate selected locales: `locale-gen`
    1. Set the locale: In `/etc/locale.conf`, set `LANG=<locale>` (e.g. `LANG=en_US.UTF-8`).
    1. Set the TTY keyboard layout: In `/etc/vconsole.conf`, set `KEYMAP=<keymap>` (e.g. `KEYMAP=no`).
1. Set hostname:
    1. `echo <hostname> > /etc/hostname`
1. Set the root password:
    1. `passwd`
1. Create the initial ramdisk:
    1. Add extra hooks: In `/etc/mkinitcpio.conf`, find the `HOOKS=()` line. Add `encrypt` after `block` and `keymap` after `keyboard` (ordering matters).
    1. Create the initial ramdisk: `mkinitcpio -P`
1. Setup GRUB:
    1. Install bootloader: `pacman -S grub efibootmgr`
    1. Enable encrypted disk support: In `/etc/default/grub`, set `GRUB_ENABLE_CRYPTODISK=y`.
    1. Find the `UUID` of the encrypted root partition: `blkid`
    1. Add kernel parameters for the encrypted root (e.g. `/dev/sda2`): In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptdevice=UUID=<device-UUID>:crypt_root root=/dev/mapper/crypt_root`.
    1. Install GRUB to ESP: `grub-install --target=x86_64-efi --efi-directory=/boot/efi`
    1. Generate GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`
1. Exit the chroot and reboot:
    1. `exit`
    1. `reboot`
1. Wait for the GRUB screen or decryption prompt.

### Post Install Setup

1. Boot into the newly installed system:
    1. (Optional) Avoid broken display drivers (typically needed for NVIDIA cards): In the GRUB bootloader menu, press `E` on the main entry and add `nomodeset` at the end of the `linux` line. Press `Ctrl+X` to continue. After proper display drivers are installed, this is no longer required.
1. (Optional) Disable the beeper:
    1. Unload the module: `rmmod pcspkr`
    1. Blacklist the module: `echo blacklist pcspkr > /etc/modprobe.d/nobeep.conf`
1. Setup default editor:
    - Create a new profile file: `/etc/profile.d/editor.sh`
    - Set the editor: `export EDITOR=vim`
    - Set the visual editor: `export VISUAL=vim`
1. Setup basic, wired networking:
    1. Enable: `systemctl enable systemd-networkd`
    1. Don't wait for network during boot: `systemctl disable systemd-networkd-wait-online.service`
    1. Add a config for the main interface (or all interfaces): See the section with an example below.
    1. (Re)start: `systemctl restart systemd-networkd`
    1. Wait for connectivity.
        - `networkctl` should show the interface as anything but "unmanaged".
        - `ip a` should show a routable IP address after a few seconds if using DHCP/RA.
1. (Optional) Setup wireless networking:
    1. (Note) Using iwd and systemd-network instead of e.g. wpa_supplicant and Network Manager.
    1. Make sure a driver is loaded for the WLAN device:
        - `ip a` should show a `wlp*` interface for the device.
        - `lspci -k` (for PCIe) or `lsusb -v` (for USB) should show a loaded module.
    1. Make sure the radio device isn't blocked: `rfkill` (should show "unblocked")
    1. Install iwd to manage wireless connections: `sudo pacman -S iwd`
    1. Create the `netdev` group and add yourself to it to control `iwd`:
        1. `sudo groupadd -r netdev`
        1. `sudo usermod -aG netdev <user>`
        1. `newgrp netdev` (optional, to avoid relogging in the current shell)
    1. Configure iwd:
        - (Note) Config file: `/etc/iwd/main.conf` (INI)
        - (Optional) Disable periodic scanning when disconnected: In section `[Scan]`, set `DisablePeriodicScan=true`.
    1. Enable iwd: `sudo systemctl enable --now iwd.service`
        - If this fails, you may need to reboot.
    1. Setup GUI and tray icon:
        1. Install (with snixembed compat library for Polybar): `yay -S iwgtk snixembed-git`
        1. Start snixembed in i3 config: `exec --no-startup-id snixembed`
        1. (Optional) Remove the XDG autostart file: `sudo rm /etc/xdg/autostart/iwgtk-indicator.desktop`
        1. (Optional) Start tray icon in i3 config instead: `exec --no-startup-id iwgtk -i`
    1. Setup the network config:
        1. Create a systemd-network config similar to the one for the wired interface, but add `IgnoreCarrierLoss=5s` to the `Network` section to allow for roaming without disconnects.
        1. Restart systemd-networkd.
    1. (Example) Test the GUI: `iwgtk`
        - Might fail until relog/reboot.
    1. (Example) Connect to WPA2/WPA3 personal network (using `iwctl`):
        1. (Note) `iwctl` has extenside tab-complete support.
        1. Enter `iwctl`: `[sudo] iwctl`
        1. Show devices: `device list`
        1. Show device info: `device <device> show`
        1. Scan for networks: `station <device> scan`
        1. Show networks: `station <device> get-networks`
        1. Connect to network: `station <device> connect <SSID>`
        1. Show connection info: `station <device> show`
        1. Disconnect from the network: `station <device> disconnect`
        1. Show known networks: `known-networks list`
        1. Forget known network: `known-networks <SSID> forget`
    1. (Example) Connect to eduroam:
        1. (Note) See the [wiki](https://wiki.archlinux.org/title/Iwd#eduroam) for more info.
        1. Go to the [eduroam configuration assistant tool (CAT)](https://cat.eduroam.org/) to download a config script for your organization. **Don't run it**, it doesn't support `iwd`.
        1. Create the config file `/var/lib/iwd/eduroam.8021x` (name-sensitive), containing the template snippet below with values found in the eduroam script.
1. Setup DNS server(s):
    1. `echo "nameserver 1.1.1.1" >> /etc/resolv.conf` (Cloudflare)
    1. `echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf` (Cloudflare)
1. Setup Pacman:
    1. Enable color: In `/etc/pacman.conf`, uncomment `Color`.
    1. Enable the multilib repo (for 32-bit apps): In `/etc/pacman.conf`, uncomment the `[multilib]` section.
1. Update the system and install useful stuff:
    1. Upgrade: `pacman -Syu`
1. Install display driver and utils:
    - For NVIDIA Maxwell and newer GPUs: `pacman -S nvidia nvidia-utils nvidia-settings`.
    - (Optional) For NVIDIA CUDA (in addition to driver): `pacman -S cuda`
    - For newer AMD GPUs: `pacman -S mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver`
1. Avoid having to enter the encryption password twice during boot:
    1. (Note) To avoid entering the password once for GRUB and then for the initramfs, we can create a keyfile and embed it into the initramfs. If the keyfile fails, it will fall back to asking for a password again.
    1. Secure the boot dir (to protect the embedded key in the initramfs): `chmod 700 /boot`
    1. Generate keyfile:
        1. `mkdir -p /root/.keys/luks && chmod 700 /root/.keys`
        1. `dd if=/dev/random of=/root/.keys/luks/crypt_root bs=2048 count=1 iflag=fullblock && chmod 600 /root/.keys/luks/crypt_root`
    1. Add key to LUKS: `cryptsetup luksAddKey /dev/<partition> /root/.keys/luks/crypt_root`
    1. Add key to initramfs: In `/etc/mkinitcpio.conf`, set `FILES=(/root/.keys/luks/crypt_root)`.
    1. Recreate initramfs: `mkinitcpio -P`
    1. Add extra kernel parameters for the keyfile: In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptkey=rootfs:/root/.keys/luks/crypt_root`.
    1. Update GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`
    1. Reboot to make sure it works. If not, it should fall back to the extra password prompt.
1. Setup sudo:
    1. (Note) Both the `wheel` and `sudo` groups are commonly used for giving sudo access, but I personally prefer `sudo` since `wheel` _may_ also be used by polkit rules, su (`pam_wheel`), etc.
    1. Install: `pacman -S sudo`
    1. Add the sudo group: `groupadd -r sudo`
    1. Enter the config: `visudo`
    1. Add line to allow sudo group without password: `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`
    1. (Note) To give users sudo access through the group: `usermod -aG sudo <user>`
1. Add a personal admin user:
    1. Create the user and add it to relevant groups: `useradd -m -G sudo,adm,sys,uucp,proc,systemd-journal,video <user>`
    1. Set its password: `passwd <user>`
    1. Relog as the new user, both to make sure that it's working and because some next steps require a non-root user.
1. Install yay to access the AUR (as non-root):
    1. (Note) This needs to be done as non-root.
    1. Install requirements: `sudo pacman -S --needed base-devel git`
    1. Clone and enter: `git clone https://aur.archlinux.org/yay.git`
    1. Install: `cd yay && makepkg -si`
    1. Remove the tmp. repo: `cd .. && rm -rf yay`
    1. Idk (once): `yay -Y --gendb`
    1. (Note) Yay needs to be run as a normal user, not as root and not with sudo.
1. Enable early numlock (initramfs phase):
    1. Install package: `yay -S mkinitcpio-numlock`
    1. Add `numlock` to the `HOOKS` list in `/etc/mkinitcpio.conf` somewhere before `encrypt` (assuming the system is encrypted) (e.g. before `modconf`).
    1. Regenerate the initramfs: `mkinitcpio -P`
1. Tweak the PAM login faillock:
    1. (Note) It applies to password logins only, not SSH keys.
    1. (Note) To unlock a user, run `faillock --reset --user <user>`.
    1. Increase the failed login count threshold: In `/etc/security/faillock.conf`, set `deny = 5`.
1. Setup the local DNS resolver (systemd):
    1. (Note) The systemd-resolve config is `/etc/systemd/resolved.conf`.
    1. (Optional) Configure static upstream DNS servers (don't use any provided by DHCP/SLAAC): In the confug, set `DNS=1.1.1.1 2606:4700:4700::1111`.
    1. (Optional) Set the domain/search string: In the config, set `Domains=<domain>`.
    1. Enable DNSSEC validation (disable if it causes problems): In the config, set `DNSSEC=yes`.
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
        - It currently defaults to Debian-specific stuff, so remove those lines and uncomment the Arch-specific lines.
    1. Run it: `/etc/iptables/config.sh`
1. (Optional) Setup colored man pages:
    1. (Note) Most breaks on wide displays (e.g. UHD), so don't use it if that may be a problem.
    1. Install the most pager: `sudo pacman -S most`
    1. Set it as the default pager: In `.bashrc` and/or `.zshrc`, set `export PAGER=most`
1. Reboot to reload stuff and make sure nothing broke:
    1. `sudo reboot`

### Setup the Xorg Display Server

1. Install: `sudo pacman -S xorg-server xorg-xinit xorg-xrandr`

### Setup the LightDM or Ly Display Manager

Note: Install _either_ the LightDM (X11 GUI) or Ly (TTY TUI) display manager, not both. Ly is more minimalistic but doesn't work well with multiple monitors where you may want to specify the layout in Xorg.

#### LightDM (Alternative 1)

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

#### Ly (Alternative 2)

1. Setup Ly:
    1. (Note) The config file is `/etc/ly/config.ini`.
    1. Install: `yay -S ly`
    1. Enable: `sudo systemctl enable ly`
    1. Add fire background: In the config, set `animate = true` and `hide_borders = true`.
1. Enable numlock on by default in X11:
    1. Install: `sudo pacman -S numlockx`
    1. Configure: Create `/etc/X11/xinit/xinitrc.d/90-numlock.sh`, containing `#!/bin/sh` and `numlockx &`. Make it executable.

### Setup the i3 Window Manager Basics

1. (Note) Some notes about i3:
    1. Se [i3](../applications/#i3) for more personal notes about i3.
    1. Use `Mod+Shift+R` to reload the i3 config.
    1. Use `Mod+Shift+E` to exit i3.
    1. `exec_always` config statements will be run again during reload but `exec`statements will only run when starting i3.
1. Setup fonts:
    1. Install basic font with emoji support: `sudo pacman -S noto-fonts noto-fonts-emoji`
1. Install i3:
    1. Install: `sudo pacman -S i3-wm`
    1. (Note) Vital parts are missing in the i3 config, follow the remaining steps before attempting to use i3.
1. Fix the keyboard layout for X11:
    1. **TODO** (Note) You may need to have an X server running (e.g. i3 started). The server must be restarted before the new layout is used.
    1. Set: `sudo localectl set-x11-keymap <keymap>` (e.g. `no`)
1. Install temporary apps to get the remaining of the setup done:
    1. Install terminal emulator: `sudo pacman -S alacritty`
    1. Install web browser: `sudo pacman -S firefox`
1. Test the display server, display manager and window manager and create i3 config:
    1. (Re)start LightDM/Ly: `sudo systemctl restart lightdm` (or `ly`)
        - This will pull you directly into the Ly/LightDM TTY (ish), use `Ctrl+Alt+F1` if you need to go back to the previous TTY where you're still logged in to do stuff.
    1. Select the i3 WM and log in.
    1. If prompted, follow the basic i3 setup wizard:
        1. Generate a new config.
        1. `Win` as default modifier.

### Setup Post-Window Manager Stuff

1. (Laptop) Fix display brightness buttons:
    1. (Note) This method assumes you can change the brightness by writing a brightness value to `/sys/class/backlight/<something>/brightness` (initially only as root). Test that first.
    1. Add udev rules to allow changing the brightness through the `video` group:
        1. In `/etc/udev/rules.d/backlight.rules`, add the following:
            ```
            TODO
            ```
        1. Add your user to the group: `sudo usermod -aG video <user>`
        1. Reboot and try writing to the file without root.
    1. Add a script/program for changing the brightness:
        1. (Note) Try using the `xorg-xbacklight` first. If that works, just use that instead of this script. On my AMD-GPU laptop it didn't.
        1. Create a `.local/bin/backlight` script to control the backlight. See the snippet below for the content.
    1. Add i3 keybinds:
        1. In the i3 config, add:
            ```
            bindsym XF86MonBrightnessUp exec --no-startup-id $HOME/.local/bin/backlight +20%
            bindsym XF86MonBrightnessDown exec --no-startup-id $HOME/.local/bin/backlight -20%
            ```
1. (Laptop) Setup touchpad (Synaptics):
    1. Install driver: `sudo pacman -S libinput`
    1. Add touchpad config to Xorg: In `/etc/X11/xorg.conf.d/70-synaptics.conf`, add the config snippet from below. **TODO**
    1. **TODO** fix this
1. (Optional) Setup better console font:
    1. (Note) Using the MesloLGS font. See [this](https://github.com/romkatv/powerlevel10k#fonts) for more info.
    1. Create the TTF dir: `mkdir -p /usr/share/fonts/TTF`
    1. Download fonts: `for x in Regular Bold Italic Bold\ Italic; do sudo curl -sSfL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${x/ /%20}.ttf" -o "/usr/share/fonts/TTF/$x.ttf"; done`.
1. Setup the Polybar system bar:
    1. (Note) i3bar, the default i3 system bar, shows workspaces and tray icons. It can include extra info like IP addresses and resource usage using i3status or i3blocks. Polybar is a replacement for i3bar.
    1. Disable i3bar: Comment the whole `bar` section of the i3 config.
    1. Install polybar: `yay -S polybar`
    1. Create the config: `mkdir ~/.config/polybar && cp /usr/share/doc/polybar/examples/config.ini ~/.config/polybar/config`
    1. Customize config:
        - Rename the "example" bar to e.g. "main" (or create one from scratch).
        - Set the font: In the bar section, remove the existing `font-<n>` statements. Set `font0 = <family>:style=<s>:size=<n>;<vertical-offset>` (e.g. `font-0 = "MesloLGS NF:style=Regular:size=9;2"`). Use `fc-list | grep <font-name>` (the part after the first colon) to search for fonts. Make sure to use a Unicode-compatible font (which the default may not be.
        - For the bar, set `bottom = true` to move it to the bottom.
        - For the bar, comment `radius` to disable rounded corners.
        - For the bar, comment `border-size` to disable the padding/border around the bar.
        - For the date module, customize how time should appear. "Alt" variants are swapped to when the module is clicked.
        - For the network/"eth" module, use `%local_ip6%` for the IPv6 address (one of them). Maybe clone the module to have one for IPv4 and one for IPv6.
        - Update the panel modules in the `modules-{left,center,right}` variables.
    1. Create a startup script: See the section below to use the new "main" bar. Make it executable.
    1. Add to i3: In the i3 config, add `exec_always --no-startup-id $HOME/.config/polybar/launch.sh`.
1. Setup the Alacritty terminal emulator (or some other):
    1. Install: `sudo pacman -S alacritty`
    1. Create the config dir: `mkdir ~/.config/alacritty/`
    1. (Optional) Download the Dracula theme: `curl https://raw.githubusercontent.com/dracula/alacritty/master/dracula.yml -o ~/.config/alacritty/dracula.yml`
    1. Configure: Setup `~/.config/alacritty/alacritty.yml`, see the example config below.
    1. Setup i3: In the i3 config, replace the `bindsym $mod+Return ...` line with `bindsym $mod+Return exec alacritty`
    1. (Note) Press `Ctrl+Shift+Space` to enter vi mode, allowing you to e.g. move around (and scroll up) using arrow keys and select text using `V` or `Shift+V`. Press `Ctrl+Shift+Space` again to exit.
1. Setup the Rofi application launcher:
    1. Install: `sudo pacman -S rofi`
    1. Install rofimoji for emoji menu: `sudo pacman -S rofimoji xdotool`
    1. (Optional) Find a theme interactively (without selecting any): `rofi-theme-selector` (e.g. `glue_pro_blue`)
    1. Configure Rofi: Create `~/.config/rofi/config.rasi`, see the example below.
    1. Configure Rofimoji: Create `~/.config/rofimoji.rc` and set `action = copy` (copy to clipboard by default).
    1. Disable old i3 dmenu shortcut: In the i3 config, comment the `bindsym $mod+d` line.
    1. Setup i3 drun shortcut: In the i3 config, set `bindsym $mod+d exec rofi -show drun`.
    1. Setup i3 window shortcut: In the i3 config, set `bindsym $mod+shift+d exec rofi -show window`.
    1. Setup i3 emoji shortcut: In the i3 config, set `bindsym $mod+mod1+d exec rofi -modi "emoji:rofimoji" -show emoji`.
1. Setup background image:
    1. Download a desktop image.
    1. Install the FEH image viewer: `sudo pacman -S feh`
    1. Update i3: In the i3 config, set `exec_always --no-startup-id feh --bg-scale $HOME/Pictures/background.png` (example).
1. (Optional) Disable mouse hover window focus (you can still click windows to focus):
    1. In the i3 config, set `focus_follows_mouse no`.
1. (Optional) Setup i3 gaps:
    1. (Note) Requires i3-gaps instead of normal i3, which should work as a drop-in replacement with more options.
    1. Replace i3 with i3-gaps: `sudo pacman -S i3-gaps` (then replace i3-wm with i3-gaps)
    1. Disable window title bar (required): In the i3 config, add `for_window [class=".*"] border pixel 4` to only show the border and no title bar, or `0` to remove the border too.
    1. Add gaps around windows: In the i3 config, add `gaps inner 8`.
1. Install clipboard manager:
    1. `sudo pacman -S xsel`
    1. **TODO** Fix this. Basic copy-pase doesn't require xsel. Copying from a terminal and closing it erases the copy content, which is undesirable.
1. Setup desktop notifications:
    1. Install the `dunst` server and the `libnotify` support library: `sudo pacman -S dunst libnotify`
    1. (Optional) Modify the config:
        1. (Note) The global config is `/etc/dunst/dunstrc`.
        1. Create and open it: `mkdir -p ~/.config/dunst && vim ~/.config/dunst/dunstrc`
        1. For high-res displays, fix scaling (doesn't affect text size): In the `global` section, set e.g. `scale = 2`.
        1. Change the font and font size: In the `global` section, set e.g. `font = MesloLGS NF 8` (or 12 for high-res).
    1. Restart dunst (if any changes): `systemctl --user restart dunst`
    1. (Optional) Test it: `notify-send 'Hello world!' 'This is an example notification.' --icon=dialog-information`
1. Setup screen locking:
    1. Install the `i3lock-color` screen locker: `yay -S i3lock-color`
    1. Install the the `xss-lock` automatic locker: `sudo pacman -S xss-lock`
    1. Set a variable to run i3lock in i3: In the i3 config, before anything i3lock related, set e.g. `set $i3lock i3lock --nofork --ignore-empty-password --pass-media-keys`, to avoid repetition.
    1. (Optional) Specify an i3lock background image: To the above command, add e.g. `--image Pictures/background.png`.
    1. Set a locking keybind in i3: In the i3 config, add `bindsym $mod+l exec --no-startup-id $i3lock`. This may conflict with some `focus` keybinds you probably don't need, so just remove those (i3 will tell you about it if you don't remove them).
    1. Update i3 for automatic locking: In the i3 config, find the example `xss-lock` line and replace it with `exec --no-startup-id xss-lock --transfer-sleep-lock -- $i3lock`. (Test with `loginctl lock-session` after restarting or relogging.)
1. Setup autostarting of desktop applications:
    1. (Note) Desktop applications are applications with `<name>.desktop` files. These applications may be autostarted using a tool like `dex`, following the XDG Autostart spec.
    1. (Note) To enable autostarting for a desktop application, find/create a `.desktop` entry file for it in `/etc/xdg/autostart` (system) `~/.config/autostart` (user). A simple method is to find the entry in e.g. `/usr/share/applications/` (system) or `~/.local/share/applications/` (user), then symlink it into the appropriate autostart directory (e.g. `ln -s /usr/share/applications/discord.desktop ~/.config/autostart`).
    1. Install dex: `sudo pacman -S dex`
    1. Add this to your i3 config: `exec --no-startup-id dex --autostart --environment i3`
    1. (Optional) Test it: `dex --autostart --environment i3 &>/dev/null`

### Setup Xorg Multi-Display and Stuff

1. (Note) The Xorg configs are only read when the server is started, meaning you practically need to restart the system (or relog if using a non-X11 display manager) to apply new configuration.
1. (Note) Query current Xorg settings: `xset q`
1. (Optional) Try `xrandr` to get try display layouts and stuff:
    1. (Note) Changes made using the command line are not persistent.
    1. Show current config: `xrandr`
    1. (Note) The resolution with `+` is the oreferred and the one with `*` is the active one.
    1. Activate/update a display: `xrandr --output <display> [--primary] [--right-of <other-display>] [--rotate left] --auto` (auto selects the preferred resolution and frame rate)
    1. Deactivate a display: `xrandr --output <display> --off`
1. Setup persistent layout config:
    1. See the example Xorg displays config below.
        - For each connected monitor, create a separate section.
        - Run `xrandr` to get display IDs.
        - Make sure to have exactly one display with `Option "Primary" "true"`.
    1. Alternatively, create a script to set up displays using `xrandr` and call it from the i3 config.
1. Setup display power management signaling (DPMS):
    1. See the example Xorg DPMS config below.
        - For non-CRT displays, the standby, suspend and off modes typically mean the same thing.
        - DPMS is enabled by default in recent Xorg, but it can be explicitly enabled by setting `Option "DPMS" "true"` in a monitor section.

### Setup Audio

Note: We're using the PipeWire sound server, a modern, security-focused and compatible replacement for both PulseAudio and JACK.
See [PipeWire (Applications)](../applications/#pipewire) for more config info.

1. Install ALSA stuff:
    1. (Note) ALSA itself is already provided as built-in kernel modules and ALSA drivers will just work.
    1. Install ALSA utils and firmware: `sudo pacman -S alsa-utils alsa-firmware`
1. Install PipeWire (including WirePlumber and adapters):
    1. Install: `sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 wireplumber pavucontrol`
    1. Start the PulseAudio adapter (to avoid relogging): `systemctl --user start pipewire-pulse`
1. Configure inputs and outputs:
    1. Run `pavucontrol` to configure volumes, inputs, outputs and stuff.
1. (Optional) Test it:
    1. Try playing something from the browser or whatever. It should work.
1. (Optional) Install useful audio applications:
    1. Install the Helvum patchbay to patch nodes and endpoints (inputs and outputs for all audio devices): `sudo pacman -S helvum`
    1. See the [PipeWire page (Arch Wiki)](https://wiki.archlinux.org/title/PipeWire).
1. Setup media keys:
    1. (Note) Install e.g. Spotify (`aur/spotify`, official) to test with.
    1. Install the playerctl utility for easy control: `sudo pacman -S playerctl`
    1. Add the following to the i3 config: See the i3 media keys config snippet below.
1. Tweak audio volume keys:
    1. Install `pamixer` (like ALSA's `amixer` but for PulseAudio): `sudo pacman -S pamixer`
    1. Open the i3 config and find the `bindsym XF86AudioRaiseVolume` and similar lines.
    1. See the config i3 volume keys snippet below.
1. Setup a Spotify module for Polybar:
    1. Install: `yay -S polybar-spotify-git`
    1. In the Polybar config (`~/.config/polybar/config`), add a module `spotify` (see config snipper below) and add it to some bar module section.

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
1. Setup Blueman:
    1. (Note) Blueman is a Bluetooth manager with a practical tray icon.
    1. Install: `sudo pacman -S blueman`
    1. (Optional) Try to run it. It's the "Bluetooth Manager" entry in e.g. Rofi.
1. (Example) Connect a device using `bluetoothctl`:
    1. (Note) To avoid entering the interactive TUI and run single commands instead, use `bluetoothctl -- <cmd>`.
    1. Enter the TUI: `bluetoothctl`
    1. (Optional) List controllers: `list`
    1. (Optional) Select a controller: `select <mac>`
    1. Enable the controller: `power on`
    1. Enable scanning: `scan on`
    1. Wait for devices to appear in the terminal.
    1. List available devices: `devices`
    1. (Optional) Enable the pairing agent: `agent on`
    1. (Optional) Set the agent as default: `default-agent`
    1. Pair with device: `pair <mac>`
    1. Wait for pairing to complete.
    1. (Optional) Trust it (sometimes required): `trust <mac>`
    1. (Optional) Reconnect to device: `connect <mac>`
    1. Exit: `Ctrl+D`

### Setup Applications

1. Setup terminal emulator:
    1. Already done.
1. Setup the ZSH shell:
    1. See [Applications: ZSH](../applications/#zsh-linux) (includes font, theme and plugins).
1. Setup the VLC video and audio player:
    1. Install: `sudo pacman -S vlc`
1. Setup the Mirage image viewer:
    1. Install: `yay -S mirage`
1. Setup the GIMP image editor:
    1. Install: `sudo pacman -S gimp`
1. Setup the Thunar graphical file manager:
    1. Install: `sudo pacman -S thunar`
1. Setup the Ranger terminal file explorer:
    1. Install: `sudo pacman -S ranger`
1. Setup the VS Code text editor/IDE:
    1. (Alternative 1) Install the Arch-built: `sudo pacman -S code`
    1. (Alternative 2) Install the Microsoft binary distribution with tracking and Microsoft extensions: `yay -S visual-studio-code-bin`
1. Setup the LibreOffice office document suite:
    1. Install: `sudo pacman -S libreoffice-fresh`
1. Setup the Okular PDF reader:
    1. Install: `sudo pacman -S okular`
1. Setup the screenshot tool Maim (for keybinds and easy CLI usage):
    1. Install: `sudo pacman -S maim`
    1. Setup i3 keybinds: See the i3 config snippet below.
1. Setup the screenshot tool Flameshot (for GUI and on-screen editing):
    1. Install: `sudo pacman -S flameshot`
    1. (Usage) Start the tray icon: Run the "Fireshot" desktop application.
    1. (Usage) Directly open the capture GUI from the terminal: `fireshot gui`
1. Setup the 7-Zip CLI/GUI archiver:
    1. Install: `yay -S p7zip-gui`
    1. (Note) Don't use the `.7z` file format, it doesn't preserve owner info.
1. Setup network tools:
    1. Install: `sudo pacman -S nmap tcpdump wireshark-qt`

### Extra (Optional)

- Setup secure boot using your own keys.

### Notes and Snippets

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

[IPv6AcceptRA]
UseDNS=yes
UseDomains=yes
```

For WLAN interfaces, add `IgnoreCarrierLoss=5s` to the `Network` section.

#### iwd eduroam Config

File: `/var/lib/iwd/eduroam.8021x` (for SSID `eduroam`)

The following values from the [eduroam configuration assistant tool (CAT)](https://cat.eduroam.org/) are required (from Arch iwd wiki page):

| iwd | eduroam | Comment |
| - | - |
| File name | `Config.ssids` (one) | Typically `eduroam`, with `8021x` file ending. |
| `EAP-Method` | `Config.eap_outer` | |
| `EAP-Identity` | `Config.anonymous_identity` | `anonymous@Config.user_realm` if missing. |
| `EAP-PEAP-CACert` | `Config.CA` | Place the cert data in a file and specify the path. |
| `EAP-PEAP-ServerDomainMask` | `Config.servers` (one) | Without `DNS:` prefix. |
| `EAP-PEAP-Phase2-Method` | `Config.eap_inner` | |
| `EAP-PEAP-Phase2-Identity` | `<username>@Config.user_realm`
| `EAP-PEAP-Phase2-Password` | `<password>` | |

Place the CA certificate in `/var/lib/iwd/eduroam.crt`.

NTNU template:

```
[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@ntnu.no
EAP-PEAP-CACert=/var/lib/iwd/eduroam.crt
EAP-PEAP-ServerDomainMask=radius.ntnu.no
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=<username>@ntnu.no
EAP-PEAP-Phase2-Password=<password>

[Settings]
AutoConnect=true
```

#### Polybar Launch Script

File: `~/.config/polybar/launch.sh`

```bash
#!/bin/bash

killall -q polybar

#polybar main &>>/tmp/polybar.log &
polybar main &
```

#### Polybar Spotify Module

File: `~/.config/polybar/config`

```
[module/spotify]
type = custom/script
interval = 1
format = <label>
#exec = python /usr/share/polybar/scripts/spotify_status.py -f '[{artist}] {song}' -t 50 -q
exec = python /usr/share/polybar/scripts/spotify_status.py -f '{song}' -t 25 -q
format-underline = #1db954
```

#### Alacritty Config

File: `~/.config/alacritty/alacritty.yml`

```yaml
font:
  # normal:
  #   family: MesloLGS NF
  #   style: Regular
  size: 9

env:
  TERM: xterm-256color

import:
  # Theme
  - ~/.config/alacritty/dracula.yml
```

#### Rofi Config

file: `~/.config/rofi/config.rasi`

```
configuration {
    font: "MesloLGS NF 10";
}
@theme "glue_pro_blue"
```

#### Xorg Monitors

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

#### Xorg DPMS

File: `/etc/X11/xorg.conf.d/20-dpms.conf`

```
Section "ServerFlags"
    # In minutes, 0 to disable
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "30"
    Option "BlankTime" "0"
EndSection
```

Alternatively, to disable DPMS completely:

```
Section "Extensions"
    Option "DPMS" "Disable"
EndSection
```

#### i3 Media Keys

File: `~/.config/i3/config`

Requires `playerctl`.

```
# Media keys
bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause
bindsym XF86AudioPause exec --no-startup-id playerctl play-pause
bindsym XF86AudioStop exec --no-startup-id playerctl stop
bindsym XF86AudioPrev exec --no-startup-id playerctl previous
bindsym XF86AudioNext exec --no-startup-id playerctl next
```

#### i3 Volume Keys

File: `~/.config/i3/config`

Requires `pamixer`.

```
# Volume keys
bindsym XF86AudioRaiseVolume exec --no-startup-id pamixer -i 5
bindsym XF86AudioLowerVolume exec --no-startup-id pamixer -d 5
bindsym XF86AudioMute exec --no-startup-id pamixer -t
bindsym XF86AudioMicMute exec --no-startup-id pamixer --default-source -t
```

#### i3 Maim Screenshot Keys

File: `~/.config/i3/config`

Requires `maim`.

```
# Capture screen (active window and full)
bindsym $mod+Print exec maim -i $(xdotool getactivewindow) $HOME/Downloads/Screenshot_$(date -Iseconds).png
bindsym $mod+Shift+Print exec maim $HOME/Downloads/Screenshot_$(date -Iseconds).png
```

{% include footer.md %}
