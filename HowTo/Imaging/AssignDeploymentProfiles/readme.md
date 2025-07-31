# Assign Autopilot Profiles During Imaging Process

This guide walks you through assigning Autopilot profiles to a Windows image during your imaging process using PowerShell and DISM.

---

## 1. Install Required PowerShell Modules

```powershell
Install-Module AzureAD -Force
Install-Module WindowsAutopilotIntune -Force
Install-Module Microsoft.Graph.Intune -Force
```

---

## 2. Connect to Microsoft Graph

```powershell
Connect-MgGraph
```

---

## 3. Export Autopilot Profiles to JSON

```powershell
$AutopilotProfiles = Get-AutopilotProfile

$TempPath = "C:\DATA\AutopilotProfiles\"
if (!(Test-Path $TempPath)) {
    New-Item -Path $TempPath -ItemType Directory -Force
}

foreach ($AutopilotProfile in $AutopilotProfiles) {
    $name = $AutopilotProfile.displayName -replace '[^a-zA-Z0-9]', '_'
    $ExportPath = "$TempPath${name}_AutopilotConfigurationFile.json"
    $AutopilotProfile | ConvertTo-AutopilotConfigurationJSON | Out-File $ExportPath -Encoding ASCII
}
```

> ✅ Your exported files will be located in: `C:\DATA\AutopilotProfiles\`



---

## 4. Prepare the JSON File for Embedding

Rename the profile you want to embed to:

```
AutopilotConfigurationFile.json
```

---

## 5. Download and Mount Windows Image

1. **Download a Windows 11 ISO.**
2. **Determine the Index for Your Edition (e.g., Pro):**

```powershell
Dism /Get-WimInfo /WimFile:"E:\sources\install.wim"
```



3. **Export the Specific Edition:**

```powershell
Dism /Export-Image /SourceImageFile:"E:\sources\install.wim" /SourceIndex:6 /DestinationImageFile:C:\DATA\WIM\install.wim /Compress:max /CheckIntegrity
```

4. **Mount the Exported Image:**

```powershell
Dism /Mount-Wim /WimFile:"C:\DATA\WIM\install.wim" /Index:1 /MountDir:C:\DATA\Mount
```

---

## 6. Inject the Autopilot Profile

Copy the renamed JSON file to:

```
C:\DATA\Mount\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json
```



---

## 7. Commit the Mounted Image

Make sure all windows/folders referencing the mounted image are closed:

```powershell
Dism /Commit-Image /MountDir:C:\DATA\Mount
```

---

## ✅ Final Notes

- You now have an updated `install.wim` file with a specific Autopilot deployment profile.
- You can deploy this WIM via PXE or USB depending on your environment.

Happy Imaging! 🚀

