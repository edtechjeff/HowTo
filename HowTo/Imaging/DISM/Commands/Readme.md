
# Random DISM Commands Used to Build the Maintenance Task

This document lists common DISM and related commands used in Windows image servicing tasks, including exporting, mounting, injecting drivers, and removing built-in apps.

---

## Start Network on WinPE Booted Machine
```
startnet.cmd
```

## Get List of Indexes in Install WIM
```powershell
powershell Get-WindowsImage -ImagePath "C:\Installs\Windows11\23H2\install.wim"
```

## Export Enterprise Image
```powershell
Dism /export-image /sourceimagefile:C:\Installs\Windows11\23H2\install.wim /sourceindex:3 /destinationimagefile:C:\Images\Images\Enterprise.wim
```

## Export Education Image
```
Dism /export-image /sourceimagefile:C:\Installs\Windows11\23H2\install.wim /sourceindex:1 /destinationimagefile:C:\Images\Images\Education.wim
```

## Export Pro Image
```
Dism /export-image /sourceimagefile:C:\Installs\Windows11\23H2\install.wim /sourceindex:5 /destinationimagefile:C:\Images\Images\Pro.wim
```

---

## Mount Install.WIM
```
Dism /Mount-Image /ImageFile:"C:\images\images\install.wim" /index:3 /MountDir:"C:\mount"
```

## Unmount and Commit Install.WIM
```
Dism /Unmount-Image /MountDir:"C:\mount" /commit
```

## Discard Changes to Install.WIM
```
Dism /Unmount-Image /MountDir:"C:\mount" /discard
```

## Capture Image
```
dism /capture-image /imagefile:z:\images\edtechjeff.wim /capturedir:c:\ /name:"custom image" /Compress:Max
```

## Add Drivers to Mounted WIM
```
DISM /Image:C:\Mount /Add-Driver /Driver:C:\drivers\production\ /recurse /ForceUnsigned
```

## Export Device Drivers
```
dism /online /Export-Driver /Destination:c:\temp
```

## Expand Drivers from CAB File
```
expand "WinPE11.0-Drivers-A05-TPKY4.cab" -f:* F:\Images\Drivers\WinPE
```

## Get Provisioned Appx Packages
```
dism /Image:C:\images\mount /Get-Provisionedappxpackages
```

## Remove Provisioned Appx Packages
(Examples below – versions may vary by Windows edition)

```
dism /image:\images\mount /Remove-Provisionedappxpackage /PackageName:Microsoft.BingNews_4.2.27001.0_neutral_~_8wekyb3d8bbwe
dism /image:\images\mount /Remove-Provisionedappxpackage /PackageName:Microsoft.BingWeather_4.53.33420.0_neutral_~_8wekyb3d8bbwe
...
dism /image:\images\mount /Remove-Provisionedappxpackage /PackageName:Microsoft.XboxSpeechToTextOverlay_1.17.29001.0_neutral_~_8wekyb3d8bbwe
```

---

## Setup Script Notes

- Mirror the system drive with: `sources\$OEM$\$$\Setup\Scripts`
- Reference scripts in `unattend.xml` with: `%SystemDrive%\Windows\Setup\Scripts`

---

## Get Device Model Name
```powershell
(Get-CimInstance -ClassName Win32_ComputerSystem).Model
```
