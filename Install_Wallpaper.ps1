<#
.SYNOPSIS
This script deploys a wallpaper image and theme to a specified subdirectory
within the Windows wallpaper directory, sets an environment variable for
version control, and automatically applies the theme using the registry.

.DESCRIPTION
This PowerShell script is designed to be deployed via Intune as a Win32
application. It automates the process of copying a wallpaper image from a
"Wallpapers" folder (located in the same directory as the script) to a
subdirectory in the system's wallpaper directory and applies the wallpaper by
modifying the necessary registry settings.

The script also sets an environment variable for version tracking. It looks for
common image file types (JPG, PNG, BMP) and uses the first available image if
"Wallpaper.jpg" is not found. The theme name is determined dynamically based on
the folder from which the script is being executed. Additionally, all operations
are logged into a `log.txt` file for easy troubleshooting.

.PARAMETER version
Specifies the version of the wallpaper deployment, which will be stored in an
environment variable for tracking. Defaults to `1.0`.

.EXAMPLE
powershell.exe -ExecutionPolicy Bypass -File "Install_Wallpaper.ps1" -version "1.1"

This example deploys the wallpaper using the dynamically determined theme name
and sets the version environment variable to "1.1."

.NOTES
- The script looks for images in the following formats: JPG, PNG, BMP. If
  "Wallpaper.jpg" is not found, it will select the first available image.
- The environment variable `WallpaperThemeVersion` is set to the provided
  version for tracking.
- The theme name is dynamically determined based on the folder name of the
  script's execution.
- All major actions are logged in a `log.txt` file located in the script's
  execution directory.

.INTUNE USAGE
- Install command:
    powershell.exe -ExecutionPolicy Bypass -File "Install_Wallpaper.ps1" -version "1.1"
  
- Detection rules:
    Rule type: Registry
    Key path: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    Value name: WallpaperThemeVersion
    Detection method: Value equals
    Value: 1.0 (or set to the version you are deploying)
    Associated with a 32-bit app on 64-bit clients: Unchecked
#>

# Define parameters
param (
    [Parameter(Mandatory=$true)]
    [string]$version = "1.0"    # Default version, can be updated as needed
)

# Define log file path
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath "log.txt"

# Function to write to the log file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
}

# Function to dynamically determine the theme name based on the script location
function Get-ThemeName {
    $scriptPath = $PSScriptRoot
    $folderName = Split-Path -Leaf $scriptPath
    Write-Log "Dynamically determined theme name: $folderName"
    return $folderName
}

# Function to set an environment variable for version control
function Set-EnvironmentVariable {
    param (
        [string]$variableName, # Name of the environment variable
        [string]$value         # Value to set for the environment variable
    )

    try {
        [Environment]::SetEnvironmentVariable($variableName, $value, [EnvironmentVariableTarget]::Machine)
        Write-Host "Environment variable '$variableName' set to '$value'."
        Write-Log "Environment variable '$variableName' set to '$value'."
    } catch {
        Write-Log "Failed to set environment variable: $_"
        Write-Error "Failed to set environment variable: $_"
        exit 1
    }
}

# Function to find the first available image in the Wallpapers folder
function Find-Wallpaper {
    $supportedFormats = @("*.jpg", "*.png", "*.bmp") # Supported file formats
    foreach ($format in $supportedFormats) {
        $image = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Wallpapers") -Filter $format -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($image) {
            Write-Log "Found wallpaper file: $($image.FullName)"
            return $image.FullName
        }
    }
    Write-Log "No supported wallpaper files found (JPG, PNG, BMP)."
    Write-Error "No supported wallpaper files found (JPG, PNG, BMP)."
    exit 1
}

