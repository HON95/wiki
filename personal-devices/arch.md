---
title: Arch Linux
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

Components:
- LUKS encrypted root
- Either the i3 window manager (Xorg) or the Hyprland compositor (Wayland)
- PipeWire multimedia framework
- iwd wireless daemon
- Some default applications

## TODO

- i3:
    - The "i3 User's Guide"
    - Plymouth
    - picom compositor
- Hyprland:
    - Wayland
    - Xwayland, xorg-xlsclients (xlsclients -l)
    - Touchpad
    - Tocuhscreen
    - Display brightness
    - Keyboard brightness
    - Wofi
    - Polybar equivalent
    - NVIDIA stuff
    - UWSM?
    - ... see i3 steps

## Resources

### Arch

- [Installation guide (Arch Wiki)](https://wiki.archlinux.org/title/Installation_guide)
- [General recommendations (Arch Wiki)](https://wiki.archlinux.org/title/General_recommendations)
- [Frequently asked questions (Arch Wiki)](https://wiki.archlinux.org/title/Frequently_asked_questions)
- [List of applications (Arch Wiki)](https://wiki.archlinux.org/title/List_of_applications)
- [dm-crypt/Encrypting an entire system (Arch Wiki)](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)


### i3

- [i3 User's Guide](https://i3wm.org/docs/userguide.html)

### Hyprland

- [Hyprland Wiki](https://wiki.hypr.land/Useful-Utilities/Status-Bars/)
- [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland)
- [Useful add ons for sway](https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway)

## Setup Basics

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
    1. Wired with DHCP/SLAAC:
        1. It should already be working.
    1. WLAN (WPA 2/3 with PSK) and DHCP/SLAAC:
        1. Setup config for SSID: `wpa_passphrase "<SSID>" "<PSK>" > /etc/wpa_supplicant/wpa_supplicant.conf`
        1. Connect: `wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlan0`
    1. (Optional) Check your IP addresses with `ip a` and try a `ping -4 google.com` (and -6).
1. Setup live-OS time:
    1. Enable NTP: `timedatectl set-ntp true`
    1. (Optional) Check the "synchronized" line from `timedatectl`.
1. Make sure your live-OS is updated: `pacman -Sy && pacman -S archlinux-keyring`
1. Partition the main disk (for LUKS encryption):
    1. Find the main disk: `lsblk`
    1. Overwrite the full disk to get rid of all traces of the previous partitioning table and OS: `dd if=/dev/zero of=/dev/<disk> bs=1M conv=fsync status=progress`
    1. (Note) Create these partitions by repeatedly running the new partition steps below:
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
    - Mount ESP: `mkdir -p /mnt/boot/efi && mount /dev/<partition-1> /mnt/boot/efi`
1. Install packages to the new root:
    - Base command and packages: `pacstrap /mnt <packages>`
    - Base packages: `base linux linux-firmware intel-ucode amd-ucode archlinux-keyring polkit sudo bash-completion man-db man-pages xdg-utils xdg-user-dirs vim tar zip unzip curl whois`
    - Extra packages: `smartmontools lm_sensors hwloc zsh htop base-devel git jq rsync openssh tmux screen usbutils tcpdump nmap inetutils bind`
    - Wireless networking packages: `iwd` (or `wpa_supplicant`)
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
    1. Create the initial ramdisk (for each config change): `mkinitcpio -P`
1. Setup GRUB:
    1. Install bootloader: `pacman -S grub efibootmgr`
    1. Enable encrypted disk support: In `/etc/default/grub`, set `GRUB_ENABLE_CRYPTODISK=y`.
    1. Find the `UUID` of the encrypted root _physical_ partition: `blkid`
    1. Add kernel parameters for the encrypted root (e.g. `/dev/sda2`): In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptdevice=UUID=<device-UUID>:crypt_root root=/dev/mapper/crypt_root`.
    1. Install GRUB to ESP (one time): `grub-install --target=x86_64-efi --efi-directory=/boot/efi`
    1. Generate GRUB config (for each config change): `grub-mkconfig -o /boot/grub/grub.cfg`
1. Exit the chroot and reboot:
    1. `exit`
    1. `reboot`
1. Remove the installation media.
1. Wait for the GRUB screen or decryption prompt.

### Setup Post-Install Stuff

1. Boot into the newly installed system:
    1. (Optional) Avoid broken display drivers (typically needed for NVIDIA cards): In the GRUB bootloader menu, press `E` on the main entry and add `nomodeset` at the end of the `linux` line. Press `Ctrl+X` to continue. After proper display drivers are installed, this is no longer required.
1. (Optional) Disable the beeper:
    1. Unload the module: `rmmod pcspkr`
    1. Blacklist the module: `echo blacklist pcspkr > /etc/modprobe.d/nobeep.conf`
1. Enable SSD periodic TRIM:
    1. Enable timer: `systemctl enable fstrim.timer`
1. Setup swap file:
    1. (Note) You should have enough memory installed to never need swapping, but it's a nice backup to prevent the system from potentially crashing if anything bugs out and eats up too much memory.
    1. Show if swap is already enabled: `swapon --show`
    1. Allocate the swap file: `fallocate -l <size> /swapfile` (e.g. 16G)
    1. Fix the permissions: `chmod 600 /swapfile`
    1. Setup the swap file: `mkswap /swapfile`
    1. Activate the swap file: `swapon /swapfile`
        - Check: `swapon --show`
    1. Add it to `/etc/fstab` using this line: `/swapfile swap swap defaults 0 0`
        - Check: `mount -a`
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
1. (Optional) Setup wireless networking (excluding tray icon and GUI):
    - Note: The remainder of the instructions assume you picked iwd here.
    - Preparations:
        1. Make sure a driver is loaded for the WLAN device:
            - `ip a` should show a `wlp*` interface for the device.
            - `lspci -k` (for PCIe) or `lsusb -v` (for USB) should show a loaded module.
        1. Make sure the radio device isn't blocked: `rfkill` (should show "unblocked")
    - Using iwd (recommended):
        1. Install: `pacman -S iwd`
        1. Configure: See example config below for config `/etc/iwd/main.conf`.
        1. (Note) Add your user to the network group to allow managing IWD: `sudo usermod -aG network <user>`
        1. Enable: `systemctl enable --now iwd.service`
            - If this fails, you may need to reboot.
        1. Setup the network config:
            1. Create a systemd-network config similar to the one for the wired interface, but add `IgnoreCarrierLoss=5s` to the `Network` section to allow for roaming without disconnects.
            1. Restart systemd-networkd.
        1. (Example) Connect to WPA2/WPA3 personal network (using `iwctl`):
            1. (Note) `iwctl` has extenside tab-complete support.
            1. Enter `iwctl`: `iwctl`
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
            1. Create the private credentials dir: `mkdir /var/lib/iwd/ && chown root:root /var/lib/iwd/ && chmod 700 /var/lib/iwd/`
            1. Create the config file `/var/lib/iwd/eduroam.8021x` (name-sensitive), containing the template snippet below with values found in the eduroam script.
        1. (Extra) Troubleshooting (as root):
            1. Run it in debug mode (stop the service first): `IWD_TLS_DEBUG=TRUE IWD_WSC_DEBUG_KEYS=1 /usr/lib/iwd/iwd`
            1. Check the debug certificate file (if the log says it stored it): `cat /tmp/iwd-tls-debug-server-cert.pem`
            1. Force it to try to connect (if nothing happens): `iwctl station wlan0 connect <SSID>`
    - Using wpa_supplicant (not recommended):
        1. Install: `sudo pacman -S wpa_supplicant`
        1. Configure:
            - See example config below for config `/etc/wpa_supplicant/wpa_supplicant.conf`.
            - Fix the permissions (it contains secrets): `sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf`
            - Create a place to put certs and protect it: `sudo mkdir -p /var/lib/wpa_supplicant/certs; sudo chmod 700 /var/lib/wpa_supplicant`
            - Using `update_config` allows it to update its config, which may change file permissions to something "readable by everyone", according to the Arch wiki. If you don't need this, set it to 0.
            - Set `country` to your country code.
        1. (Optional) Test the daemon and config:
            1. Start it in debug mode: `sudo wpa_supplicant -B -i <interface> -c /etc/wpa_supplicant/wpa_supplicant.conf -d`
            1. See if you successfully connect by running and watching `sudo wpa_cli`.
            1. (Optional) Check that you can see all networks:
                1. `sudo wpa_cli scan`
                1. `sudo wpa_cli scan_results`
            1. Kill it: `sudo pkill wpa_supplicant`
        1. **TODO**:
            - Update the main service to use the correct config and enable it.
            - Configure for specific interfaces, e.g. for differente wired and wireless config? https://wiki.archlinux.org/title/wpa_supplicant#At_boot_(systemd)
1. Setup DNS server(s):
    1. `echo "nameserver 1.1.1.1" >> /etc/resolv.conf` (Cloudflare)
    1. `echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf` (Cloudflare)
1. Setup Pacman:
    1. Enable color: In `/etc/pacman.conf`, uncomment `Color`.
    1. Enable the multilib repo (for 32-bit apps): In `/etc/pacman.conf`, uncomment the `[multilib]` section.
    1. Update/upgrade: `pacman -Syu`
1. Install display driver and utils:
    - For NVIDIA Maxwell and newer GPUs: `pacman -S nvidia nvidia-utils nvidia-settings`.
        - (Optional) For CUDA: `pacman -S cuda`
    - For newer AMD GPUs: `pacman -S mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver`
    - For newer Intel integrated GPUs: `pacman -S mesa lib32-mesa vulkan-intel intel-media-driver`
1. Avoid having to enter the encryption password twice during boot:
    1. (Note) To avoid entering the password once for GRUB and then for the initramfs, we can create a keyfile and embed it into the initramfs. If the keyfile fails, it will fall back to asking for a password again.
    1. Secure the boot dir (to protect the embedded key in the initramfs): `chmod 700 /boot`
    1. Generate keyfile:
        1. `(umask 0077; mkdir -p /var/lib/keys/luks)`
        1. `dd if=/dev/random of=/var/lib/keys/luks/crypt_root bs=2048 count=1 iflag=fullblock`
    1. Add key to LUKS: `cryptsetup luksAddKey /dev/<partition> /var/lib/keys/luks/crypt_root`
    1. Add key to initramfs: In `/etc/mkinitcpio.conf`, set `FILES=(/var/lib/keys/luks/crypt_root)`.
    1. Recreate initramfs: `mkinitcpio -P`
    1. Add extra kernel parameters for the keyfile: In `/etc/default/grub`, in the `GRUB_CMDLINE_LINUX` variable, add `cryptkey=rootfs:/var/lib/keys/luks/crypt_root`.
    1. Update GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`
    1. (Note) When rebooting, if it doesn't work it will/should/might fall back to the extra password prompt.
1. (Optional) Reboot, check that booting works.
1. Setup sudo:
    1. (Note) Both the `wheel` and `sudo` groups are commonly used for giving sudo access, but I personally prefer `sudo` since `wheel` _may_ also be used by polkit rules, su (`pam_wheel`), etc.
    1. Install: `pacman -S sudo`
    1. Add the sudo group: `groupadd -r sudo`
    1. Enter the config: `EDITOR=vim visudo`
    1. Add line to allow sudo group without password: `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`
1. Add a personal admin user:
    1. Create the user and add it to relevant groups (remove missing groups): `useradd -m -G sudo,adm,sys,uucp,proc,systemd-journal,video,network <user>` (remove any missing groups)
    1. Set its password: `passwd <user>`
    1. (Optional) Relog to test the user.
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
    1. Regenerate the initramfs: `sudo mkinitcpio -P`
1. Tweak the PAM login faillock:
    1. (Note) It applies to password logins only, not SSH keys.
    1. (Note) To unlock a user, run `faillock --reset --user <user>`.
    1. Increase the failed login count threshold: In `/etc/security/faillock.conf`, set `deny = 5`.
1. Setup the local DNS resolver (systemd):
    1. (Note) The systemd-resolve config is `/etc/systemd/resolved.conf`.
    1. (Optional) Configure static upstream DNS servers (don't use any provided by DHCP/SLAAC): In the confug, set `DNS=1.1.1.1 2606:4700:4700::1111`.
    1. (Optional) Set the domain/search string: In the config, set `Domains=<domains>`.
    1. Disable DNSSEC validation (enabling it may cause NTP problems): In the config, set `DNSSEC=no`.
    1. Enable and start it: `sudo systemctl enable --now systemd-resolved`
    1. Setup `resolv.conf`: `sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
    1. Check: `resolvectl query vg.no` and `curl google.com`
1. Setup the NTP client (systemd):
    1. (Note) The default server pool is fine.
    1. Enable: `sudo timedatectl set-ntp true`
    1. Check: `timedatectl` (see the "synchronized" field)
1. Setup firewall (IPTables):
    1. Install IPTables: `sudo pacman -S iptables`
    1. Enable the IPTables services: `sudo systemctl enable --now iptables.service ip6tables.service`
    1. Download my IPTables script (or do it yourself): `sudo curl https://raw.githubusercontent.com/HON95/scripts/master/iptables/iptables.sh -o /etc/iptables/config.sh`
    1. Make it executable: `sudo chmod +x /etc/iptables/config.sh`
    1. Modify it.
        - It currently defaults to Debian-specific stuff, so remove those lines and uncomment the Arch-specific lines.
    1. Run it: `sudo /etc/iptables/config.sh`

## Setup Desktop Environment Basics

1. Setup the Ly Display Manager (common for Xorg/Wayland):
    1. Install: `yay -S ly`
    1. Enable: `sudo systemctl enable ly`
    1. In `/etc/ly/config.ini`, set `animation = CMatrix`.
1. Setup fonts:
    1. Install basic font with emoji support: `sudo pacman -S noto-fonts noto-fonts-emoji`

## Setup i3 (Alternative)

If not using Hyprland (Wayland).

1. Setup Xorg Display Server:
    1. Install: `sudo pacman -S xorg-server xorg-xinit xorg-xrandr xorg-xinput`
1. (Note) Some notes about i3:
    - Se [i3](/personal-devices/applications/#i3) for more personal notes about i3.
    - Use `Mod+Shift+R` to reload the i3 config.
    - Use `Mod+Shift+E` to exit i3.
    - Use `Mod+Enter` to open a terminal.
    - Use the terminal to open the web browser, since launchers aren't set up yet.
    - `exec_always` config statements will be run again during reload but `exec`statements will only run when starting i3.
1. Install i3:
    1. Install: `sudo pacman -S i3-wm`
    1. (Note) Vital parts are missing in the i3 config, follow the remaining steps before attempting to use i3.
1. Fix the keyboard layout for X11:
    1. Set: `sudo localectl set-x11-keymap <keymap>` (e.g. `no`)
1. Install temporary apps to get the remaining of the setup done:
    1. Install terminal emulator and web browser: `sudo pacman -S alacritty firefox`
        - If asked, select `pipewire-jack` and `wireplumber`.
1. Reboot.
1. Arrive at window manager (Ly).
    - Use `Ctrl+Alt+F1` if you need to enter a terminal TTY (TTY1). Ly/LightDM uses one of the first TTYs, the rest are terminal TTYs.
1. Select the i3 WM and log in.
1. If prompted, follow the basic i3 setup wizard:
    1. Generate a new config.
    1. `Win` as default modifier.
1. Press `Mod+Enter` to open a terminal.
1. Enable numlock on by default in X11:
    1. Install: `sudo pacman -S numlockx`
    1. Configure: Create `/etc/X11/xinit/xinitrc.d/90-numlock.sh`, containing `#!/bin/sh` and `numlockx &`. Make it executable.
1. Setup displays:
    1. (Note) Using an xrandr script instead of Xorg config due to problems with 144Hz displays and reduced flexibility.
    1. (Note) DPMS (Display Power Management Signaling) is automatically enabled for all displays.
    1. Show displays: `xrandr`
    1. (Example) Temporarily configure displays:
        1. Main display example: `xrandr --output eDP --auto`
        1. Rotated right display example: `xrandr --output HDMI-A-0 --right-of eDP --rotate left --auto`
        1. Set full RGB range:
            - Intel GPUs: `xrandr --output DP-1 --set "Broadcast RGB" "Full"`
            - AMD GPUs: `xrandr --output DP-1 --set "output_csc" "bypass"`
    1. Create an executable script `$HOME/.config/xrandr.sh` containing the configure commands for all displays. Call it from the i3 config.
1. (Touchpad) Setup touchpad (Synaptics):
    1. Install driver: `sudo pacman -S libinput`
    1. Add touchpad config to Xorg: In `/etc/X11/xorg.conf.d/70-synaptics.conf`, add the config snippet from below. **TODO**
    1. **TODO** fix this
1. (Touchscreen) Setup touchscreen:
    1. (Note) The touchscreen should be mostly plug-and-play, but the mapping might be wrong when using multiple displays.
    1. Show input devices (should list the touchscreen): `xinput --list`
    1. (Example) Map the touchscreen to the main display: `xinput --map-to-output 'x' eDP` (for touchscreen `x`)
1. (Laptop) Fix display brightness buttons:
    1. (Note) This is an alternative to using the `xorg-xbacklight` package, which didn't work for me neither on AMD nor Intel laptops.
    1. Try manually changing the backlight:
        1. Find the backlight controller in `/sys/class/backlight`.
        1. Find the maximum brightness in `/sys/class/backlight/<x>/max_brightnes`.
        1. Set a new brightness: `echo 10 | sudo tee /sys/class/backlight/<x>/brightness`
        1. Verify that it actually changed. If not, this won't work.
    1. Add udev rules to allow changing the brightness through the `video` group:
        1. In `/etc/udev/rules.d/backlight.rules`, add the following (template, using `<x>` from above):
            ```
            ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="<x>", RUN+="/bin/chgrp video /sys/class/backlight/<x>/brightness"
            ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="<x>", RUN+="/bin/chmod g+w /sys/class/backlight/<x>/brightness"
            ```
        1. (Optional) Reboot and try writing to the file without root.
    1. Add a script/program for changing the brightness:
        1. Create a `/usr/local/bin/display-backlight` script to control the backlight. [Example script.](https://github.com/HON95/configs/blob/master/linux/display-backlight.sh)
    1. Add i3 keybinds:
        1. In the i3 config, add:
            ```
            bindsym XF86MonBrightnessUp exec --no-startup-id /usr/local/bin/display-backlight +1
            bindsym XF86MonBrightnessDown exec --no-startup-id /usr/local/bin/display-backlight -1
            ```
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
1. Setup screen locking:
    1. Install the `i3lock-color` screen locker: `yay -S i3lock-color`
    1. Install the the `xss-lock` automatic locker: `sudo pacman -S xss-lock`
    1. Set a variable to run i3lock in i3: In the i3 config, before anything i3lock related, set e.g. `set $i3lock i3lock --nofork --ignore-empty-password --pass-media-keys`, to avoid repetition.
    1. (Optional) Specify an i3lock background image: To the above command, add e.g. `--image Pictures/background.png`.
    1. Set a locking keybind in i3: In the i3 config, add `bindsym $mod+l exec --no-startup-id $i3lock`. This may conflict with some `focus` keybinds you probably don't need, so just remove those (i3 will tell you about it if you don't remove them).
    1. Update i3 for automatic locking: In the i3 config, find the example `xss-lock` line and replace it with `exec --no-startup-id xss-lock --transfer-sleep-lock -- $i3lock`. (Test with `loginctl lock-session` after restarting or relogging.)
1. Setup background image:
    1. Download a desktop image.
    1. Install the FEH image viewer: `sudo pacman -S feh`
    1. Update i3: In the i3 config, set `exec_always --no-startup-id feh --bg-scale $HOME/Pictures/background.png` (example).

## Setup Hyprland (Alternative)

If not using i3 (X11).

1. Install:
    1. Basics: `sudo pacman -S hyprland kitty brightnessctl xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent qt5-wayland qt6-wayland`
1. Fix NVIDIA stuff:
    1. **TODO**: See the Hyprland wiki page.
1. Start Hyprland:
    1. Reboot the PC.
    1. (Note) If you need a working terminal, just switch to another TTY.
    1. In the Ly login select "Hyprland" (not "uwsasdasd? managed").
    1. Open the terminal: `Super+Q`
    1. (Note) The keyboard layout and stuff is probably all wrong at this point.
1. Update config basics:
    1. Open the config: `vim ~/.config/hypr/hyprland.conf`
    1. (Note) Check the wiki for options: [Variables](https://wiki.hypr.land/Configuring/Variables/)
    1. (Note) Hyprland updates immediately when the file is saved.
    1. Set the keyboard layout: `input { kb_layout = no }` (Norway)
    1. Set repeat rate/delay: `input { repeat_rate = 50 // repeat_delay = 500 }`
    1. Set monitor mode: `monitor = eDP-1,1920x1080@60,0x0,1` (example for 1080p60, position 0x0, scaling 1x)
        - Check current and available modes: `hyprctl monitors`
        - To use auto mode instead: `monitor = ,preferred,auto,auto`
    1. Fix other stuff: **TODO**: Example config.
1. Fix XWayland and X11 apps:
    1. Disable X11 scaling: In `hyprland.conf`, put `xwayland { force_zero_scaling = true }`.
    1. Make Electron apps and VSCode use Wayland: Create `~/.config/{electron,code}-flags.conf` and add `--ozone-platform=wayland`.
1. Setup application launcher (Rofi):
    1. Install: `sudo pacman -S rofi rofimoji xdotool`
    1. (Optional) Find a theme interactively (without selecting any): `rofi-theme-selector` (e.g. `glue_pro_blue`)
    1. Configure Rofi: Create `~/.config/rofi/config.rasi`, see the example below.
    1. Configure Rofimoji: Create `~/.config/rofimoji.rc` and set `action = copy` (copy to clipboard by default).
    1. Setup Hyprland drun shortcut: In the i3 config, set `bind = SUPER, D, exec, rofi -show drun`.
    1. Setup Hyprland window shortcut: In the i3 config, set `bind = SUPER SHIFT, D, exec, rofi -show window`.
    1. Setup Hyprland emoji shortcut: In the i3 config, set `bind = SUPER ALT, D, exec, rofi -modi "emoji:rofimoji" -show emoji`.
1. Setup status bar (Waybar):
    1. Install: `sudo pacman -S waybar`
    1. Add config files: `mkdir ~/.config/waybar/ ; cp /etc/xdg/waybar/* ~/.config/waybar/`
    1. Customize it. E.g. replace `sway/workspaces` with `hyprland/workspaces`.
    1. Make active workspace marked: Replace `#workspaces button.focused` with `#workspaces button.active` in `~/.config/waybar/style.css`.
    1. Autostart: Add `exec-once = waybar` to the Hyprland-config.
1. Setup screen locker (hyprlock):
    1. Install: `sudo pacman -S hyprlock`
    1. Add default config: `curl https://raw.githubusercontent.com/hyprwm/hyprlock/refs/heads/main/assets/example.conf -o ~/.config/hypr/hyprlock.conf`
    1. Add Hyprland keybinds:
        - Lock manually: `bind = SUPER, L, exec, hyprlock`
        - Lock on lid close: `bindl = , switch:on:Lid Switch, exec, hyprlock --immediate`

**TODO**:

- Start hyprpolkitagent from Hyprland? https://wiki.hypr.land/Hypr-Ecosystem/hyprpolkitagent/

## Setup Extras

### General

1. (Optional) Setup better console font:
    1. (Note) Using the MesloLGS font. See [this](https://github.com/romkatv/powerlevel10k#fonts) for more info.
    1. Create the TTF dir: `sudo mkdir -p /usr/share/fonts/TTF`
    1. Download fonts: `for x in Regular Bold Italic Bold\ Italic; do sudo curl -sSfL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${x/ /%20}.ttf" -o "/usr/share/fonts/TTF/$x.ttf"; done`
1. Setup the Alacritty terminal emulator (or some other):
    1. Install: `sudo pacman -S alacritty`
    1. Create the config dir: `mkdir ~/.config/alacritty/`
    1. (Optional) Download the Dracula theme: `curl https://raw.githubusercontent.com/dracula/alacritty/master/dracula.toml -o ~/.config/alacritty/dracula.toml`
    1. Configure: Setup `~/.config/alacritty/alacritty.toml`, see the example config [here](https://github.com/HON95/configs/blob/master/alacritty/alacritty.toml).
    1. (i3) Setup terminal keybind: In the i3 config, replace the `bindsym $mod+Return ...` line with `bindsym $mod+Return exec alacritty`
    1. (Note) Press `Ctrl+Shift+Space` to enter vi mode, allowing you to e.g. move around (and scroll up) using arrow keys and select text using `V` or `Shift+V`. Press `Ctrl+Shift+Space` again to exit.
1. (Optional) Setup iwd wireless networking tray icon and GUI:
    1. **TODO**: i3/Xorg only? Try one of the other GUIs?
    1. (Note) Make sure your user is a member of the `network` group to allow controling iwd.
    1. Install (with snixembed compat library for Polybar): `yay -S iwgtk snixembed-git`
    1. Start snixembed in i3 config: `exec --no-startup-id snixembed`
    1. (Optional) Remove the XDG autostart file: `rm /etc/xdg/autostart/iwgtk-indicator.desktop`
    1. (Optional) Start tray icon in i3 config instead: `exec --no-startup-id iwgtk -i`
    1. (Example) Test: `iwgtk` (GUI) or `iwgtk -i` (tray icon)
        - Might fail until relog/reboot.
1. Setup desktop notifications (dunst):
    1. Install: `sudo pacman -S dunst libnotify`
    1. (Optional) Modify the config:
        1. (Note) The global config is `/etc/dunst/dunstrc`.
        1. Create local config: `mkdir -p ~/.config/dunst && vim ~/.config/dunst/dunstrc`
        1. See the example config below.
    1. Restart dunst (if any changes): `systemctl --user restart dunst`
    1. (Optional) Test it: `notify-send 'Hello world!' 'This is an example notification.' --icon=dialog-information`
1. Setup autostarting of desktop applications:
    1. **TODO**: Wayland?
    1. (Note) Desktop applications are applications with `<name>.desktop` files. These applications may be autostarted using a tool like `dex`, following the XDG Autostart spec.
    1. (Note) To enable autostarting for a desktop application, find/create a `.desktop` entry file for it in `/etc/xdg/autostart` (system) or `~/.config/autostart` (user). A simple method is to find the entry in e.g. `/usr/share/applications/` (system) or `~/.local/share/applications/` (user), then symlink it into the appropriate autostart directory (e.g. `ln -s /usr/share/applications/discord.desktop ~/.config/autostart/`).
    1. Install dex: `sudo pacman -S dex`
    1. Add this to your i3 config: `exec --no-startup-id dex --autostart --environment i3`
    1. (Optional) Test it: `dex --autostart --environment i3 &>/dev/null`

### Setup Audio

Note: We're using the PipeWire sound server, a modern, security-focused and compatible replacement for both PulseAudio and JACK.
See [PipeWire (Applications)](/personal-devices/applications/#pipewire) for more config info.

1. Install ALSA stuff:
    1. (Note) ALSA itself is already provided as built-in kernel modules and ALSA drivers will just work.
    1. Install ALSA utils and firmware: `sudo pacman -S alsa-utils alsa-firmware`
1. Install PipeWire (including WirePlumber and adapters):
    1. Install: `sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 pipewire-x11-bell wireplumber pavucontrol`
    1. Start the PulseAudio adapter (to avoid relogging): `systemctl --user start pipewire-pulse`
1. Configure inputs and outputs:
    1. Run `pavucontrol` to configure volumes, inputs, outputs and stuff.
1. (Optional) Test it:
    1. Try playing something from the browser or whatever. It should work.
1. (Optional) Install useful audio applications:
    1. Install the Helvum patchbay to patch nodes and endpoints (inputs and outputs for all audio devices): `sudo pacman -S helvum`
    1. See the [PipeWire page (Arch Wiki)](https://wiki.archlinux.org/title/PipeWire).
1. Setup media keys: (**TODO**: Wayland)
    1. (Note) Install e.g. Spotify (`aur/spotify`, official) to test with.
    1. Install the playerctl utility for easy control: `sudo pacman -S playerctl`
    1. Add the following to the i3 config: See the i3 media keys config snippet below.
1. Tweak audio volume keys: (**TODO**: Wayland)
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

1. Setup a BASH command completion dir (also used by ZSH for CLI apps that don't support ZSH):
    1. Create dir `/etc/bash_completion.d` (might already exist).
    1. Setup `/etc/profile.d/completion.sh`, see the example below.
1. (Optional) Setup colored man pages:
    1. (Note) Most breaks on wide displays (e.g. UHD), so don't use it if that may be a problem.
    1. Install the most pager: `sudo pacman -S most`
    1. Set it as the default pager: In `.bashrc` and/or `.zshrc`, set `export PAGER=most`
1. Setup terminal emulator:
    1. Already done.
1. Setup the ZSH shell:
    1. See [Applications: ZSH](/personal-devices/applications/#zsh-linux) (includes font, theme and plugins).
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
1. Setup the screenshot tool Maim (for keybinds and easy CLI usage): (**TODO**: Wayland)
    1. Install: `sudo pacman -S maim`
    1. Setup i3 keybinds: See the i3 config snippet below.
1. (i3) Setup Flameshot screenshot/snippet utility:
    1. Install: `sudo pacman -S flameshot`
    1. (Usage) Start the tray icon: Run the "Fireshot" desktop application.
    1. (Usage) Directly open the capture GUI from the terminal: `fireshot gui`
1. (Hyprland) Setup hyprshot screenshot/snippet utility:
    1. Install: `sudo pacman -S hyprshot`
    1. Add Hyprland keybinds:
        - Screenshot a window: `bind = SUPER, PRINT, exec, hyprshot -m window --clipboard-only`
        - Screenshot a monitor: `bind = , PRINT, exec, hyprshot -m output --clipboard-only`
        - Screenshot a region: `bind = SUPER SHIFT, S, exec, hyprshot -m region --clipboard-only`
1. Setup the 7-Zip CLI/GUI archiver:
    1. Install: `yay -S p7zip-gui`
    1. (Note) Don't use the `.7z` file format, it doesn't preserve owner info.
1. Setup Remmina with RDP:
    1. Install: `sudo pacman -S remmina freerdp`
1. Setup network tools:
    1. Install: `sudo pacman -S nmap tcpdump wireshark-qt`
1. Set default applications (after installation):
    1. Web browser: `xdg-settings set default-web-browser firefox.desktop`

## Config Snippets

### systemd-networkd Network Config

File: `/etc/systemd/network/en.network` (example)

This example sets up any interface starting with `en` (i.e. wired Ethernet interfaces) to use DHCPv4 and SLAAC/DHCPv6. The `DHCP` and `IPv6AcceptRA` sections are optional, the default values are typically fine. Use `RouteMetric=2048` for WLAN interfaces to prefer LAN when both are connected. For WLAN interfaces, add `IgnoreCarrierLoss=5s` to the `Network` section to prevent it from going down during short connection issues. Add `LLDP=yes` to capture LLDP info (but not emit it), if you're into that. Use `Anonymize` for DHCPv4 to hide client info and emulate a Windows client (DHCPv6 doesn't send any too revealing info).

```
[Match]
Name=en*

[Network]
DHCP=yes
IPv6AcceptRA=yes
IPv6PrivacyExtensions=no
LLDP=yes
EmitLLDP=no

[DHCPv4]
RouteMetric=1024
UseDNS=yes
UseNTP=no
UseHostname=no
UseDomains=yes
Anonymize=yes

[DHCPv6]
RouteMetric=1024
UseDNS=yes
UseNTP=no
UseHostname=no
UseDomains=yes

[IPv6AcceptRA]
RouteMetric=1024
UseDNS=yes
UseDomains=yes
Token=prefixstable
```

### iwd Config

File: `/etc/iwd/main.conf`

```ini
[General]
AddressRandomization=network

[Settings]
AutoConnect=true

[Scan]
DisablePeriodicScan=no
```

### iwd Config

File: `/var/lib/iwd/eduroam.8021x` (for SSID `eduroam`)

The following values from the [eduroam configuration assistant tool (CAT)](https://cat.eduroam.org/) are required (from Arch iwd wiki page):

| iwd | eduroam | Comment |
| - | - |
| File name | `Config.ssids` (one) | Typically `eduroam`, with `8021x` file ending. |
| `EAP-Method` | `Config.eap_outer` | |
| `EAP-Identity` | `Config.anonymous_identity` | `@Config.user_realm` if missing. |
| `EAP-PEAP-CACert` | `Config.CA` | Place the cert data in a file and specify the path. |
| `EAP-PEAP-ServerDomainMask` | `Config.servers` (one) | Without `DNS:` prefix. |
| `EAP-PEAP-Phase2-Method` | `Config.eap_inner` | |
| `EAP-PEAP-Phase2-Identity` | `<username>`
| `EAP-PEAP-Phase2-Password` | `<password>` | |

Place the CA certificate in `/var/lib/iwd/eduroam.crt`.

NTNU eduroam template:

```ini
[Security]
EAP-Method=PEAP
EAP-Identity=@ntnu.no
EAP-PEAP-CACert=/var/lib/iwd/eduroam.crt
EAP-PEAP-ServerDomainMask=DNS:radius.ntnu.no
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=<username>@ntnu.no
EAP-PEAP-Phase2-Password=<password>

[Settings]
AutoConnect=true
```

### wpa_supplicant Config

File: `/etc/wpa_supplicant/wpa_supplicant.conf`

```
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=network
# Allow wpa_cli to add networks and change the config?
# File permissions may get fucked.
update_config=0
country=NO
# More agressive scanning for roaming
bgscan="simple:30:-70:3600"

# Example networks below, omit these

# WPA Personal
# Use "wpa_passphrase <ssid>" to generate a network stub with a PSK-hashed password to avoid cleartext.
network={
    ssid="Example"
    psk="HelloWorld"
}

# WPA Enterprise (PEAP-MSCHAPv2) (NTNU eduroam example)
network={
    key_mgmt=WPA-EAP
    pairwise=CCMP
    group=CCMP TKIP
    eap=PEAP
    phase2="auth=MSCHAPV2"
    # Point to actual EAP CA cert
    ca_cert="/var/lib/wpa_supplicant/certs/eduroam.crt"
    altsubject_match="DNS:radius.ntnu.no"
    anonymous_identity="@ntnu.no"
    # Your credentials
    identity="user@ntnu.no"
    password="user_password"
}

# dot1x wired (PEAP-MSCHAPv2)
# NOT TESTED
network={
    key_mgmt=IEEE8021X
    eap=PEAP
    identity="user_name"
    password="user_password"
    phase2="autheap=MSCHAPV2"
}
```

### Dunst Config

File: `~/.config/dunst/dunstrc`

```ini
[global]
monitor = 1
origin = top-left
#scale = 1
font = MesloLGS NF 8
background = "#333"
frame_color = "#888"
foreground = "#eee"
```

### Polybar Launch Script

File: `~/.config/polybar/launch.sh`

```bash
#!/bin/bash

killall -q polybar

#polybar main &>>/tmp/polybar.log &
polybar main >/dev/null 2>&1 &
```

### Polybar Spotify Module

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

### Rofi Config

file: `~/.config/rofi/config.rasi`

```
configuration {
    font: "MesloLGS NF 10";
}
@theme "glue_pro_blue"
```

### Xorg Monitors

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

### Xorg DPMS

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

### BASH Command Completion Configs

File: `/etc/profile.d/completion.sh`

```sh
# Don't include /usr/share/bash-completion/bash_completion,
# assume bashrc or something already includes it.
# We don't want that when reading /etc/profile with ZSH anyways.

if [[ $PS1 && -d /etc/bash_completion.d/ ]]; then
    for f in /etc/bash_completion.d/*; do
        test -r "$f" && . "$f"
    done
    unset f
fi
```

### i3 Media Keys

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

### i3 Volume Keys

File: `~/.config/i3/config`

Requires `pamixer`.

```
# Volume keys
bindsym XF86AudioRaiseVolume exec --no-startup-id pamixer -i 5
bindsym XF86AudioLowerVolume exec --no-startup-id pamixer -d 5
bindsym XF86AudioMute exec --no-startup-id pamixer -t
bindsym XF86AudioMicMute exec --no-startup-id pamixer --default-source -t
```

### i3 Maim Screenshot Keys

File: `~/.config/i3/config`

Requires `maim`.

```
# Capture screen (active window and full)
bindsym $mod+Print exec maim -i $(xdotool getactivewindow) $HOME/Downloads/Screenshot_$(date -Iseconds).png
bindsym $mod+Shift+Print exec maim $HOME/Downloads/Screenshot_$(date -Iseconds).png
```

## Troubleshooting

### Fix Boot

1. Boot into live-OS.
1. Find the disk: `lsblk`
1. Decrypt it: `cryptsetup luksOpen /dev/<partition> crypt_root`
1. Mount it: `mount /dev/mapper/crypt_root /mnt`
1. Mount the EFI partition: `mount /dev/<partition-1> /mnt/boot/efi`
1. Chroot into it: `arch-chroot /mnt`
1. Fix GRUB: `grub-install --target=x86_64-efi --efi-directory=/boot/efi && grub-mkconfig -o /boot/grub/grub.cfg`
1. Fix initramfs: `mkinitcpio -P`

If the GRUB or initramfs commands didn't work (e.g. if it broke during an Pacman upgrade and lots of packages are corrupt):

1. Exit the chroot (if inside it).
1. Mount other stuff:
    - `mount -t proc /proc /mnt/proc`
    - `mount --rbind /sys /mnt/sys`
    - `mount --rbind /dev /mnt/dev`
1. (Maybe) Fix DNS: `rm /mnt/etc/resolv.conf; echo nameserver 1.1.1.1 > /mnt/etc/resolv.conf`
1. (Maybe) Remove the Pacman DB lock: `rm /mnt/var/lib/pacman/db.lck`
1. (Maybe) Overwrite the Pacman mirrorlist: `cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist`
1. Reinstall all packages:
    1. Get packages: `pacman --sysroot /mnt -Qq >tmp.txt`
    1. Remove non-Pacman packages (e.g. from yay) from the text file until the next command succeeds.
    1. Reinstall: `pacman --sysroot /mnt -S --overwrite "*" - <tmp.txt`
1. Fix boot dir perms: `chmod 700 /mnt/boot`
1. Fix resolvconf: `ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf`
1. Reboot into fixed OS.
1. Fix AUR packages: `yay -Qqm | yay -S -`

{% include footer.md %}
