# 🛠️ Troubleshooting Sysprep and WIMMount Issues

This guide walks through resolving Sysprep failures and WIMMount driver issues, including common error codes, registry repair, and app removals that may interfere with the process.


## 🧹 Sysprep Preparation Steps

### 🔐 Disable BitLocker

```powershell
manage-bde -off C:
```

### 🔍 Check BitLocker Status

```powershell
manage-bde -status
```

### Get BitLocker Key
```
manage-bde -protectors -get C:
``` 

### Enable BitLocker
```
manage-bde -on C:
```
---

## Pause Windows Updates and Reboot Device

## 🧼 Remove Appx Packages (Common Sysprep Blockers)

> You can identify blocking packages by checking the `sysprep` log file in:
> ```
> C:\Windows\System32\Sysprep\Panther\setuperr.log
> ```

### Remove OneDrive Sync

```powershell
Get-AppxPackage Microsoft.OneDriveSync | Remove-AppxPackage
```

### Remove WebExperience Pack

```powershell
Get-AppxPackage MicrosoftWindows.Client.Webexperience | Remove-AppxPackage
```
---

## ❗ Common Error

- **Error Code 1243**  
  > *"The specified service does not exist."*

This typically indicates a missing `WIMMount` driver or registry corruption.

---

## 🧹 Remove Copilot (If Causing Sysprep Issues)

### Current User

```powershell
Get-AppxPackage -Name Microsoft.Copilot | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.bingsearch | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.OneDriveSync | Remove-AppxPackage
```

### All Users

```powershell
Get-AppxPackage -AllUsers *Microsoft.Copilot* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.bingsearch* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.OneDriveSync* | Remove-AppxPackage -AllUsers
```

### Remove Provisioned Copilot Package

```powershell
Get-AppxProvisionedPackage -Online |
  Where-Object DisplayName -like "*Microsoft.Copilot*" |
  Remove-AppxProvisionedPackage -Online
```

---
## 🧹 Remove WebExperience (Provisioned and Installed)

```powershell
Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage -AllUsers

Get-AppxProvisionedPackage -Online |
  Where-Object DisplayName -like "*WebExperience*" |
  Remove-AppxProvisionedPackage -Online
```

---

## 🔍 Check for WIMMount Registry Key

Open `regedit` and confirm the following path exists:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WIMMount
```

If missing, you can manually recreate it using this `.reg` snippet:

### 🧾 WIMMount Registry Configuration

```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WIMMount]
"DebugFlags"=dword:00000000
"Description"="@%SystemRoot%\\system32\\drivers\\wimmount.sys,-102"
"DisplayName"="@%SystemRoot%\\system32\\drivers\\wimmount.sys,-101"
"ErrorControl"=dword:00000001
"Group"="FSFilter Infrastructure"
"ImagePath"=hex(2):73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,64,00,\
72,00,69,00,76,00,65,00,72,00,73,00,5c,00,77,00,69,00,6d,00,6d,00,6f,00,75,\
00,6e,00,74,00,2e,00,73,00,79,00,73,00,00,00
"Start"=dword:00000003
"SupportedFeatures"=dword:00000003
"Tag"=dword:00000001
"Type"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WIMMount\Instances]
"DefaultInstance"="WIMMount"

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WIMMount\Instances\WIMMount]
"Altitude"="180700"
"Flags"=dword:00000000
```

---

## 📁 Check for Driver File

Ensure the following file exists:

```
C:\Windows\System32\drivers\wimmount.sys
```
---

## 🛑 Disable Reserved Storage

```powershell
DISM.exe /Online /Set-ReservedStorageState /State:Disabled
```

### Check Reserved Storage State

```powershell
Get-WindowsReservedStorageState
```

📚 More Info:  
[Reserved Storage Details - ElevenForum](https://www.elevenforum.com/t/enable-or-disable-reserved-storage-in-windows-11.21389/)

---

## 🔄 Clear Windows Update Cache

```cmd
net stop wuauserv
net stop bits
del /s /q C:\Windows\SoftwareDistribution\*
net start wuauserv
net start bits
```
---
