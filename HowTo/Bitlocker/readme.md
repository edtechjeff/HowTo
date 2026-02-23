---
title: BitLocker Servers GPO Deployment Guide
author: Jeff Downs
date: \today
toc: true
toc-depth: 3
---

# Purpose

Enable BitLocker encryption on Windows Server systems and ensure recovery keys are backed up to Active Directory.

---

# Pre-Requisites

- Group Policy Object (GPO) created and linked to the appropriate OU.
- Server joined to Active Directory.
- BitLocker policies configured to store recovery information in AD.
**Note:** Since this is a clustered HyperV setup the VMs themselves will not have a TPM Chip enabled. Will only do password for bilocker

---

# Steps

## 2. Install Bitlocker Windows Feature
```powershell
Install-WindowsFeature BitLocker -IncludeAllSubFeature -IncludeManagementTools -Restart:$false
```
**Note:** Reboot the server after installation

---

## 3. Import BitLocker Module (Post-Reboot)
```powershell
Import-Module BitLocker
```

---

## 4. Verify module loaded
```powershell
Get-Command Enable-BitLocker
```

---

## 5. Run to get key from server
**Note:** Save the output till you verify that the key did load into Active Directory
```powershell
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
```

---

## 6. Enable BitLocker on OS Drive (C:)
**Note:** Server will require a reboot.
```bash
manage-bde -on C:
```

---

## 7. Force Backup of Recovery Key to Active Directory
```powershell
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId (Get-BitLockerVolume -MountPoint "C:").KeyProtector[0].KeyProtectorId
```

---

## 8. Monitor Encryption Progress
```powershell
Get-BitLockerVolume -MountPoint "C:"
```

---

## 10. Enable Auto Unlock for Data Volume
**Note:** Automatically unlock encrypted data volume during system boot.
```powershell
Enable-BitLockerAutoUnlock -MountPoint "D:"
```

---

## 11. Verify Auto Unlock is Enabled
```powershell
Get-BitLockerVolume -MountPoint "D:" | Select MountPoint, AutoUnlockEnabled
```

---

## 12. Alternative detailed view
```powershell
Get-BitLockerVolume | Select MountPoint, VolumeStatus, EncryptionPercentage
```

---

## 13. Verify BitLocker Status on All Volumes
```powershell
Get-BitLockerVolume
```

---

## 14. Retrieve Recovery Key from Server
```powershell
(Get-BitLockerVolume -MountPoint "C:").KeyProtector |
Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} |
Select-Object -ExpandProperty RecoveryPassword
```

---

## 15. Verify key is in Active Directory
**note:** You must know the Distinguished Name (DN) of the computer object.
```powershell
Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} `
-SearchBase "CN=COMPUTERNAME,OU=Servers,DC=domain,DC=com" `
-Properties *
```

---