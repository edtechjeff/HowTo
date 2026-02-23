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

## 1. Install Bitlocker Windows Feature
```powershell
Install-WindowsFeature BitLocker -IncludeAllSubFeature -IncludeManagementTools -Restart:$false
```
**Note:** Reboot the server after installation

---

## 2. Import BitLocker Module (Post-Reboot)
```powershell
Import-Module BitLocker
```

---

## 3. Verify module loaded
```powershell
Get-Command Enable-BitLocker
```

---

## 4. Run to get key from server
**Note:** Save the output till you verify that the key did load into Active Directory
```powershell
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
```

---

## 5. Enable BitLocker on OS Drive (C:)
**Note:** Server will require a reboot.
```bash
manage-bde -on C:
```

---

## 6. Force Backup of Recovery Key to Active Directory
```powershell
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId (Get-BitLockerVolume -MountPoint "C:").KeyProtector[0].KeyProtectorId
```

---

## 7. Monitor Encryption Progress
```powershell
Get-BitLockerVolume -MountPoint "C:"
```

---

## 8. Enable Auto Unlock for Data Volume
**Note:** Automatically unlock encrypted data volume during system boot.
```powershell
Enable-BitLockerAutoUnlock -MountPoint "D:"
```

---

## 9. Verify Auto Unlock is Enabled
```powershell
Get-BitLockerVolume -MountPoint "D:" | Select MountPoint, AutoUnlockEnabled
```

---

## 10. Alternative detailed view
```powershell
Get-BitLockerVolume | Select MountPoint, VolumeStatus, EncryptionPercentage
```

---

## 11. Verify BitLocker Status on All Volumes
```powershell
Get-BitLockerVolume
```

---

## 12. Retrieve Recovery Key from Server
```powershell
(Get-BitLockerVolume -MountPoint "C:").KeyProtector |
Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} |
Select-Object -ExpandProperty RecoveryPassword
```

---

## 13. Verify key is in Active Directory
**note:** You must know the Distinguished Name (DN) of the computer object.
```powershell
Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} `
-SearchBase "CN=COMPUTERNAME,OU=Servers,DC=domain,DC=com" `
-Properties *
```

---

## 14. Other Commands

This section includes additional commands useful for validation and troubleshooting.

### Example 1 – View BitLocker Protectors

Displays all configured protectors for the OS volume.

```bash
manage-bde -protectors -get C:
```

### Example 2 – View BitLocker Status (CLI)

Shows encryption state and percentage.

```bash
manage-bde -status C:
```

**Purpose**  
Verifies encryption progress and protection status.

**Purpose**  
Shows the Recovery Password ID and other protector types assigned to the drive.

**When to Use**
- Before backing up recovery keys to Active Directory  
- To confirm a recovery password exists  
- During BitLocker troubleshooting  

### Example 3 – Retrieve Recovery Password via PowerShell

Retrieves the BitLocker recovery password directly from the system.

```powershell
(Get-BitLockerVolume -MountPoint "C:").KeyProtector |
Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} |
Select-Object -ExpandProperty RecoveryPassword
```

**Purpose**  
Outputs the 48-digit BitLocker recovery password.

**When to Use**
- Before manually backing up to AD  
- For emergency recovery documentation  
- Validation before reboot

**Important**  
Always verify the recovery key is successfully stored in Active Directory.

### Example 4 – Enable BitLocker on OS Drive

Enables BitLocker using TPM and Recovery Password protector.

```powershell
Enable-BitLocker -MountPoint "C:" -RecoveryPasswordProtector -TpmProtector
```

**Purpose**  
Starts encryption of the operating system volume.

---

### Example 5 – Backup Recovery Key to Active Directory

Backs up recovery key to AD (manual method).

```powershell
$KeyID = (Get-BitLockerVolume -MountPoint "C:").KeyProtector |
Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} |
Select-Object -ExpandProperty KeyProtectorId

manage-bde -protectors -adbackup C: -ID $KeyID
```

**Purpose**  
Ensures recovery information is stored in Active Directory.

---

### Example 6 – Verify BitLocker Module Availability

Confirms BitLocker PowerShell module is available.

```powershell
Get-Command Enable-BitLocker
```

**Purpose**  
Validates that BitLocker management tools are installed.

---

### Example 7 – Enable BitLocker Auto Unlock (Data Volume)

Enables automatic unlock for non-OS drives.

```powershell
Enable-BitLockerAutoUnlock -MountPoint "D:"
```

**Purpose**  
Allows data volumes to unlock automatically after reboot.

---

### Example 8 – Suspend BitLocker Protection

Temporarily suspends protection (useful before maintenance).

```powershell
Suspend-BitLocker -MountPoint "C:" -RebootCount 1
```

**Purpose**  
Suspends BitLocker protection for one reboot cycle.

---

### Example 9 – Resume BitLocker Protection

Re-enables protection after suspension.

```powershell
Resume-BitLocker -MountPoint "C:"
```

**Purpose**  
Restores active BitLocker protection.

---

### Example 10 – Check TPM Status

Verifies TPM presence and readiness.

```powershell
Get-Tpm
```

**Purpose**  
Confirms TPM is enabled and ready before encryption.