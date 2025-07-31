# Install Azure AD Connect on New Server and Migrate

## Supported Windows Server Versions

Azure AD Connect v2 is supported on:

- Windows Server 2016
- Windows Server 2019
- Windows Server 2022

> **Note:** Azure AD Connect v2 requires **Windows Server 2016 or higher**. If you're running an older version, you **must migrate** to a newer server.

## Upgrade vs. Migration

Already running Azure AD Connect v1 on a supported OS and want to upgrade? Or upgrading from v2 to a newer release? Follow the [in-place upgrade guide](https://learn.microsoft.com/en-us/azure/active-directory/hybrid/how-to-upgrade-previous-version).

## Major Changes in Azure AD Connect v2

- Uses SQL Server 2019 LocalDB
- Uses MSAL (Modern Authentication Library)
- Requires Visual C++ Redistributable 14
- Enforces TLS 1.2
- All binaries SHA2-signed
- Drops support for Windows Server 2012/2012 R2
- Requires PowerShell 5.0

## Migration Steps

### 1. Check Azure AD Connect Version on Source Server

- Open **Azure AD Connect Synchronization Service** > Help > About
- Example: Version 1.6.16.0 indicates v1

### 2. Export Configuration from Source Server

1. Open **Azure AD Connect** > **Configure**
2. Choose **View or export current configuration** > **Next** > **Export Settings**
3. Save the `.json` file to copy to the target server

### 3. Document User Sign-In Settings

1. Go to **Additional tasks** > **Change user sign-in** > **Next**
2. Note down or screenshot the configured method (e.g., Password Hash Sync, Write-back)

> ⚠ Exported JSON **does not include sign-in settings** — document them manually.

If **Device Writeback** is enabled:

```powershell
(Get-ADSyncGlobalSettings).Parameters | select Name,Value
Get-ADSyncScheduler
```

Save the output to a file for reference.

### 4. Ensure TLS 1.2 is Enabled on Target Server

Run the following PowerShell script **as Administrator**:

```powershell
# Enable TLS 1.2 for .NET and SCHANNEL
# [Script truncated for brevity — full script remains the same]
```

Reboot the server after applying the script.

### 5. Download Azure AD Connect v2

Download the latest installer from: [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=47594)

> Latest known version: **2.1.20.0**

### 6. Install Azure AD Connect v2 on Target Server

1. Run the installer > Accept terms > Continue
2. Click **Customize**
3. Check **Import synchronization settings** and load the exported `.json` file
4. Re-enter sign-in settings noted earlier
5. Use a user account with **Hybrid Identity Administrator** role (no longer requires Global Admin)

#### Recommended: Use a Service Account

- Create a cloud-only user (e.g., `svc-adconnect@domain.onmicrosoft.com`)
- Assign the **Hybrid Identity Administrator** role via Azure AD portal

If prompted:

- **Create new AD account** (recommended)
- OR use an existing AD DS Connector account with correct permissions

> ⚠ Exclude the Azure AD Connect Sync Account from MFA policies.

6. Select **Start sync** and **Enable staging mode** > Install
7. Verify version and synchronization success
8. Compare exported `.json` and applied configuration using Notepad

### 7. Enable Staging Mode on Old Server

1. Launch Azure AD Connect > Configure > **Configure staging mode**
2. Authenticate and enable staging mode
3. Confirm staging mode is active

### 8. Disable Staging Mode on New Server

1. On new server > Azure AD Connect > Configure > **Configure staging mode**
2. Authenticate > **Uncheck Enable staging mode** > Configure
3. Confirm staging mode is disabled

### 9. Verify Synchronization

- Open **Azure AD Connect Synchronization Service**
- Check for **success** status — no permission or sync errors

If issues appear (e.g., on Domain Admin accounts):

- Open **Active Directory Users and Computers**
- Enable **inheritance** under Security tab > Advanced

### 10. Verify in Microsoft 365 Admin Center

- Go to [admin.microsoft.com](https://admin.microsoft.com)
- Check **Azure AD Connect** tile > **Sync status**
- Or go to **Health > Directory sync status**

### 11. Decommission Old Azure AD Connect Server

1. Shut it down for a few days or disable its services as a precaution
2. Uninstall Azure AD Connect
3. Remove old AD DS Connector and Azure AD Connector accounts

### 12. Verify Azure AD Connect Health (Optional)

> Requires Azure AD Premium P1 or higher

1. Go to [Azure Portal](https://portal.azure.com) > Azure AD > Azure AD Connect Health
2. Under **Sync Services**, confirm the new server is listed and healthy
3. If not listed:
   - Run **Microsoft Azure AD Connect Health Agent for Sync** > Change > Re-register
4. Once confirmed, delete the old server from the portal

---

**End of Guide**

can you give me the mar
