# Example SetupComplete.cmd

```
@echo off
REM ======================================================
REM SetupComplete.cmd - runs after Windows setup finishes
REM Runs in SYSTEM context before first logon
REM ======================================================

:: Log start
echo %DATE% %TIME% - SetupComplete starting >> C:\Windows\Temp\SetupComplete.log

:: === Disable Consumer Experience via registry ===
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
echo %DATE% %TIME% - Consumer Experience disabled >> C:\Windows\Temp\SetupComplete.log

:: Block Store auto-downloads
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f

:: Disable Game DVR / Game Bar
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

:: Remove provisioned Xbox + Solitaire apps
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Xbox*' | Remove-AppxProvisionedPackage -Online; ^
   Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.MicrosoftSolitaireCollection' | Remove-AppxProvisionedPackage -Online; ^
   Get-AppxPackage -AllUsers Microsoft.Xbox* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; ^
   Get-AppxPackage -AllUsers *MicrosoftSolitaireCollection* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue"

:: === Remove provisioned bloatware apps ===
:: Call PowerShell inline to remove from provisioned packages
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$patterns = @(
    'Microsoft.Bing*',
    'Microsoft.MicrosoftOfficeHub*',
    'Microsoft.Office.OneNote*',
    'Microsoft.SkypeApp*',
    'Microsoft.Wallet*',
    'Microsoft.MicrosoftSolitaireCollection*',
    'Microsoft.People*',
    'Microsoft.WindowsMaps*',
    'Microsoft.YourPhone*',
    'Microsoft.Zune*',
    'Microsoft.Xbox*'
  );
  $prov = Get-AppxProvisionedPackage -Online;
  foreach ($pat in $patterns) {
    $prov | Where-Object { $_.DisplayName -like $pat } | ForEach-Object {
      Write-Output ('Removing provisioned: ' + $_.DisplayName)
      Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
  }
  $apps = Get-AppxPackage -AllUsers;
  foreach ($pat in $patterns) {
    $apps | Where-Object { $_.Name -like $pat } | ForEach-Object {
      Write-Output ('Removing installed: ' + $_.Name)
      Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
  }" >> C:\Windows\Temp\SetupComplete.log 2>&1

:: Log end
echo %DATE% %TIME% - SetupComplete finished >> C:\Windows\Temp\SetupComplete.log

exit /b 0
```