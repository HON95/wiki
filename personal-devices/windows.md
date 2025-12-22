---
title: Windows
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

## Installation

- Product key:
    - There's no need to provide a product/activation key. If the PC (motherboard?) has been activated before, it will automatically activate when starting the first time.
- Disable TPM and Secure Boot checks (if not supported by PC):
    - Must be done early in the installation wizard.
    - Press `Shift+F10` to open a terminal (including `Fn` if laptop).
    - Run `regedit`.
    - Go to `HKEY_LOCAL_MACHINE\SYSTEM\Setup`.
    - Create new key `LabConfig` and enter it.
    - Create new DWORD `BypassTPMCheck` with value 1.
    - Create new DWORD `BypassSecureBootCheck` with value 1.
    - Close regedit and the command prompt and continue with the installation.
- Local user account:
    - Must be done early in the installation wizard.
    - Press `Shift+F10` to open a terminal (including `Fn` if laptop).
    - Disable the internet connection requirement (triggers a restart): `oobe\bypassnro`
    - If a network interface is connected, it needs to be disconnected before proceeding with the wizard. Open the terminal again and enter `ipconfig /release`. If using Wi-FI, simply press "I don't have internet" instead.
    - Link to a Microsoft account later if needed, but preferably only for Microsoft apps.
- Options:
    - Say no to everything privacy related.

## Setup

- Install all available updates.
- Install graphics drivers and fix display frame rates, color ranges (use full range for PC displays and limited for TVs, generally) etc.
- (Optional) Enable BitLocker drive encryption (requires Windows Pro edition):
    - (Note) Using passwords and not TPM because I don't want my PC to decrypt itself without me and because I need to move disks between PCs.
    - If you have a TPM module: Disable it in the BIOS settings.
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
    - Because it's annoying to wait before I can start typing the password.
    - Open `regedit`.
    - Create key `HKEY_LOCAL_MACHINE/SOFTWARE/Policies/Microsoft/Windows/Personalization`.
    - Within it, create DWORD `NoLockScreen` and set it to `1`.
- (Optional) Set hardware clock to use UTC:
    - Because Linux uses it, so the Windows time will be wrong if dual booting.
    - Open `regedit`.
    - Set DWORD `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal` to `1`.
- Disable network throttling:
    - Open CMD as admin.
    - Run `netsh int tcp show global` and look for "Receive Window Auto-Tuning Level". "enabled" means throttling is enabled.
    - Run `netsh int tcp set global autotuninglevel=disabled` to disable it.
- Change the computer name.
- Check Windows Security.
- Sound settings:
    - Go to "system settings -> sound -> more sound settings" to find the old sount control panel.
    - Disable unused playback and recording devices.
    - Set "format" for used devices.
    - Set to do nothing when Windows detects communications activity.
- Display settings:
    - Disable scaling.
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
- Keyboard settings:
    - Disable the layout change shortcut:
        1. Go to "Advanced keyboard settings" (settings), "Input language hot keys" (window), "Advanced key settings" (tab).
        1. Press "change key sequence" for the "between input languages" entry and set both options to "no assigned".
- Personalisation settings:
    - Enable dark mode.
    - Remove lock screen apps.
    - In desktop icon settings, hide the recycle bin.
    - Only show app list in start menu.
    - Configure the taskbar.
    - Configure the start menu.
- Apps settings:
    - Uninstall useless apps and programs.
    - Change optional features and Windows features.
- Accounts settings:
    - (Optional) Add login PIN to avoid typing the password from the lock screen.

## Setup (Windows 10)

*Possibly outdated.*

- Install all available updates.
- Install graphics drivers and fix display frame rates, color ranges (use full range for PC displays and limited for TVs, generally) etc.
- Enable BitLocker drive encryption (requires Windows Pro edition):
    - (Note) Using passwords and not TPM because I don't want my PC to decrypt itself without me and because I need to move disks between PCs.
    - If you have a TPM module: Disable it in the BIOS settings.
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
    - Because it's annoying to wait before I can start typing the password.
    - Open `regedit`.
    - Set DWORD `HKEY_LOCAL_MACHINE/SOFTWARE/Policies/Microsoft/Windows/Personalization/NoLockScreen` to `1`.
- Set hardware clock to use UTC:
    - Because Linux uses it, so the Windows time will be wrong if dual booting.
    - Open `regedit`.
    - Set DWORD `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal` to `1`.
- Disable network throttling:
    - Open CMD as admin.
    - Run `netsh int tcp show global` and look for "Receive Window Auto-Tuning Level". "enabled" means throttling is enabled.
    - Run `netsh int tcp set global autotuninglevel=disabled` to disable it.
- Change the computer name.
- Check Windows Security.
- Disable pointless startup apps (through the task manager).
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
- Keyboard settings:
    - Disable the layout change shortcut:
        1. Go to "Advanced keyboard settings" (settings), "Input language hot keys" (window), "Advanced key settings" (tab).
        1. Press "change key sequence" for the "between input languages" entry and set both options to "no assigned".
