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
- TPM enabled in BIOS.
- Server joined to Active Directory.
- BitLocker policies configured to store recovery information in AD.

---

# Steps

- Verify TPM Chip is enabled
```powershell
Get-Tpm
```

---

- Install Bitlocker Windows Feature
```powershell
Install-WindowsFeature BitLocker -IncludeAllSubFeature -IncludeManagementTools -Restart:$false
```
**Note:** Reboot the server after installation

---

- Import BitLocker Module (Post-Reboot)
```powershell
Import-Module BitLocker
```

---

- Verify module loaded
```powershell
Get-Command Enable-BitLocker
```

---

- Run to get key from server
**Note:** Save the output till you verify that the key did load into Active Directory
```powershell
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
```

---

- Enable BitLocker on OS Drive (C:)
**Note:** Server will require a reboot.
```bash
manage-bde -on C:
```

---

- Force Backup of Recovery Key to Active Directory
```bash
manage-bde -protectors -adbackup C:
```

---

- Monitor Encryption Progress
```powershell
Get-BitLockerVolume -MountPoint "C:"
```

---

- Enable-BitLocker -MountPoint "D:" -RecoveryPasswordProtector
**Note:** Modify drive letters as appropriate for your environment.
```powershell
Enable-BitLocker -MountPoint "D:" -RecoveryPasswordProtector
```

---

- Enable Auto Unlock for Data Volume
**Note:** Automatically unlock encrypted data volume during system boot.
```powershell
Enable-BitLocker -MountPoint "D:" -RecoveryPasswordProtector
```

---

- Verify Auto Unlock is Enabled
```powershell
Get-BitLockerVolume -MountPoint "D:" | Select MountPoint, AutoUnlockEnabled
```

---

- Alternative detailed view
```powershell
Get-BitLockerVolume | Select MountPoint, VolumeStatus, EncryptionPercentage
```

---

- Verify BitLocker Status on All Volumes
```powershell
Get-BitLockerVolume
```

---

- Retrieve Recovery Key from Server
```powershell
(Get-BitLockerVolume -MountPoint "C:").KeyProtector |
Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} |
Select-Object -ExpandProperty RecoveryPassword
```

---

- Verify key is in Active Directory
**note:** You must know the Distinguished Name (DN) of the computer object.
```powershell
Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} `
-SearchBase "CN=COMPUTERNAME,OU=Servers,DC=domain,DC=com" `
-Properties *
```

---