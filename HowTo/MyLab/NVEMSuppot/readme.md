---
title: Lab Setup
author: Jeff Downs
date: January 5, 2026
---

# Steps to get NVME running native on Server 2025

## BIOS prerequisites (no commands, but required)
### Goal: NVMe must be exposed natively (not behind Intel RAID/VMD).
- Set storage mode to AHCI
- Disable Intel VMD / NVMe RAID (if present)
- Install OS on a separate SATA SSD (your “F10 D5”)
- NVMe will be used for Storage Spaces

### Expected after install:
- Device Manager → Storage controllers shows Standard NVM Express Controller

## Confirm the NVMe driver stack is correct (pre-flight checks)
### Confirm NVMe controller is using Microsoft inbox NVMe driver

```powershell
Get-PnpDevice -Class "SCSIAdapter" |
Where-Object FriendlyName -like "*NVM*" |
Get-PnpDeviceProperty DEVPKEY_Device_DriverInfPath
```

## Confirm the NVMe disk is poolable
```powershell
Get-PhysicalDisk | Select FriendlyName, MediaType, CanPool
```
### Expected: your NVMe shows CanPool : True

## Enable Native NVMe (registry) + reboot
```powershell
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\stornvme\Parameters" -Force | Out-Null

New-ItemProperty `
  -Path "HKLM:\SYSTEM\CurrentControlSet\Services\stornvme\Parameters" `
  -Name "NativeNVMeEnabled" `
  -PropertyType DWord `
  -Value 1 `
  -Force

Restart-Computer
```

## Verify after reboot
```powershell
Get-ItemProperty `
  -Path "HKLM:\SYSTEM\CurrentControlSet\Services\stornvme\Parameters" `
  -Name NativeNVMeEnabled
```
### Expected: NativeNVMeEnabled : 1

## Re-check the driver binding (should still be stornvme.inf):
```powershell
Get-PnpDevice -Class "SCSIAdapter" |
Where-Object FriendlyName -like "*NVM*" |
Get-PnpDeviceProperty DEVPKEY_Device_DriverInfPath
```