- Personalisation settings:
    - Enable dark mode.
    - Remove lock screen apps.
    - In desktop icon settings, hide the recycle bin.
    - Only show app list in start menu.
    - Configure the taskbar.
- Apps settings:
    - Uninstall useless apps and programs.
    - Change optional features and Windows features.
- Accounts settings:
    - (Optional) Add login PIN to avoid typing the password from the lock screen.
- Gaming settings:
    - Under "captures", disable "record what happened".

## Make Windows more Streaming/Presentation Friendly (Windows 10)

- Disable pointless or interrupting applications.
- Disable sleeping:
    1. Go to the power settings (search for it).
    1. Set the sleep timer and display off timer to "never".
- Disable Windows sounds:
    1. Go to sound settings (e.g. left click the taskbar icon).
    1. Go to the "sounds" tab.
    1. Change to "no sounds".
- Disable UAC desktop dimming (e.g. when installing stuff):
    1. Open the UAC settings (search "UAC").
    1. Change to "notify me only when [...] *(do not dim my desktop)*".
- Disable automatic Windows updates:
    1. Run `gpedit.msc`.
    1. Navigate to "Computer Configuration > Administrative Templates > Windows Compoents > Windows Update > Manage end user experience > Configure Automatic Updates".
    1. Enable it and set it to "Notify for fownload and auto install" (notify but don't auto install). Press "OK" and exit.
    1. Open a command prompt and run `gpupdate /force` to apply.
- (Optional) Prevent the mouse from moving into the output display:
    1. Go to the display settings (search or right click the desktop).
    1. Move the output display to the upper right or left corner of the other displays.
    1. Verify that you can't move the mouse into it through the corner.
    1. If you sometimes need to access the display by mouse, offset the cornerign a little to leave a little gap to let the mouse through.
- Disable the task view shortcut (zooms out all windows):
    1. **TODO** How? Disable the shortcut?
- Always keep the presentation window on top:
    1. Install [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/) (official Windows software).
    1. Use the ["Always On Top"](https://learn.microsoft.com/en-us/windows/powertoys/always-on-top) feature, by pressing `Win+Ctrl+T` when the window is active.

## Windows Subsystem for Linux (WSL)

### Setup

More info: [Windows Subsystem for Linux Installation Guide for Windows 10 (Microsoft Docs)](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1. Prerequisites:
    - Intel VT-x or AMD SVM must be enabled in the BIOS settings. Check that the "Virtualization" field in the Task Manager CPU page says "Enabled" afterwards.
    - Hyper-V is not required.
1. Allow using VirtualBox and WSL on the same PC:
    1. Disable hypervisor launch (admin terminal): `bcdedit /set hypervisorlaunchtype off`
    1. Disable "Hyper-V" and "Windows Sandbox" in the Windows Features.
    1. **TODO**: Disable "Windows Hypervisor Platform" too for VirtualBox hardware virtualization mode to work? Breaks WSL?
1. Install (Ubuntu, the default):
    1. Open the Windows command prompt or PowerShell in admin mode.
    1. Start installer: `wsl --install`
    1. Reboot (if and when requested).
    1. Wait for the terminal window to open and the installation to finish.
    1. Enter your new Linux username and password.
1. Enable automatic kernel upgrades:
    1. Go to "Windows updates", "advanced options" and enable "Receive updates for other Microsoft products when you update Windows".
1. Install a distro like Ubuntu from the Microsoft Store app.
    1. Make sure it's using WSL 2, see usage.

### Usage

- Show status: `wsl --status`
- Show VMs: `wsl -l -v`
- Change WSL version for VM: `wsl --set-version <vm> <version>`
- Restart: `wsl --shutdown` and ???
- Update kernel: `wsl --update`

### Docker Desktop

- Recommends using the WSL 2 backend.
- WSL backend notes: [Docker Desktop WSL 2 backend (Docker Docs)](https://docs.docker.com/desktop/windows/wsl/)
- See the NVIDIA notes for NVIDIA Container Toolkit notes.
    - Side note: I gave up on getting it working ... Why would I use Windows for CUDA stuff anyways.

### NVIDIA CUDA

- User guide: [CUDA on WSL User Guide (NVIDIA Docs)](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
- Announcement blog post: [Announcing CUDA on Windows Subsystem for Linux 2 (NVIDIA Developer Blog)](https://developer.nvidia.com/blog/announcing-cuda-on-windows-subsystem-for-linux-2/)
- Using the Windows Insiders Program may be necessary.
- CUDA on WSL drivers: [NVIDIA Drivers for CUDA on WSL, including DirectML Support(NVIDIA Developer)](https://developer.nvidia.com/cuda/wsl/download)

### Troubleshooting

**Time in containers is wrong when using WSL backend**:

Restart WSL every time it happens. It's a known bug still not fixed.

{% include footer.md %}
