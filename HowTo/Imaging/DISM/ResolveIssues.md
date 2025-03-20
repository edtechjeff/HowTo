# If Error Message you get the following
- Error: 1243
  - The specified service does not exist.

# Check to see if this registry is there

'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WIMMount'

# The Registry Key
Windows Registry Editor Version 5.00
---

```
{

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
"Flags"=dword:

}
```

# Check to see if the following File is there
- c:\windows\system32\drivers\wimmount.sys” exists on the computer

# Sysprep Issues

## Disable Bitlocker
```
manage-bde -off C:
```
## Check Status of Bitlocker
```
manage-bde -status
```
# Remove AppxPackage
## 'Will remove remove OneDriveSync Package. You can get the package name from the Sysprep LOG' 
```
get-AppxPackage Microsoft.OneDriveSync | Remove-AppxPackage
```

## 'Will remove remove WebExperienc Package. You can get the package name from the Sysprep LOG' 
```
get-AppxPackage MicrosoftWindows.Client.Webexperience | Remove-AppxPackage
```

## Disable Reserved Storage State
```
DISM.exe /Online /Set-ReservedStorageState /State:Disabled
```

## Get Reserved Storage State
```
Get-WindowsReservedStorageState
```

## Remove Update Cache on Local Machine
```
net stop wuauserv
net stop bits
del /s /q C:\Windows\SoftwareDistribution\*
net start wuauserv
net start bits
```
## Info about Storage State
https://www.elevenforum.com/t/enable-or-disable-reserved-storage-in-windows-11.21389/

