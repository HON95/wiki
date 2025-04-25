---
title: Cisco Catalyst App Hosting
breadcrumbs:
- title: Containers
---
{% include header.md %}

## General

- These notes are mainly targeted at the Cisco Catalyst 9000 series switches (IOS-XE), but many other Cisco platforms support app hosting too.
- Available resources (example devices):
    - Cat9300: 1x1G AppGig port, 2GB RAM, 1 CPU-core, x86_64.
    - Cat9400: 1x1G AppGig port, 8GB RAM, 2 CPU-core, x86_64.
    - Cat9500: Mgmt port, 2GB RAM, 1 CPU-core, x86_64.
- External storage can be supported using a dedicated SSD that may be installed in the switch. The internal storage may only be used by certain Cisco-signed apps.
- DNA Advantage license is required for Cat9k switches (`network-advantage` and `dna-advantage`).
- Memory, CPU and storagre is isolated from network functions, to avoid network interruptions from the application.
- The container can be connected to a bridge connected to the management port and/or to a bridge connected to the front-panel ports.
- For switch stacks, the application only runs on the primary.
- App hosting on switches may be used e.g. for network reachability monitoring, local network applications and traffic inspection.
- App hosting on APs may be used e.g. for shelf label management, asset tracking and patient tracking, using BLE or WLAN.

## App Design

- Using Docker images for the applications.
- Cat9k and N5K support running Docker images natively, while most other platforms (e.g. access points) require using ioxclient with the Docker image and a `package.yml` file descriptor to create an IOx compatible application. Both variants require uploading the image as a `.tar` file to the switch.
- The IOx application can be deployed using ioxclient, CatC, YANG, CLI or the web UI. CatC is generally recommended for production workflows.
- Alpine Linux is recommended as the Docker base image does to its small size and low memory usage.
- Cisco apps are always signed.
- If you need to cross-compile with Docker (e.g. building for ARM platforms on an x86_64 platform), use an appropriate base image and add `--platform linux/arm64` or similar to the Docker build command line.
- Access points:
    - Uses an ARM architecture, so an appropriate base image and cross compilation may be needed.
    - ioxclient is required to build and deploy the application.
    - Images for access points should not exceed 20MB.
    - Remember to activate "apphost" in the AP profile.
    - The application will typically run behind the management IP address of the AP, using NAT and DHCP internally. The CAPWAP tunnel will not be used for application hosting, it's always locally switched.

## Configuration and Operation

- Enable `iox` in the IOS-XE config. Show status with `show iox-service`.
- App signature validation can be disabled from the web UI.
- The front-panel bridge is configured using the `AppGigabitEthernet` interface. This should typically be a trunk with relevant VLANs allowed.
- The application is configured using a `app-hosting` config section.
- Management commands:
    - Unpackage the app: `install appid cleu25 package usbflash1:demo.tar` (example)
    - Reserve resources for app: `activate appid <name>`
    - Start the app: `start appid <name>`
    - Stop the app: `stop appid <name>`
    - Release resources for the app: `deactivate appid <name>`
    - Remove app files: `uninstall appid <name>`
- Show commands:
    - Show apps: `show app-hosting list`
- CatC integration for management:
    - Found in "Provision > Application Hosting" for switches or "Provision > Services > IoT Services" for APs.
    - Supports creating/uploading apps and deploying them to managed switches.

**AppGigabitEthernet interface example:**

```
interface AppGigabitEthernet1/0/1
  switchport mode trunk
  switchport trunk allowed vlan 100
```

**App hosting example:**

```
app-hosting appid cleu25
  app-vnic AppGigabitEthernet trunk
    vlan 100 guest-interface 0
```

{% include footer.md %}
