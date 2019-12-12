---
title: Windows Applications
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration
  url: /config/
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}
Windows 10

## PuTTY

- In `Terminal > Features`, activate `Disable application keypad mode`.
- In `Window > Appearance`, change font to Consolas, regular, size 10.
- In `Window > Colours`, set all ANSI non-bold colors to the same as the bold ones.

## Speedfan

- **Warning:** The controller symlinks likes to change on boot, meaning the config may break every boot. This makes it literally useless.
- Manually add startup shortcut.
- Disable `Do SMART Summary Error Log scan on startup` since it may cause the PC to freeze.
  - Alternatively, use the CLI argument `/NOSMARTSCAN`.
- Set the PWM mode for fans which will be controlled by Speedfan to manual.

{% include footer.md %}
