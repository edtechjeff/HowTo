# Google Drive via WINGET

## Files included are as follows

- Detection script for Intune
- Install script
- Uninstall script

## You can package the Install and Uninstall using the Win32 - [Win32 Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)

## Command to use for the Intune Deployment
- Install command
    - powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
- Uninstall command
    - powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\unInstall.ps1