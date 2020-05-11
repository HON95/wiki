---
title: Home Assistant
breadcrumbs:
- title: Configuration
- title: Linux Servers
---
{% include header.md %}

## Installation (Proxmox)

These steps are for installing the Home Assistant image in Proxmox. There is also a "Core" variant which can be installed as a Docker image, but don't doesn't include the add-on store.

1. Create the VM in Proxmox:
    - It must use OVMF (UEFI).
    - The main hard drive doesn't matter, it will be removed later.
    - Enable QEMU agent.
1. Download the VMDK image from [Installing Home Assistant](https://www.home-assistant.io/hassio/installation/) to the Proxmox host.
1. Import the image to the VM: `qm importdisk <vmid> hassos.vmdk <storage> -format <qcow2|raw>`
1. Detach and remove the existing main disk for the VM.
1. Attach the newly imported disk for the VM (by double clicking it).
1. Start the VM and make sure it boots properly.
1. Open the web wizard to configure it.
    - It uses port 8123.
    - To find its IP address, log in from console (see below) and run `ipconfig`. It only listens on IPv4.
1. (Optional) Setup DHCP reservations to make its IP addresses static.
1. (Optional) If you need to configure something from console, log in as root with no password.
    - Type `login` to open a shell.
1. (Optional) Install some useful add-ons:
    - "File editor" or "Visual Studio Code"

## Integrations and Add-Ons

### Telldus Live Integration

**TODO** Make this work.

See [Telldus Live (Home Assistant)](https://www.home-assistant.io/integrations/tellduslive/).

These instructions use the local API (supported by TellStick Net v2, ZNet Lite v1/v2 and possibly more) insetad of the cloud API for devices that support it. This does not require the [TellStick add-on](https://www.home-assistant.io/integrations/tellstick/).

1. Make sure the device has a static IP address (use DHCP reservations).
1. Set up the device with Telldus Live.
    - The website is absolutely terrible, use the app when possible.
1. Add the configuration snippet below to `configuration.yml` containing the IPv4 address of the device.
    - This is required for using the local API.
    - While it does request an IPv6 address, its services don't seem to listen to IPv6.
1. Restart Home Assistant.
1. Open Home Assistant and open the page to add integrations. "Telldus Live" should appear as discovered.
1. Configure the discovered integration using the Telldus device, not the cloud API.
    - If it fails and the discovered integration disappears, then restart Home Assistant again.
    - It will take you to both Telldus Live and the device to authenticate the integration.

```yaml
# ...
tellduslive:
    host: <ipv4-or-hostname>
```

{% include footer.md %}
