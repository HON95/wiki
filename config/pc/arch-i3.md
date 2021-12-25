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
    1. Note: For cabled Ethernet with DHCP, it should already be working. For WLAN or exotic setups, check the wiki.
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
    1. Note: GRUB has limited support for LUKS2, so use LUKS1.
    1. Check which cryptohash and encryption algorithms are fastest on the system: `cryptsetup benchmark`
    1. Create: `cryptsetup luksFormat --type=luks1 --use-random -h sha256 -i 5000 -c aes-xts-plain64 -s 256 /dev/<partition-2>` (example parameters)
    1. Enter the password to unlock the system during boot.
    1. Note: See the step way down for avoiding entering the password twice during boot.
1. Unlock the encrypted root volume:
    1. `cryptsetup luksOpen /dev/<partition> crypt_root` (for example name `crypt_root`)
1. Format the root volume:
    1. `mkfs.ext4 /dev/mapper/crypt_root`
1. Mount the volumes:
    - Mount root: `mount /dev/mapper/crypt_root /mnt`
    - Mount ESP: `mkdir -p /mnt/boot/efi && mount /dev/<partition> /mnt/boot/efi`
1. Install packages to the new root:
    - Base command and packages: `pacstrap /mnt base linux linux-firmware vim sudo bash-completion man-db man-pages xdg-utils xdg-user-dirs`
    - **TODO** Maybe: `wpa_supplicant networkmanager`
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
    1. Install useful tools: `pacman -S --needed most zsh vim man-db man-pages htop bash-completion p7zip git jq rsync openssh tmux screen reflector`
1. Install display driver:
    - For NVIDIA Maxwell and newer GPUs: `pacman -S nvidia nvidia-utils nvidia-settings`.
    - (Optional) For NVIDIA CUDA (in addition to driver): `pacman -S cuda`
    - For AMD GPUs, older NVIDIA GPUs and other GPUs, check the wiki.
1. Avoid having to enter the encryption password twice during boot:
    1. Note: To avoid entering the password once for GRUB and then for the initramfs, we can create a keyfile and embed it into the initramfs. If the keyfile fails, it will fall back to asking for a password again.
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
    1. Note: Both the `wheel` and `sudo` groups are commonly used for giving sudo access, but I personally prefer `sudo` since `wheel` _may_ also be used by polkit rules, su (`pam_wheel`), etc.
    1. Install: `pacman -S sudo`
    1. Add the sudo group: `groupadd -r sudo`
    1. Enter the config: `EDITOR=vim visudo`
    1. Add line to allow sudo group without password: `%sudo ALL=(ALL) NOPASSWD: ALL`
    1. (Later) Give users sudo access through the group: `usermod -aG sudo <user>`
1. Add a personal user:
    1. Create the user and add it to relevant groups: `useradd -m -G sudo,adm,sys,uucp,proc,systemd-journal <user>`
    1. Set its password: `passwd <user>`
    1. **TODO** Required to run `xdg-user-dirs-update` manually, at least before a DE/WM is installed?
    1. Relog as the new user, both to make sure that it's working and because some next steps require a non-root user.
1. Install yay to access the AUR:
    1. Note: This needs to be done as non-root.
    1. Install requirements: `pacman -S --needed base-devel git`
    1. Clone and enter: `git clone https://aur.archlinux.org/yay.git && cd yay`
    1. Install: `makepkg -si`
    1. Remove the tmp. repo: `cd .. && rm -rf yay`
    1. Idk (once): `yay -Y --gendb`
1. Enable early numlock (initramfs phase):
    1. Install package: `yay -S mkinitcpio-numlock`
    1. Add `numlock` to the `HOOKS` list in `/etc/mkinitcpio.conf` before `encrypt` (assuming the system is encrypted) (e.g. before `modconf`).
    1. Regenerate the initramfs: `mkinitcpio -P`
1. Tweak the PAM login faillock:
    1. Note: It applies to password logins only, not SSH keys.
    1. Note: To unlock a user, run `faillock --reset --user <user>`.
    1. Increase the failed login count threshold: In `/etc/security/faillock.conf`, set `deny = 5`.
