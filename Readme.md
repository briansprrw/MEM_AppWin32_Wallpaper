
# Deploying Wallpaper Management with Microsoft Intune

Instructions on how to package, upload, and configure a wallpaper management script as a Win32 app in Microsoft Intune. This script not only copies wallpaper images but also configures the wallpaper for the user and tracks the deployment version through an environment variable.

## Prerequisites

- Microsoft Intune subscription
- Windows 10 or Windows 11 devices enrolled in Intune
- Administrative privileges on the Intune portal
- PowerShell scripting knowledge

## Packaging the Script

1. Ensure the `Install_Wallpaper.ps1` PowerShell script is correctly prepared. The script will:
   - Copy the wallpaper images to the `%SystemRoot%\Web\Wallpaper` directory.
   - Apply the wallpaper using registry settings.
   - Set an environment variable for version tracking (`WallpaperThemeVersion`).
   - Log key actions to `log.txt`.
2. Download the [Microsoft Win32 Content Prep Tool](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool).
3. Run the `IntuneWinAppUtil.exe` and follow the prompts to package your script and related files (e.g., wallpapers) into an `.intunewin` file.

## Uploading to Intune

1. Log in to the Microsoft Endpoint Manager admin center.
2. Navigate to `Apps` > `Windows`.
3. Click on `+Add` and select `Windows app (Win32)` from the app type dropdown.
4. Upload the packaged `.intunewin` file.

## Configuring the App

### General Information

- **Name**: Wallpaper Management
- **Description**: This app configures the desktop wallpaper for Intune-managed devices and tracks versioning through an environment variable.
- **Publisher**: (Your organization or personal name)

### Program

- **Install command**: 
  ```powershell
  powershell.exe -executionpolicy bypass -file "Install_Wallpaper.ps1" -version "1.1"
  ```
- **Uninstall command**: N/A (Uninstall functionality not included)
- **Install behavior**: System

### Detection Rules

- **Rule type**: Registry
- **Key path**: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`
- **Value name**: `WallpaperThemeVersion`
- **Detection method**: Value equals
- **Value**: `1.0` (or the version you are deploying)

### Requirements

- **Operating system architecture**: Select based on your target devices
- **Minimum operating system**: Windows 10 or later

### Return Codes

- Use the standard return codes.

### Assignments

- Assign the app to the relevant user or device groups as per your organizational policies.

## Troubleshooting

- Check the Intune management portal for deployment status.
- Verify the wallpaper has been applied on a test device.
- Review the `log.txt` file created in the script’s execution directory for detailed logging of the deployment process.

## Additional Resources

- For more insights on deploying wallpapers as a Win32 app, refer to:
  - [Wallpaper and Lockscreen with Intune and Business Premium | scloud](https://scloud.work/wallpaper-lockscreen-intune-business/)
  - [Manage Desktop Wallpaper with Microsoft Intune - MSEndpointMgr](https://msendpointmgr.com/2021/02/02/manage-desktop-wallpaper-with-microsoft-intune/)
