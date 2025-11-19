# Used to remove a shortcut off the all users desktop


## Detectiion Script
```powershell
# Detection script for Intune Remediation
$shortcutPath = "C:\Users\Public\Desktop\Microsoft Edge.lnk"

if (Test-Path -Path $shortcutPath) {
    Write-Host "Shortcut exists."
    exit 1  # Non-compliant, remediation needed
}
else {
    Write-Host "Shortcut does not exist."
    exit 0  # Compliant
}
```

## Remediation Script
```powershell
# Remediation script for Intune Remediation
$shortcutPath = "C:\Users\Public\Desktop\Microsoft Edge.lnk"

try {
    if (Test-Path -Path $shortcutPath) {
        Remove-Item -Path $shortcutPath -Force
        Write-Host "Shortcut deleted successfully."
    }
    else {
        Write-Host "Shortcut not found. Nothing to delete."
    }
}
catch {
    Write-Host "Error deleting shortcut: $($_.Exception.Message)"
}
```
