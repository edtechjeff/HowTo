---
title: "Post Deployment using SetupComplete.cmd"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Title: Post Deployment using SetupComplete.cmd

## Purpose: The following is a method to deploy applications or set settings or basically anything that you can script

## Background of SetupComplete.cmd


SetupComplete.cmd is a custom script used during the Windows setup process to automate tasks after installation. It is executed immediately after the user sees the desktop but before any user logs in. This script is particularly useful for post-deployment configurations, such as installing applications or modifying system settings.

***Cut to the Chase:*** If you can script it you can run it with SetupComplete.cmd

## Key Features and Usage

1.  Execution Timing: The script runs after Windows installation is complete but before the logon screen appears. It is located in the %WINDIR%\Setup\Scripts\ directory. If found, Windows Setup automatically executes it.

2.  Permissions: It runs with local system permissions, allowing it to perform administrative tasks without user intervention.

3.  Common Use Cases: Automating application installations. Removing or modifying default settings (e.g., disabling OneDrive setup). Running custom scripts for system configurations.

4.  Behavior: The script runs only once during the setup process. It does not validate exit codes or error levels, so any errors in the script will not halt the setup process.

5.  Restrictions: Rebooting the system within SetupComplete.cmd (e.g., using shutdown -r) is not recommended, as it can leave the system in an unstable state. If the computer joins a domain during installation, Group Policy is applied only after the script finishes execution to avoid conflicts.

## Process

1. Mount the image
2. Open up the mounted image
3. Browse to the following location
    - \Path\To\Mounted\Image\Windows\Setup
4. Create Sub folder called
```
Scripts
```
5. Create a file called SetupComplete.cmd
6. In the file put in what ever commands you want.

## Example SetupComplete.cmd

***Note:***In this example we are going to install Chrome, Notepad ++ and 7zip

```bash
@echo off
REM ======================================================
REM SetupComplete.cmd - runs after Windows setup finishes
REM Runs in SYSTEM context before first logon
REM ======================================================

:: Log start
echo %DATE% %TIME% - SetupComplete starting >> C:\Windows\Temp\SetupComplete.log

REM === Install Google Chrome ===
start /wait msiexec /i "C:\Windows\Setup\Scripts\GoogleChromeStandaloneEnterprise64.msi" /qn /norestart

REM === Install 7-Zip ===
start /wait C:\Windows\Setup\Scripts\7z2501-x64.exe /S

REM === Install Notepad++ ===
start /wait C:\Windows\Setup\Scripts\npp.8.8.5.Installer.x64.exe /S

:: Log end
echo %DATE% %TIME% - SetupComplete finished >> C:\Windows\Temp\SetupComplete.log
exit /b 0
```

7. Copy all MSI's and Exe to c:\windows\setup\scripts 
8. Commit the image and test your deployment

## Basic SetupComplete.cmd

```bash
@echo off
REM ======================================================
REM SetupComplete.cmd - runs after Windows setup finishes
REM Runs in SYSTEM context before first logon
REM ======================================================

:: Log start
echo %DATE% %TIME% - SetupComplete starting >> C:\Windows\Temp\SetupComplete.log

REM == Put anything after this block to run as an install

:: Log end
echo %DATE% %TIME% - SetupComplete finished >> C:\Windows\Temp\SetupComplete.log
exit /b 0
```