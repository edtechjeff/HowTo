#Fill this variable with the Winget package ID
$PackageName = "Mozilla.Firefox"

# Try using winget from path
try {
    $InstalledApps = winget list --id $PackageName 2>&1

    if ($InstalledApps -match $PackageName) {
        Write-Host "$PackageName is installed"
        exit 0
    } else {
        Write-Host "$PackageName not detected"
        exit 1
    }
}
catch {
    Write-Host "Winget not available or failed to run. Error: $_"
    exit 1
}