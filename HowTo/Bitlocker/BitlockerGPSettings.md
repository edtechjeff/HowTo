---
title: BitlockerServers GPO Report
author: Jeff Downs
date: \today
toc: true
toc-depth: 3
---

# Computer Configuration

## Administrative Templates  
**Path:**  
`Computer Configuration → Policies → Administrative Templates → Windows Components → BitLocker Drive Encryption`

---

# Encryption Settings

## Choose drive encryption method and cipher strength
**Status:** Enabled  
**Encryption Method:** AES 256-bit  

---

# Recovery Settings – Domain Backup

## Store BitLocker recovery information in Active Directory Domain Services
**Status:** Enabled  

- Require BitLocker backup to AD DS: **Enabled**
- Store: **Recovery passwords only**
- BitLocker cannot be enabled if backup fails

---

# Fixed Data Drives

## Choose how BitLocker-protected fixed drives can be recovered
**Status:** Enabled  

- Allow data recovery agent: Enabled  
- Allow 48-digit recovery password: Enabled  
- Allow 256-bit recovery key: Enabled  
- Omit recovery options from the BitLocker setup wizard: Disabled  
- Save BitLocker recovery information to AD DS for fixed data drives: Enabled  
- AD DS Storage Option: Backup recovery passwords and key packages  
- Do not enable BitLocker until recovery information is stored to AD DS: Enabled  

---

## Enforce drive encryption type on fixed data drives
**Status:** Enabled  
**Encryption Type:** Not explicitly defined (Wizard selection suppressed)

---

# Operating System Drives

## Choose how BitLocker-protected operating system drives can be recovered
**Status:** Enabled  

- Allow data recovery agent: Enabled  
- Allow 48-digit recovery password: Enabled  
- Allow 256-bit recovery key: Enabled  
- Omit recovery options from the BitLocker setup wizard: Disabled  
- Save BitLocker recovery information to AD DS for operating system drives: Enabled  
- AD DS Storage Option: Store recovery passwords and key packages  
- Do not enable BitLocker until recovery information is stored to AD DS: Enabled  

---

## Disallow standard users from changing the PIN or password
**Status:** Enabled  
- Standard users cannot change BitLocker PIN or password

---

## Enforce drive encryption type on operating system drives
**Status:** Enabled  
**Encryption Type:** Not explicitly defined (Wizard selection suppressed)

---

## Require additional authentication at startup
**Status:** Enabled  

### TPM Configuration

| Setting | Configuration |
|----------|---------------|
| Allow BitLocker without TPM | Disabled |
| Configure TPM startup | Allow TPM |
| Configure TPM startup PIN | Do not allow startup PIN |
| Configure TPM startup key | Do not allow startup key |
| Configure TPM startup key and PIN | Do not allow startup key and PIN |

**Resulting Behavior:**

- TPM-only authentication permitted
- No PIN allowed
- No USB startup key allowed
- No TPM + PIN
- No TPM + USB key
- No TPM + PIN + USB combination

---

# Security Filtering

| Trustee | Permission |
|----------|-----------|
| Authenticated Users | Apply Group Policy |
| Domain Admins | Edit, delete, modify security |
| Enterprise Admins | Edit, delete, modify security |
| SYSTEM | Edit, delete, modify security |
| Enterprise Domain Controllers | Read |

---

# Effective Security Posture Summary

This GPO enforces the following configuration for member servers:

- AES 256-bit BitLocker encryption
- Mandatory AD DS recovery backup
- BitLocker activation blocked if AD backup fails
- Recovery passwords and key packages stored in AD
- TPM-only startup authentication
- No startup PIN or USB key allowed
- Standard users cannot modify BitLocker credentials
- Applies to both operating system and fixed data drives

---

# Architectural Notes

- Encryption type enforcement is enabled but not explicitly defined, suppressing user selection in the wizard.
- TPM-only configuration simplifies server deployments.
- Recovery key escrow is centrally enforced via AD DS.
- 256-bit encryption aligns with enterprise-grade security standards.
- Designed for domain-joined member servers.

---