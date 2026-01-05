---
title: iSCSI Setup
author: Jeff Downs
date: January 5, 2026
---

# My Lab Setup

### Enable All ICMP Firewall Rules
```Powershell
Get-NetFirewallRule | Where-Object DisplayName -like "*ICMP*" | Enable-NetFirewallRule
```

# Steps for SAN using a Windows Server

## Install iSCSI Target role
- On SAN01:
- Server Manager
- Add roles and features → File and Storage Services → File and iSCSI Services → iSCSI Target Server

### Powershell Alternative
```powershell
Install-WindowsFeature FS-iSCSITarget-Server -IncludeManagementTools
```

## Verify
```powershell
Get-WindowsFeature FS-iSCSITarget-Server
```
## Prep storage on SAN01
- In Disk Management:
- Initialize disks (GPT)
- Create NTFS or ReFS volumes
    Example:
    E:\iSCSI\

## Create Folder to store files
```powershell
New-Item -Path "G:\iSCSI" -ItemType Directory -Force
```

***These disks stay local to SAN01. You’ll expose space via VHDX files.***

## Create iSCSI virtual disks (LUNs)
- Server Manager:
- File and Storage Services → iSCSI → Tasks → New iSCSI Virtual Disk
Create:
- Witness disk – e.g., 1–5 GB
- CSV disk(s) – e.g., 500 GB / 1 TB / whatever you need
Example:
    D:\iSCSI\HV-Witness.vhdx → 2 GB
    D:\iSCSI\HV-CSV01.vhdx → 1.5 TB

### Powershell
```powershell
New-IscsiVirtualDisk -Path "G:\iSCSI\HV-Witness.vhdx" -Size 2GB -UseFixed
New-IscsiVirtualDisk -Path "G:\iSCSI\HV-CSV01.vhdx" -Size 1.5TB -UseFixed

```

## Verify disk created
```powershell
Get-IscsiVirtualDisk | Select Path, Size, Status | Format-Table -Auto
```

## Create an iSCSI target
- This defines who can connect.
- Server Manager → iSCSI → New iSCSI Target
Add initiators:
- By DNS name (recommended):
- HV01.domain.local
- HV02.domain.local

Or by IQN from each host’s iSCSI Initiator.
- Name:
- HVClusterTarget

## Command to pull IQN (Run on each host)
```powershell
(Get-InitiatorPort).NodeAddress
```

### Powershell Method DNS 
```powershell
New-IscsiServerTarget -TargetName "HVClusterTarget" `
  -InitiatorIds "DNSName:HyperV1.ad.edtechjeff.com"
```
### Powershell Method IQN
```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds "IQN:iqn.1991-05.com.microsoft:hyperv01"
```
### Multiple IQN
```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hyperv01.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hyperv02.ad.edtechjeff.com"
```
### Add to existing
```powershell
Set-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hyperv01.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hyperv02.ad.edtechjeff.com"
```

## Verify
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" | Select TargetName
```


## Map virtual disks to target
- Attach both LUNs to the target.
```powershell
Add-IscsiVirtualDiskTargetMapping -TargetName "HVClusterTarget" `
  -Path "G:\iSCSI\HV-Witness.vhdx"

Add-IscsiVirtualDiskTargetMapping -TargetName "HVClusterTarget" `
  -Path "G:\iSCSI\HV-CSV01.vhdx"
```

## Verify
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" | Select -ExpandProperty VirtualDisks
```

## (Optional) Enable CHAP authentication
- If you want security beyond IP/DNS:
```powershell
Set-IscsiServerTarget -TargetName "HVClusterTarget" `
  -EnableChap $true -ChapUsername "hvchap" -ChapSecret "StrongPassword!"
```

## Firewall
```powershell
Get-NetFirewallRule | ? DisplayName -like "*iSCSI*"
```
