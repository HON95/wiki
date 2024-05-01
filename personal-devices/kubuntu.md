---
title: Kubuntu
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

### Using
{:.no_toc}

- Kubuntu 20.10

## Installation

1. Use the guided partitioner.
    - The manual installer is broken and can't create encrypted volumes.

## Setup

1. Packages:
    - Install upgrades: `sudo apt update && sudo apt dist-upgrade --autoremove`
    - Install extra stuff: `sudo apt install curl vim nmap`
1. Setup default editor:
    - Set editor: `sudo update-alternatives --config editor` and select `vim.basic`.
1. Disable password for the sudo group by running `visudo` and changing the sudo group line to `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`.
1. Make sure the correct graphics drivers are in use (e.g. the proprietary Nvidia driver).
1. Fix the displays (positions, resolutions, refresh rates).
1. Enable numlock on boot (search for it).
1. Appearance:
   - Change to the dark theme.
   - Make all fonts 1 size smaller.
1. Shortcuts:
   - Disable web search keywords.
1. Setup panels for all screens. Only show tasks for the current screen.
1. Setup clipboard:
    - Open the clipboard settings from the taskbar.
    - Select "ignore selection" to avoid copying when selecting text.
    - Set the history size to 1 (effectively disabling the history).
1. Setup firewall:
    - Remove other firewalls: `sudo apt purge ufw firewalld`
    - Install IPTables stuff: `sudo apt install iptables iptables-persistent netfilter-persistent`
    - (Alternative 1) Create an IPTables script (e.g. [iptables.sh](https://github.com/HON95/scripts/blob/master/iptables/iptables.sh)).
    - (Alternative 2) Run my preset (basics only, no SSH etc.): `curl https://raw.githubusercontent.com/HON95/scripts/master/iptables/iptables.sh | sudo bash`

### Extra

1. Install applications: See [PC Applications](/personal-devices/applications/).
1. (Optional) Install encrypted DVD support:
    - Install: `sudo apt install libdvd-pkg && sudo dpkg-reconfigure libdvd-pkg`
    - Warning: Don't change the region if not necessary. It's typically limited to five changes.

### PipeWire

Kubuntu comes with PulseAudio. PipeWire is a modern solution designed to replace PulseAudio, JACK and ALSA. This means it combines the simplicity of basic desktop usage from PulseAudio with the complexity of session managers from JACK, with extra focus on security, performance and compatibility. Plus it supports video. See [PipeWire (Applications)](/personal-devices/applications/#pipewire) for more config info.

1. Install PipeWire:
    1. Install: `sudo apt install pipewire pipewire-audio-client-libraries pipewire-pulse`
    1. **TODO** Required to enable pipewire or pipewire-pulse?
1. Disable PulseAudio:
    1. (Note) The package is required by Kubuntu, so it can't be completely removed.
    1. Disable PulseAudio: `systemctl --user disable --now pulseaudio.service pulseaudio.socket`
    1. Mask PulseAudio: `systemctl --user mask pulseaudio.service pulseaudio.socket`
1. Setup the PulseAudio adapter:
    1. Install `pipewire-audio-client-libraries` (done in the last step).
    1. Create this file for some reason: `touch /etc/pipewire/media-session.d/with-pulseaudio`
    1. Add the `pipewire-pulse` service: `cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* /etc/systemd/user/`
    1. Reload systemctl: `systemctl --user daemon-reload`
    1. Enable: `systemctl --user enable pipewire`
    1. Restart everything: `systemctl --user restart pipewire pipewire-pulse`
1. (Note) PipeWire comes with a "Pro Audio" profile (selectable in pavucontrol), for sound cards with multiple inputs and/or outputs which shouldn't get tossed together into e.g. a 5.1 profile.
1. (Optional) Install the WirePlumber session manager:
    1. (Warning) This is broken and doesn't work properly when using the slightly outdated version of PipeWire available in the main repos.
    1. See [Installing WirePlumber (WirePlumber wiki)](https://pipewire.pages.freedesktop.org/wireplumber/installing-wireplumber.html).
    1. (Note) You may need to checkout an older version if the installed version of PipeWire is outdated. Search the dependency file [commit history](https://gitlab.freedesktop.org/pipewire/wireplumber/-/commits/master/meson.build) for pipewire bumps.
    1. (Note) Required dependencies: `build-essential libglib2.0-dev libspa-0.2-dev libpipewire-0.3-dev lua5.3 meson cmake`
1. (Optional) Install the Helvum patchbay:
    1. See the [Helvum repo](https://gitlab.freedesktop.org/ryuukyu/helvum).

## Troubleshooting

**The system settings and other apps crash after updating the graphics driver:**

Reboot the system.

**Connecting an Xbox One controller over Bluetooth fails for some unknown reason:**

1. `sudo apt install sysfsutils`
1. `echo "/module/bluetooth/parameters/disable_ertm=1" | sudo tee -a /etc/sysfs.conf`
1. `reboot`

{% include footer.md %}
