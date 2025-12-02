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