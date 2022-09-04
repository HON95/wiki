---
title: Linksys LGS Switches
breadcrumbs:
- title: Network
---
{% include header.md %}

### Using
{:.no_toc}

- LGS326

## Information

- Default IP address: DHCPv4 with fallback to `192.168.1.251/24`.
- Default credentials: Username `admin` with password `admin`.
- MCLI password: `mcli`

## Basic Setup (HTTP GUI)

1. Wait for it to boot (a few minutes).
1. (Optional) Reset the configuration:
    1. Hold the reset button for 15 seconds (minimum 10 seconds) to clear its configuration. When released, the port LEDs should start go dark or start blinking or something.
    1. Wait for it to reboot.
1. Connect the switch to the upstream network or to your PC. It will use the default IP address `192.168.1.251` or use a DHCP address. If using the default address, the system LED will be blinking. If it gets assigned a DHCP address, it will stop blinking.
1. Access the HTTP portal and login using username "admin" and password "admin".
1. (Optional) Update the firmware:
    1. Check the firmware version in the banner and check if it is the latest version (1.1.1.9 for LGS326 last time I checked).
    1. Go to "maintenance", "file management", "firmware & boot code".
    1. Upload and apply the new version.
    1. Reboot the device for it to take effect.
1. (Optional) Upload a config:
    1. Go to "maintenance", "file management", "configuration & log".
    1. "Download" the new config to the switch, either to running config or startup config.
        - Uploading to running config: The config will take effect immediately, which may include changing the IP address. Remember to copy it to startup config afterwards. Do this when testing new config changes.
        - Uploading to startup config: Wait for the upload to finish, then reboot the device for it to take effect. Only do this for functioning configs.
    1. Wait for it to come back up to whatever IP address it's configured to use (should take under a minute). If it doesn't come back up within a few minutes, fix the config and restart/reset the switch.

## Basic Setup (Telnet CLI)

**TODO**

{% include footer.md %}
