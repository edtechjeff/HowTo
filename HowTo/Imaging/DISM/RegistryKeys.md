# Bypassing TPM, CPU, and RAM Checks for Windows 11 Installation

To bypass the TPM, CPU, and RAM checks when installing Windows 11 on a virtual machine, you can modify the registry settings during the installation process. Below are the steps and registry keys you need to add:

## Steps to Modify Registry Settings

1. Boot into the Windows 11 installation media.
2. When you reach the installation screen, press `Shift + F10` to open the Command Prompt.
3. Type `regedit` and press Enter to open the Registry Editor.
4. Navigate to the following path:
    ```
    HKEY_LOCAL_MACHINE\SYSTEM\Setup
    ```
5. Right-click on the `Setup` key, select **New > Key**, and name it `LabConfig`.
6. Select the newly created `LabConfig` key and add the following DWORD (32-bit) values:

### Registry Keys to Add

| Name                     | Type         | Value | Description                              |
|--------------------------|--------------|-------|------------------------------------------|
| `BypassTPMCheck`         | DWORD (32-bit) | `1`   | Bypasses the TPM requirement.            |
| `BypassCPUCheck`         | DWORD (32-bit) | `1`   | Bypasses the CPU requirement.            |
| `BypassRAMCheck`         | DWORD (32-bit) | `1`   | Bypasses the minimum RAM requirement.    |
| `BypassSecureBootCheck`  | DWORD (32-bit) | `1`   | (Optional) Bypasses the Secure Boot check.|

7. Close the Registry Editor and proceed with the installation.

## Notes

- These changes are intended for testing or evaluation purposes only. 
- Installing Windows 11 on unsupported hardware may result in reduced performance or compatibility issues.
- Always back up your data before making changes to your system.

By following these steps, you should be able to bypass the hardware checks and install Windows 11 on a virtual machine.
