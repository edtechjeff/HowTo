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
- On Storage1:
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
    G:\iSCSI\

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
    G:\iSCSI\HV-Witness.vhdx → 2 GB
    G:\iSCSI\HV-CSV01.vhdx → 1.5 TB

### Powershell
***Note*** Creating a large fixed iSCSI virtual disk can take considerable time because the storage is allocated during creation. Do not rerun New-IscsiVirtualDisk just because the command appears to be taking a long time
```powershell
New-IscsiVirtualDisk -Path "G:\iSCSI\HV-Witness.vhdx" -Size 2GB -UseFixed
New-IscsiVirtualDisk -Path "G:\iSCSI\HV-CSV01.vhdx" -Size 1.5TB

```

## Verify disk created
```powershell
Get-IscsiVirtualDisk |
    Format-Table Path,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -Auto
```

## Create an iSCSI target
- This defines who can connect.
- Server Manager → iSCSI → New iSCSI Target
Add initiators:
- By DNS name (recommended):
- HV03.domain.local
- HV04.domain.local

Or by IQN from each host’s iSCSI Initiator.
- Name:
- HVClusterTarget

# Run the following command on HV03 and HV04, then return to STORAGE1.

## Pull IQN (Run on each host)
```powershell
(Get-InitiatorPort).NodeAddress
```

# Continue on only after you have the IQN

## Multiple IQN
```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hv03.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hv04.ad.edtechjeff.com"
```

# Other Commands
### Adding a Single IQN
```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds "IQN:iqn.1991-05.com.microsoft:hv03"
```

### Add and IQN to existing target
```powershell
Set-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hv03.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hv04.ad.edtechjeff.com"
```

## Verify
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" | Select TargetName
```

## Map virtual disks to target
- Attach both LUNs to the target.
```powershell
Add-IscsiVirtualDiskTargetMapping `
    -TargetName "HVClusterTarget" `
    -Path "G:\iSCSI\HV-Witness.vhdx" `
    -Lun 0

Add-IscsiVirtualDiskTargetMapping `
    -TargetName "HVClusterTarget" `
    -Path "G:\iSCSI\HV-CSV01.vhdx" `
    -Lun 1
```

## Verify
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,InitiatorIds,LunMappings,Sessions,Status
```

## What it will display
```text
LUN 0 → G:\iSCSI\HV-Witness.vhdx
LUN 1 → G:\iSCSI\HV-CSV01.vhdx
```
# Verify virtual disks
```powershell
Get-IscsiVirtualDisk |
    Format-Table Path,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -Auto
```

# Verify target
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,TargetIqn,InitiatorIds,Status
```

# Verify LUN mappings
```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Select-Object -ExpandProperty LunMappings
```

# Once HV03/HV04 are connect4ed

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,InitiatorIds,LunMappings,Sessions,Status
```

## (Optional) Enable CHAP authentication
- If you want security beyond IP/DNS

```powershell 
# Create the CHAP credentials
$ChapSecret = ConvertTo-SecureString `
    -String "YourChapSecretHere" `
    -AsPlainText `
    -Force

$ChapCredential = New-Object `
    System.Management.Automation.PSCredential `
    ("hvchap", $ChapSecret)

# Enable CHAP on the iSCSI target
Set-IscsiServerTarget `
    -TargetName "HVClusterTarget" `
    -EnableChap $true `
    -Chap $ChapCredential
```

## Verify
```powershell
Get-IscsiServerTarget `
    -TargetName "HVClusterTarget" |
    Format-List TargetName,EnableChap,EnableReverseChap
```

## Firewall
```powershell
Get-NetFirewallRule | ? DisplayName -like "*iSCSI*"
```
