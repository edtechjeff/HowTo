# Detection script for Intune Remediation

# Define shortcuts to check
$shortcutTargets = @(
    "C:\Users\Public\Desktop\Microsoft Edge.lnk",
    "C:\Users\*\Desktop\Microsoft Edge.lnk"
)

$found = $false

foreach ($path in $shortcutTargets) {
    # Expand wildcard paths
    $expanded = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

    if ($expanded) {
        foreach ($item in $expanded) {
            if (Test-Path $item.FullName) {
                Write-Host "Shortcut exists at: $($item.FullName)"
                $found = $true
            }
        }
    }
}

if ($found) {
    exit 1  # Non-compliant
}
else {
    Write-Host "No Microsoft Edge shortcuts found in Public Desktop or user profiles."
    exit 0  # Compliant
}
