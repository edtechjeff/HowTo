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