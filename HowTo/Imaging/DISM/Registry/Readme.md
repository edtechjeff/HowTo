# 🚫 Bypassing TPM, CPU, and RAM Checks for Windows 11 Installation

You can bypass the hardware checks (TPM, CPU, RAM, and optionally Secure Boot) when installing Windows 11—especially useful in virtual machines or on unsupported hardware—by modifying the registry during installation.

---

## 🧰 Steps to Modify Registry Settings

1. **Boot into the Windows 11 installation media.**
2. When you reach the initial setup screen, press `Shift + F10` to open **Command Prompt**.
3. Type `regedit` and press **Enter** to launch the **Registry Editor**.
4. In the Registry Editor, navigate to the following path:
   ```
   HKEY_LOCAL_MACHINE\SYSTEM\Setup
   ```
5. Right-click on the **Setup** key, select **New > Key**, and name it:
   ```
   LabConfig
   ```
6. Select the `LabConfig` key and add the following **DWORD (32-bit)** values:

---

## 📝 Registry Keys to Add

| Name                     | Type            | Value | Description                               |
|--------------------------|-----------------|--------|-------------------------------------------|
| `BypassTPMCheck`         | `DWORD (32-bit)`| `1`    | Bypasses the Trusted Platform Module check. |
| `BypassCPUCheck`         | `DWORD (32-bit)`| `1`    | Bypasses unsupported CPU restrictions.    |
| `BypassRAMCheck`         | `DWORD (32-bit)`| `1`    | Skips minimum RAM requirements.           |
| `BypassSecureBootCheck`  | `DWORD (32-bit)`| `1`    | *(Optional)* Skips the Secure Boot check. |

7. Close the **Registry Editor** and return to the installation process to continue with setup.

---

## ⚠️ Important Notes

- These steps are intended for **testing or evaluation** purposes only.
- Installing Windows 11 on unsupported hardware may lead to:
  - Reduced system performance
  - Compatibility issues
  - Lack of official support or future updates
- Always **back up important data** before proceeding.

---

## ✅ Outcome

After completing these steps, the Windows 11 installer should skip the hardware validation checks, allowing you to install it even on systems or VMs that don't meet the official requirements.
