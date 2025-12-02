# Setting Up Solarwinds TFTP

## Setup Struture
C:\TFTP-Root\
    ├── EFI\
    │     ├── Boot\
    │     └── Microsoft\
    │           └── Boot\
    ├── boot\
    └── sources\

## Commands to create structure
```powershell
mkdir c:\TFTP-Root\EFI
mkdir c:\TFTP-Root\boot
mkdir c:\TFTP-Root\sources
mkdir c:\TFTP-Root\EFI\Boot
mkdir c:\TFTP-Root\EFI\Microsoft\Boot
```
## Configure DHCP 
- Option 66
    - 192.168.x.x (IP of your PXE Server)
- Option 67
    - EFI\Boot\bootx64.efi

## Install ADK
- Windows ADK
- Windows PE Add-on

## Build Custom WinPE Boot Image
```
copype amd64 C:\WinPE
```

## Mount WinPE to modify it
```
dism /mount-wim /wimfile:C:\WinPE\media\sources\boot.wim /index:1 /mountdir:C:\WinPE\mount
```

## Add optional components
```powershell
Dism /Image:C:\WinPE\mount /Add-Package /PackagePath:"%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Image:C:\WinPE\mount /Add-Package /PackagePath:"%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Image:C:\WinPE\mount /Add-Package /PackagePath:"%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Image:C:\WinPE\mount /Add-Package /PackagePath:"%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WDS-Tools.cab"

```
## Add Drivers
- Dell WinPE
- Intel Rapid Raid Controller Driver

## Add custom starnet.cmd
```
notepad C:\WinPE\mount\Windows\System32\startnet.cmd
```

### Example Starnet
```
wpeinit

@echo off
echo Initializing network...
ipconfig /renew

:: Map deployment share
net use Z: \\192.168.x.x\Deployment password /user:domain\user

:: Run your deployment script
Z:\Deploy\start.cmd
```

## Cmmit and unmount
```
dism /unmount-wim /mountdir:C:\WinPE\mount /commit
```

## Copy custom WinPE boot.wim into TFTP
```
copy C:\WinPE\media\sources\boot.wim C:\TFTP-Root\sources\boot.wim /Y
```

## Extract all EFI boot files from the custom boot.wim
```
dism /mount-wim /wimfile:C:\TFTP-Root\sources\boot.wim /index:1 /mountdir:C:\mount
```

## Copy PXE EFI boot environment
```
xcopy C:\mount\Windows\Boot\EFI\* C:\TFTP-Root\EFI\Microsoft\Boot\ /E /Y /I
```

## Unmount
```
dism /unmount-wim /mountdir:C:\mount /discard
```

## Mount windows ISO
### Copy files from ISO 
```
\EFI\Boot\bootx64.efi → C:\TFTP-Root\EFI\Boot\
```

## Build correct BCD for PXE Boot
### Create Store
```
bcdedit /createstore C:\TFTP-Root\boot\BCD
```

### Create boot manager
```
bcdedit /store C:\TFTP-Root\boot\BCD /create {bootmgr} /d "Windows Boot Manager"
bcdedit /store C:\TFTP-Root\boot\BCD /set {bootmgr} timeout 1
```

### create RAM disk options
```
bcdedit /store C:\TFTP-Root\boot\BCD /create {ramdiskoptions} /d "Ramdisk Options"
bcdedit /store C:\TFTP-Root\boot\BCD /set {ramdiskoptions} ramdisksdidevice boot
bcdedit /store C:\TFTP-Root\boot\BCD /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi
```

### Create boot loader entry
```
for /f "tokens=2 delims={}" %G in ('bcdedit /store C:\TFTP-Root\boot\BCD /create /d "WinPE" /application osloader') do set GUID={%G}
```

### Configure loader
```
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% device ramdisk=[boot]\sources\boot.wim,{ramdiskoptions}
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% osdevice ramdisk=[boot]\sources\boot.wim,{ramdiskoptions}
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% path \Windows\System32\Boot\winload.efi
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% systemroot \Windows
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% winpe yes
bcdedit /store C:\TFTP-Root\boot\BCD /set %GUID% detecthal yes
bcdedit /store C:\TFTP-Root\boot\BCD /set {bootmgr} default %GUID%
```

## Copy boot.sid
```
copy C:\WinPE\media\boot\boot.sdi C:\TFTP-Root\boot\boot.sdi /Y
```

## Start Solarwinds TFTP

## 




