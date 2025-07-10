# Prompt for root folder
$rootFolder = (New-Object -ComObject Shell.Application).BrowseForFolder(0, "Select the root folder to search:", 0).Self.Path

if (-not $rootFolder) {
    Write-Host "No folder selected. Exiting..."
    exit
}

# Extract a safe folder name for filename (remove special characters)
$folderName = Split-Path $rootFolder -Leaf
$folderNameSafe = ($folderName -replace '[\\/:*?"<>|]', '_')

# Prompt for log folder
$logFolder = (New-Object -ComObject Shell.Application).BrowseForFolder(0, "Select the folder to save the log file:", 0).Self.Path

if (-not $logFolder) {
    Write-Host "No log folder selected. Exiting..."
    exit
}

# Create log folder if it doesn't exist
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
}

# Define cutoff date
$cutoffDate = Get-Date "2025-05-15"

# Get folders created after cutoff date
$folders = Get-ChildItem -Path $rootFolder -Recurse -Directory | Where-Object {
    $_.CreationTime -gt $cutoffDate
} | Select-Object FullName, CreationTime

# Export to CSV with timestamp and root folder name
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvName = "CreatedAfter_${folderNameSafe}_$timestamp.csv"
$csvPath = Join-Path $logFolder $csvName
$folders | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "✅ Report saved to $csvPath"
