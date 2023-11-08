# Deploying Wallpaper Management with Microsoft Intune

Instructions on how to package, upload, and configure a wallpaper management script as a Win32 app in Microsoft Intune. The script only copies or deposits a folder with potential wallpaper images. To actually configure the Wallpaper for the user there would also need to be an Intune Configuration Profile wih the setting "Desktop Wallpaper (User)" configured.

Below the instructions on how to package and distribute as Win32 App package.

## Prerequisites

- Microsoft Intune subscription
- Windows 10 or Windows 11 devices enrolled in Intune
- Administrative privileges on the Intune portal
- PowerShell scripting knowledge

## Packaging the Script

1. Prepare your PowerShell script that copies the desired wallpaper images to the `%SystemRoot%\Web\Wallpaper` directory.
2. Ensure the script includes parameters for install and uninstall actions.
3. Download the [Microsoft Win32 Content Prep Tool](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool).
4. Run the `IntuneWinAppUtil.exe` and follow the prompts to package your script and related files into an `.intunewin` file.

## Uploading to Intune

1. Log in to the Microsoft Endpoint Manager admin center.
2. Navigate to `Apps` > `Windows`.
3. Click on `+Add` and select `Windows app (Win32)` from the app type dropdown.
4. Upload the packaged `.intunewin` file.

## Configuring the App

> :warning: **WARNING:** This is an example, modify as needed.

> :memo: **Note:** Example instructions assumes you'll use "Nature" as parameter.


### General Information

- **Name**: Wallpaper Management
- **Description**: This app configures the desktop wallpaper for Intune-managed devices.
- **Publisher**: [You might want to put your name here?]

### Program

- **Install command**: `powershell.exe -executionpolicy bypass -file ".\Install_Wallpaper.ps1" -theme "Nature"`
- **Uninstall command**: `powershell.exe -executionpolicy bypass -file ".\Install_Wallpaper.ps1" -theme "Nature" -Uninstall`
- **Install behavior**: System

### Detection Rules

- **Rule type**: File
- **Path**: `%SystemRoot%\Web\Wallpaper`
- **File or folder**: Nature
- **Detection method**: File or folder exists

### Requirements

- **Operating system architecture**: Select as per your target devices
- **Minimum operating system**: Windows 10 or later

### Return Codes

- The standard return codes.

### Assignments
- Assign the app to the relevant user or device groups as per your organizational policies.



## Troubleshooting

- Check the Intune management portal for deployment status.
- Verify the wallpaper has been applied on a test device.
- Consult the script logs if available.

## Additional Resources

- For a deeper understanding of deploying wallpapers as a Win32 app and the rationale behind the script's file placement, refer to the following articles:
  - [Wallpaper and Lockscreen with Intune and Business Premium | scloud](https://scloud.work/wallpaper-lockscreen-intune-business/)
  - [Manage Desktop Wallpaper with Microsoft Intune - MSEndpointMgr](https://msendpointmgr.com/2021/02/02/manage-desktop-wallpaper-with-microsoft-intune/)

