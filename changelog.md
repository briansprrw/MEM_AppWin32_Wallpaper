# Changelog for Install_Wallpaper.ps1 Script

## Original Version
- The original script was designed to:
  - Copy wallpaper images from a `Wallpapers` folder to a specified subdirectory within the Windows wallpaper directory.
  - Apply the wallpaper using registry settings.
  - Support only JPG files.
  - Basic logging of actions.
  - Handle version tracking through an environment variable (`WallpaperThemeVersion`).
  
---

## Changes Made to the Script

### 1. **Multiple Image Format Support**
   - Added support for JPG, PNG, and BMP formats. The script now searches for these image formats and applies the first found wallpaper.

### 2. **Dynamic Theme Name**
   - The script dynamically determines the theme name based on the folder name in which the script is executed.
   - This improves flexibility and allows for easy deployment without hardcoding the theme name.

### 3. **Logging Enhancements**
   - Added detailed logging that records all key operations, including:
     - Starting the script.
     - Finding wallpaper files.
     - Copying wallpaper files.
     - Applying wallpaper.
     - Uninstalling wallpaper.
   - All logs are saved to `log.txt` for better traceability.

### 4. **Error Handling Improvements**
   - Improved error handling with meaningful error messages and logging.
   - The script now logs detailed errors when an issue occurs (e.g., copying wallpaper, removing theme directory).

### 5. **Uninstall Functionality**
   - Introduced the `Uninstall` parameter to allow for wallpaper and theme removal.
   - The `Uninstall` command now removes the wallpaper, theme subdirectory, and resets the environment variable `WallpaperThemeVersion`.
   - This makes the script flexible enough to handle both deployment and removal of wallpaper through Intune.
   - Example Uninstall command:
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File "Install_Wallpaper.ps1" -Uninstall
     ```

### 6. **Version Tracking**
   - The environment variable `WallpaperThemeVersion` is used to track the deployment version.
   - The version is passed through the `-version` parameter, which defaults to `1.0` but can be updated as needed for new deployments.
   - This environment variable is reset upon uninstallation.

### 7. **Registry-based Wallpaper Application**
   - Registry settings are used to apply the wallpaper and ensure it is immediately reflected on the user's desktop.
   - The registry keys for wallpaper style and tiling are configured for non-interactive deployment.

### 8. **PowerShell Parameters**
   - The script now supports the following parameters:
     - **-version**: Allows specifying a deployment version.
     - **-Uninstall**: When specified, triggers the wallpaper removal process.

---

## Future Improvements
- Expand error handling based on different environments and test feedback.
- Add additional logging for network-related actions (if applicable).
