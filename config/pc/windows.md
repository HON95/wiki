---
title: Windows
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: PC
---
{% include header.md %}

Using: Windows 10

## Installation

- There's no need to provide a product/activation key. If the PC \(motherboard?\) has been activated before, it will automatically activate when starting the first time.
-  Use a local account. Link to a Microsoft account later if needed, but preferably only for Microsoft apps.
- Say no to everything privacy related.

## After Installation

- Install all available updates.
- Install graphics drivers and fix display frame rates, color ranges \(use full range for PC displays and limited for TVs, generally\) etc.
- Enable BitLocker drive encryption for all drives.
  - Allow using it without a TPM module:
    - Open `gpedit.msc`.
    - Go to: `Local Computer Policy/Computer Configuration/Administrative Templates/Windows Components/Bitlocker Drive Encryption/Operating System Drives`
    - Edit "Require additional authentication at startup".
      - Enable it.
      - Allow without compatible TPM module.
      - Do not allow TPM.
    - Enable "allow enhanced PINs for startup".
- Disable the lock screen: [How to Disable the Lock Screen on Windows 10 \(Lifewire\)](https://www.lifewire.com/disable-lock-screen-windows-10-4173812)
  - Open `regedit`.
  - Go to `HKEY_LOCAL_MACHINE/SOFTWARE/Policies/Microsoft/Windows`.
  - Create a new key named `Personalization`.
  - Add a new DWORD named `NoLockScreen` with value `1`.
- Change the computer name.
- Check Windows Security.
- Start menu:
  - Remove useless tiles.
- Sound Control Panel:
  - Disable unused playback and recording devices.
  - Set "format" for used devices.
  - Set to do nothing when Windows detects communications activity.
- Windows Explorer:
  - Set File Explorer to open to "this PC".
  - Hide recently used files and folders in Quick access.
  - Show known file endings and hidden files.
  - Show merge conflicts.
- Power settings:
  - Used balanced.
  - Extend periods for turning off stuff.
  - Disable the sleep timer.
  - Allow the CPU to reduce its "utilization" \(for Intel SpeedStep\).
- Device settings:
  - Disable AutoPlay.
- Personalisation settings:
  - Enable dark mode.
  - Remove lock screen apps.
  - In desktop icon settings, hide the recycle bin.
  - Only show app list in start menu.
  - Configure the taskbar.
- Apps settings:
  - Uninstall useless apps and programs.
  - Change optional features and Windows features.
    - Install the Windows Subsystem for Linux, then Ubuntu from the Microsoft Store.
- Accounts settings:
  - Add login PIN to avoid typing the password from the lock screen.
- Gaming settings:
  - Disable "Record \[...\] using Game bar".
  - Keep Game Mode enabled.

## Troubleshooting

### Windows Subsystem for Linux \(WSL\)

#### Linux Kernel CMA Support was Requested ...

```text
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

{% include footer.md %}
