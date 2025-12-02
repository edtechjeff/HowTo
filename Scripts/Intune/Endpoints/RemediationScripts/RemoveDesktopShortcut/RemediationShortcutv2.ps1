# Remediation script for Intune Remediation

# Public desktop path
$publicShortcut = "C:\Users\Public\Desktop\Microsoft Edge.lnk"

# User desktop wildcard
$userShortcutPattern = "C:\Users\*\Desktop\Microsoft Edge.lnk"

# Combine all possible paths
$allShortcuts = @()

# Add Public Desktop if exists
if (Test-Path $publicShortcut) {
    $allShortcuts += $publicShortcut
}

# Add all user profile desktop shortcuts
$userShortcuts = Get-ChildItem -Path $userShortcutPattern -ErrorAction SilentlyContinue
if ($userShortcuts) {
    $allShortcuts += $userShortcuts.FullName
}

# Remove duplicates just in case
$allShortcuts = $allShortcuts | Select-Object -Unique

# If no shortcuts found
if (-not $allShortcuts -or $allShortcuts.Count -eq 0) {
    Write-Host "No Microsoft Edge shortcuts found. Nothing to delete."
    exit 0
}

# Delete all found shortcuts
foreach ($shortcut in $allShortcuts) {
    try {
        if (Test-Path $shortcut) {
            Remove-Item -Path $shortcut -Force
            Write-Host "Deleted shortcut: $shortcut"
        }
    }
    catch {
        Write-Host "Error deleting $shortcut : $($_.Exception.Message)"
    }
}

Write-Host "Remediation complete."
exit 0