# Function to copy the wallpaper image to the theme directory
function Copy-Wallpaper {
    param (
        [string]$theme,      # Name of the theme subdirectory
        [string]$sourcePath  # Full path to the source image file
    )

    # Define the destination path
    $destPath = Join-Path -Path $env:SystemRoot -ChildPath "Web\Wallpaper\$theme\$(Split-Path $sourcePath -Leaf)"

    # Check if the destination directory exists, and create it if it doesn't
    if (-not (Test-Path -Path (Split-Path $destPath -Parent))) {
        Write-Log "Creating theme directory '$($env:SystemRoot)\Web\Wallpaper\$theme'."
        New-Item -Path (Split-Path $destPath -Parent) -ItemType Directory | Out-Null
    }

    # Copy the wallpaper to the destination folder
    try {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Log "Wallpaper copied successfully to '$destPath'."
    } catch {
        Write-Log "An error occurred while copying the wallpaper: $_"
        Write-Error "An error occurred while copying the wallpaper: $_"
        exit 1
    }

    return $destPath
}

# Function to apply the wallpaper by setting the necessary registry keys
function Apply-Wallpaper {
    param (
        [string]$wallpaperPath # Full path to the wallpaper image
    )

    try {
        # Set registry keys to apply the wallpaper
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallpaperPath
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" # Fit style
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0"   # No tiling
        # Refresh the desktop to apply changes
        rundll32.exe user32.dll,UpdatePerUserSystemParameters ,1 ,True
        Write-Log "Wallpaper applied successfully via registry."
    } catch {
        Write-Log "Failed to apply the wallpaper via registry: $_"
        Write-Error "Failed to apply the wallpaper via registry: $_"
        exit 1
    }
}

# Main script execution
try {
    # Start logging
    Write-Log "Starting wallpaper deployment script."

    # Dynamically determine the theme name
    $theme = Get-ThemeName

    # Find the first available wallpaper image
    $wallpaperPath = Find-Wallpaper

    # Copy the wallpaper to the specified theme directory
    $copiedWallpaperPath = Copy-Wallpaper -theme $theme -sourcePath $wallpaperPath

    # Apply the wallpaper using registry settings
    Apply-Wallpaper -wallpaperPath $copiedWallpaperPath

    # Set the environment variable to indicate the version of the wallpaper deployment
    Set-EnvironmentVariable -variableName "WallpaperThemeVersion" -value $version

    Write-Log "Script completed successfully."

    # Exit with code 0 (success)
    exit 0
} catch {
    Write-Log "An error occurred: $_"
    Write-Error $_.Exception.Message
    exit 1
}

# Function to remove the wallpaper and theme directory
function Remove-Wallpaper {
    param (
        [string]$theme # Name of the theme subdirectory
    )

    # Define the destination path
    $destPath = Join-Path -Path $env.SystemRoot -ChildPath "Web\Wallpaper\$theme"

    # Check if the destination directory exists
    if (Test-Path -Path $destPath) {
        try {
            Remove-Item -Path $destPath -Recurse -Force
            Write-Log "Theme '$theme' and all associated wallpapers have been removed."
        } catch {
            Write-Log "An error occurred while removing the theme: $_"
            Write-Error "An error occurred while removing the theme: $_"
            exit 1
        }
    } else {
        Write-Log "Theme '$theme' does not exist or has already been removed."
    }
}

# Main script execution (modified to handle Uninstall)
try {
    Write-Log "Starting wallpaper deployment script."

    # Dynamically determine the theme name
    $theme = Get-ThemeName

    if ($Uninstall) {
        # Uninstall: Remove the wallpaper and associated theme
        Remove-Wallpaper -theme $theme
        Set-EnvironmentVariable -variableName "WallpaperThemeVersion" -value ""
        Write-Log "Uninstall completed."
    } else {
        # Install: Find and copy the wallpaper, apply it, and set the version environment variable
        $wallpaperPath = Find-Wallpaper
        $copiedWallpaperPath = Copy-Wallpaper -theme $theme -sourcePath $wallpaperPath
        Apply-Wallpaper -wallpaperPath $copiedWallpaperPath
        Set-EnvironmentVariable -variableName "WallpaperThemeVersion" -value $version
        Write-Log "Install completed successfully."
    }

    # Exit with success
    exit 0
} catch {
    Write-Log "An error occurred: $_"
    Write-Error $_.Exception.Message
    exit 1
}
