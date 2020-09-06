---
title: VyOS
breadcrumbs:
- title: Configuration
- title: Network
---
{% include header.md %}

## Installation

See [Installation (VyOS)](https://docs.vyos.io/en/latest/install.html).

1. (Recommended) Disable Intel Hyper-Threading.
1. Download the latest rolling release (free) or LTS release (paid) ISO.
1. Burn and boot from it (it's a live image).
1. Log in using user `vyos` and password `vyos`.
1. Run `install image` to run the permanent installation wizard.
    - Copy the `config.boot.default` config file.
1. Remove the live image and reboot.

## Configuration

### Basic Usage

- The system is in "operational mode" after logging in. Enter "configuration mode" using the `configure` command.
- Use `?` to show alternatives and tab to auto-complete.
- Use `commit` to apply configuration changes and `save` to make them permanent.

{% include footer.md %}