1. Setup the local DNS resolver (systemd):
    1. Note: The systemd-resolve config is `/etc/systemd/resolved.conf`.
    1. Configure the upstream DNS servers: In the confug, set `DNS=1.1.1.1 2606:4700:4700::1111`.
    1. (Optional) Set the domain/search string: In the config, set `Domains=<domain>`.
    1. Enable or disable DNSSEC validation (do if the upstream servers don't): In the config, set `DNSSEC=<yes|no>`.
    1. Enable and start it: `systemctl enable --now systemd-resolved`
    1. Setup `resolv.conf`: `ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
    1. Check: `curl google.com`
1. Setup the NTP client (systemd):
    1. Note: The default server pool is fine.
    1. Enable: `timedatectl set-ntp true`
    1. Check: `timedatectl` (see the "synchronized" field)
1. Setup firewall (IPTables):
    1. Install IPTables: `sudo pacman -S iptables`
    1. Enable the IPTables services: `sudo systemctl enable --now iptables.service ip6tables.service`
    1. Download my IPTables script (or do it yourself): `curl https://raw.githubusercontent.com/HON95/scripts/master/iptables/iptables.sh -o /etc/iptables/config.sh`
    1. Make it executable: `chmod +x /etc/iptables/config.sh`
    1. Modify it.
    1. Run it: `/etc/iptables/config.sh`

### Setup Xorg, LightDM and i3

1. Setup the Xorg display server (minimal):
    1. Install: `pacman -S xorg-server xorg-xinit xorg-xrandr`
    1. Fix the keyboard layout for X11: `sudo localectl set-x11-keymap <keymap>` (e.1. `no`)
1. Setup the LightDM display manager (aka login manager):
    1. Note: User-local configuration/profile-stuff should be placed in `~/.xprofile`.
    1. Install: `pacman -S lightdm`
    1. Enable: `systemctl enable lightdm`
1. Setup the LightDM GTK+ greeter (aka login screen) (one of many):
    1. Note: The GTK+ greeter may be configured in `/etc/lightdm/lightdm-gtk-greeter.conf` or using the `lightdm-gtk-greeter-settings` GUI.
    1. Install: `pacman -S lightdm-gtk-greeter`
    1. Set it as the default: In `/etc/lightdm/lightdm.conf`, under the `[Seat:*]` section, set `greeter-session=lightdm-gtk-greeter`.
    1. (Optional) Set the background: In `/etc/lightdm/lightdm-gtk-greeter.conf`, under the `[greeter]` section, set `background=<image-path>`. The `/usr/share/pixmaps` dir is recommended for storing backgrounds.
1. **TODO** Setup the Webkit2 greeter with the Litarvan theme.
1. Enable numlock on by default for LightDM:
    1. Install: `pacman -S numlockx`
    1. Configure: In `/etc/lightdm/lightdm.conf`, under the `[Seat:*]` section, set `greeter-setup-script=/usr/bin/numlockx on`.
1. Install the i3 window manager:
    1. Note: The "gaps" part will be set up later, i3-gaps will work just like plain i3 for now.
    1. Install: `pacman -S i3-gaps`
1. Setup the Polybar system bar:
    1. Note: i3bar, the default i3 system bar, shows workspaces and tray icons. It can include extra info like IP addresses and resource usage using i3status or i3blocks. Polybar is a replacement for i3bar.
    1. Disable i3bar: Comment the whole `bar` section of the i3 config.
    1. Install polybar: `yay -S polybar`
    1. Create the config: `mkdir ~/.config/polybar && cp /usr/share/doc/polybar/config ~/.config/polybar/config`
    1. Customize config:
        - Rename the "example" bar to e.g. "main" (or create one from scratch).
        - For the bar, set `bottom = true` to move it to the bottom.
        - For the bar, comment `radius` to disable rounded corners.
        - For the bar, comment `border-size` to disable the padding/border around the bar.
        - For the date module, customize how time should appear. "Alt" variants are swapped to when the module is clicked ().
        - For the network/"eth" module, use `%local_ip6%` for the IPv6 address (one of them).
    1. Create a startup script: See the section below to use the new "main" bar.
    1. Add to i3: In the i3 config, add `exec_always --no-startup-id $HOME/.config/polybar/launch.sh`.
1. Setup the some terminal emulator:
    1. (Alternative) Setup xfce4-terminal (GUI config, copy-paste, just works):
        1. Install: `pacman -S xfce4-terminal`
        1. Update font (example): Install `ttf-hack`, restart the terminal, and change to "Hack" size 10.
    1. (Alternative) Install urxvt (ugly and useless by default but very customizable and extendable):
        1. Install: `pacman -S rxvt-unicode`
        1. Fix the ugliness and uselessness.
    1. Setup i3: In the i3 config, replace the `bindsym $mod+Return` line with `bindsym $mod+Return exec <terminal>`
1. Setup the Rofi application launcher:
    1. Install: `pacman -S rofi`
    1. Install rofimoji for emoji menu: `pacman -S rofimoji xdotool`
    1. Find a theme interactively (without selecting any): `rofi-theme-selector` (e.g. `glue_pro_blue`)
    1. Configure Rofi: Create `~/.config/rofi/config.rasi`, see the example below.
    1. Configure Rofimoji: Create `~/.config/rofimoji.rc` and set `action = copy` (copy to clipboard by default).
    1. Disable old i3 dmenu shortcut: In the i3 config, comment the `bindsym $mod+d` line.
    1. Setup i3 drun shortcut: In the i3 config, set `bindsym $mod+d exec rofi -show drun`.
    1. Setup i3 window shortcut: In the i3 config, set `bindsym $mod+shift+d exec rofi -show window`.
    1. Setup i3 emoji shortcut: In the i3 config, set `bindsym $mod+mod1+d exec rofi -modi "emoji:rofimoji" -show emoji`.
1. Setup fonts:
    1. `pacman -S noto-fonts notn-fonts-emoji`
1. Test LightDM and i3:
    1. Restart LightDM and get pulled into it: `systemctl restart lightdm`
    1. Select the i3 WM and log in.
    1. Follow the basic i3 setup wizard:
        1. Generate a new config.
        1. `Win` as default modifier.
    1. Test i3: `Mod+Return` to open terminal, `Mod+D` to open app launcher, etc.
1. Setup background image:
    1. Download a desktop image.
    1. Install the FEH image viewer: `pacman -S feh`
    1. Update i3: In the i3 config, set `exec_always --no-startup-id feh --bg-scale $HOME/Pictures/mc.jpg` (example image).
1. Setup i3 gaps:
    1. Disable window title bar (required): In the i3 config, add `for_window [class=".*"] border pixel 4` to only show the border and no title bar, or `0` to remove the border too.
    1. Add gaps around windows: In the i3 config, add `gaps inner 8`.
1. Install clipboard manager:
    1. `pacman -S xsel`
1. Setup screen locking:
    1. **TODO** Multi-monitor support? Haven't tested yet.
    1. Install the `i3lock-fancy` screen locker: `yay -S i3lock-fancy-git`
    1. Install the `xss-lock` automatic locker trigger: `pacman -S xss-lock`
    1. Update i3 to use `i3lock-fancy`: In the i3 config, find the example `xss-lock` line and replace it with `exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock-fancy --nofork`. i3 needs to be completely restarted for this to start.
    1. Set a locking keybind in i3: In the i3 config, add `bindsym $mod+l exec --no-startup-id i3lock-fancy --nofork`. This may conflict with some `focus` keybinds you probably don't need, so just remove those.

### Setup Audio

1. Note: We're using the PipeWire sound server, a compatible replacement for both PulseAudio and JACK.
1. Install ALSA stuff:
    1. Note: ALSA itself is already provided as built-in kernel modules and ALSA drivers will just work.
    1. Install ALSA utils and firmware: `pacman -S alsa-utils alsa-firmware`
1. Install PipeWire (including WirePlumber and adapters):
    1. Install: `pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 wireplumber pavucontrol`
    1. Start the PulseAudio adapter (to avoid relogging): `systemctl start --user pipewire-pulse`
1. Configure inputs and outputs:
    1. Run `pavucontrol` to configure volumes, inputs, outputs and stuff.
1. Test it:
    1. Try playing something from the browser or whatever. It should work.
1. **TODO** Bluetooth support. Check the PipeWire page.
1. Install useful audio applications:
    1. Install the Helvum patchbay to patch nodes and endpoints (inputs and outputs for all audio devices): `pacman -S helvum`
    1. See the [PipeWire page (Arch Wiki)](https://wiki.archlinux.org/title/PipeWire).

### Setup Applications

1. Setup terminal emulator:
    1. Already done.
1. Setup ZSH:
    1. See [Applications: ZSH](../applications/#zsh-linux) (includes font, theme and plugins).
1. Setup the VLC video and audio player:w
    1. `pacman -S vlc`
1. Setup the Mirage image viewer:
    1. `yay -S mirage`
1. Setup the Thunar graphical file manager:
    1. `pacman -S thunar`
1. Setup the Ranger terminal file explorer:
    1. `pacman -S ranger`
1. Setup the VS Code text editor (and much more):
    1. `pacman -S code`

### Extra steps (Optional)

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

This example sets up interface `eno1` (the main interface, see `ip a`) to use DHCPv4 and SLAAC/DHCPv6.

`/etc/systemd/network/eno1.network` (example):

```
[Match]
Name=eno1

[Network]
DHCP=yes
```

#### Polybar Launch Script

```bash
#!/bin/bash

killall -q polybar

polybar main &>>/tmp/polybar.log

echo "Polybar launched"
```

#### Rofi Config

```
configuration {
    font: "hack 12";
}
@theme "glue_pro_blue"
```

{% include footer.md %}
