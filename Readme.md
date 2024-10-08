
# Deploying Wallpaper Management with Microsoft Intune

This guide provides instructions on packaging, uploading, and configuring the wallpaper management script as a Win32 app using Microsoft Intune. The script supports both installation and uninstallation of wallpapers and tracks deployment versions via an environment variable.

## Prerequisites

- Microsoft Intune subscription
- Windows 10 or Windows 11 devices enrolled in Intune
- Administrative privileges in the Intune portal
- PowerShell scripting knowledge

## Packaging the Script

1. Prepare the `Install_Wallpaper.ps1` PowerShell script. The script performs the following tasks:
   - Installs or uninstalls wallpapers in the `%SystemRoot%\Web\Wallpaper` directory.
   - Applies or removes the wallpaper using registry settings.
   - Sets or removes an environment variable for version tracking (`WallpaperThemeVersion`).
   - Logs operations in a `log.txt` file.
2. Download the [Microsoft Win32 Content Prep Tool](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool).
3. Run the `IntuneWinAppUtil.exe` to package the script and related files (e.g., wallpapers) into an `.intunewin` file.

## Uploading to Intune

1. Sign in to the Microsoft Endpoint Manager admin center.
2. Navigate to `Apps` > `Windows`.
3. Select `+Add` and choose `Windows app (Win32)`.
4. Upload the `.intunewin` file.

## Configuring the App

### General Information

- **Name**: Wallpaper Management
- **Description**: This app installs or uninstalls wallpapers on Intune-managed devices and tracks versioning via an environment variable.
- **Publisher**: (Your organization or name)

### Program

- **Install command**: 
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File "Install_Wallpaper.ps1" -version "1.1"
  ```
- **Uninstall command**: 
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File "Install_Wallpaper.ps1" -Uninstall
  ```
- **Install behavior**: System

### Detection Rules

- **Rule type**: Registry
- **Key path**: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`
- **Value name**: `WallpaperThemeVersion`
- **Detection method**: Value equals
- **Value**: `1.0` (or the current version you are deploying)

### Requirements

- **Operating system architecture**: Select based on target devices
- **Minimum operating system**: Windows 10 or later

### Return Codes

- Use standard return codes.

### Assignments

- Assign the app to relevant users or device groups.

## Troubleshooting

- Check the Intune management portal for deployment status.
- Review the `log.txt` file for detailed logs.
- Confirm the wallpaper is applied or removed on the test device.

## Additional Resources

- [Wallpaper and Lockscreen with Intune and Business Premium | scloud](https://scloud.work/wallpaper-lockscreen-intune-business/)
- [Manage Desktop Wallpaper with Microsoft Intune - MSEndpointMgr](https://msendpointmgr.com/2021/02/02/manage-desktop-wallpaper-with-microsoft-intune/)
