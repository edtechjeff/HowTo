# 🔧 PowerShell Scripts

[![PowerShell](https://img.shields.io/badge/built%20with-PowerShell-012456.svg?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](../../LICENSE)

This directory contains a curated set of PowerShell scripts to support everyday IT operations. These tools help with automation, reporting, and quick diagnostics in Microsoft environments—especially in hybrid or cloud setups using Intune, Azure AD, or Microsoft Graph.

---

## 📜 Script Index

| Script Name                          | Description                                                        |
|-------------------------------------|--------------------------------------------------------------------|
| `CheckBitlocker.ps1`                | Checks BitLocker encryption status on the local device.            |
| `IntuneDevicesAndLastContact.ps1`   | Retrieves Intune-enrolled devices and their last check-in time.    |
| `SyncADConnect.ps1`                 | Forces a sync between on-prem AD and Azure AD using AD Connect.    |
| `WMI-Battery.ps1`                   | Pulls battery info using WMI queries—useful for laptop health.     |
| `DeviceStatusFromGraph.ps1`         | Uses Graph API to pull detailed device info. Requires auth.        |
| `GetUserMembership.ps1`             | Lists all AD groups a user belongs to.                             |
| `TestEmailSend.ps1`                 | Sends a test email via SMTP for mail flow or automation testing.   |

---

## 🚀 Usage

> 💬 Most scripts include inline comments to guide usage.

1. Open the `.ps1` file in PowerShell ISE or VS Code.
2. Modify any required variables (e.g., usernames, tenant IDs, SMTP settings).
3. Run with sufficient privileges (e.g., Administrator or Graph access token).
4. Review output or logs as needed.

---

## 🔐 Security Note

Some scripts require elevated permissions or sensitive credentials (e.g., app tokens, admin accounts). **Never hardcode passwords**. Use secure credential prompts or environment variables where possible.

---

## 🤝 Contributing

Have a helpful script? Submit a pull request with your code and a short explanation. Keep naming and formatting consistent with existing scripts.

---

## 📄 License

Licensed under the [MIT License](../../LICENSE).
