Assign AutoPilot Profiles During Imaging Process

Table of Contents

1. Import Required PowerShell Modules

2. Log onto Microsoft Graph

3. Export AutoPilot Profiles

4. Rename Desired Profile

5. Prepare Windows Image

6. Export Specific Windows Edition

7. Mount the WIM Image

8. Copy AutoPilot Profile to Image

9. Commit the Mounted Image

10. Final Thoughts

Troubleshooting Tips

Next Steps

1. Import Required PowerShell Modules

if (-not (Get-Module -ListAvailable -Name AzureAD)) { Install-Module AzureAD -Force }
if (-not (Get-Module -ListAvailable -Name WindowsAutopilotIntune)) { Install-Module WindowsAutopilotIntune -Force }
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Intune)) { Install-Module Microsoft.Graph.Intune -Force }

Note: PowerShell ISE is deprecated. Use Visual Studio Code or Windows Terminal for scripting.

2. Log onto Microsoft Graph

Connect-MgGraph

3. Export AutoPilot Profiles

$AutopilotProfiles = Get-AutopilotProfile
```markdown
# Assign AutoPilot Profiles During Imaging Process

## Table of Contents

1. Import Required PowerShell Modules
2. Log onto Microsoft Graph
3. Export AutoPilot Profiles
4. Rename Desired Profile
5. Prepare Windows Image
6. Export Specific Windows Edition
7. Mount the WIM Image
8. Copy AutoPilot Profile to Image
9. Commit the Mounted Image
10. Final Thoughts

---

## Troubleshooting Tips

---

## Next Steps

---

### 3. Export AutoPilot Profiles

```powershell
# Export AutoPilot Profiles to JSON files
foreach ($AutopilotProfile in $AutopilotProfiles) {
    $TempPath = "C:\DATA\AutopilotProfiles\"

    if (!(Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force
    }

    $name = $AutopilotProfile.displayName
    $ExportPath = Join-Path $TempPath ($name + "_AutopilotConfigurationFile.json")
    $AutopilotProfile | ConvertTo-AutopilotConfigurationJSON | Out-File $ExportPath -Encoding ASCII
}
```
foreach ($AutopilotProfile in $AutopilotProfiles) {
    $TempPath = "C:\DATA\AutopilotProfiles\"

    if (!(Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force
    }

    $name = $AutopilotProfile.displayName
    $ExportPath = Join-Path $TempPath ($name + "_AutopilotConfigurationFile.json")
    $AutopilotProfile | ConvertTo-AutopilotConfigurationJSON | Out-File $ExportPath -Encoding ASCII
}

Your files will be downloaded to:C:\DATA\AutopilotProfiles



4. Rename Desired Profile

Rename the .json file you want to use during deployment to:

AutopilotConfigurationFile.json

5. Prepare Windows Image

Download a Windows 11 ISO and locate install.wim inside the \sources folder.

6. Export Specific Windows Edition

Use the following command to identify the edition index (e.g., Professional):

Dism /get-wiminfo /wimfile:"E:\sources\install.wim"



Export the edition you want (in this case, Pro = Index 6):

Dism /export-image /SourceImageFile:"E:\sources\install.wim" /SourceIndex:6 /DestinationImageFile:C:\DATA\WIM\install.wim /Compress:max /CheckIntegrity

7. Mount the WIM Image

Dism /mount-wim /wimfile:"C:\DATA\WIM\install.wim" /index:1 /mountdir:C:\DATA\Mount

8. Copy AutoPilot Profile to Image

Place the renamed .json file into the following directory inside the mounted image:

C:\DATA\Mount\Windows\Provisioning\Autopilot\



9. Commit the Mounted Image

Make sure all folders using the mount path are closed (File Explorer, editors, etc.), or this command will fail:

Dism /Commit-Image /MountDir:C:\DATA\Mount

10. Final Thoughts

You now have a custom WIM that will:

Install Windows 11 Professional (or your selected edition)

Automatically apply your chosen AutoPilot profile

You can deploy this WIM file using PXE, MDT, or USB—whatever method works best for your environment.

Troubleshooting Tips

❗ Ensure the file is named AutopilotConfigurationFile.json exactly.

❗ Close all open folders pointing to C:\DATA\Mount before committing.

❗ Use Dism /Cleanup-Wim if you encounter locking issues.

⚠ Some modules like WindowsAutopilotIntune may be deprecated—consider switching to Microsoft Graph directly.

Next Steps

Integrate this WIM into your WDS/MDT or USB deployment routine.

Test deployment in a virtual machine before full rollout.

Automate JSON generation and copying using deployment scripts.

Hope this guide has helped—until next time!