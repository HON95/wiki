---
title: Windows
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

### Using
{:.no_toc}

- Windows 10

## Installation

- There's no need to provide a product/activation key. If the PC (motherboard?) has been activated before, it will automatically activate when starting the first time.
- Use a local account. Link to a Microsoft account later if needed, but preferably only for Microsoft apps.
- Say no to everything privacy related.

## Setup

- Install all available updates.
- Install graphics drivers and fix display frame rates, color ranges (use full range for PC displays and limited for TVs, generally) etc.
- Enable BitLocker drive encryption (requires Pro edition):
    - Note: Using passwords and not TPM because I don't want my PC to decrypt itself without me and because I need to move disks between PCs.
    - Allow using it without a TPM module:
        - Open `gpedit.msc`.
        - Go to: `Local Computer Policy/Computer Configuration/Administrative Templates/Windows Components/Bitlocker Drive Encryption/Operating System Drives`
        - Edit "Require additional authentication at startup".
            - Enable it.
            - Allow without compatible TPM module.
            - Do not allow TPM.
        - Enable "allow enhanced PINs for startup".
    - Setup BitLocker for drives:
        - Enter the BitLocker management settings.
        - Enable for all disks.
        - Save the recovery keys somewhere safe, it's required sometimes to unlock the disk.
        - Enable auto-unlock for other encrypted disks.
- Disable the lock screen:
    - Because it's annoying.
    - Open `regedit`.
    - Go to `HKEY_LOCAL_MACHINE/SOFTWARE/Policies/Microsoft/Windows`.
    - Create a new key (dir) named `Personalization`.
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
    - Use balanced mode (high performance mode is a waste of energy with no benefits).
    - Extend periods for turning off stuff.
    - Disable the sleep timer.
    - Set the minimum processor state to 0% (for power saving with DVFS).
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
- Setup WSL:
    - Google it.
- Accounts settings:
    - (Optional) Add login PIN to avoid typing the password from the lock screen.
- Gaming settings:
    - Disable "Record \[...\] using Game bar".
    - Keep Game Mode enabled.

## Troubleshooting

### Docker

**Time in containers is wrong when using WSL backend**:

Restart WSL every time it happens. It's a known bug still not fixed.

{% include footer.md %}
