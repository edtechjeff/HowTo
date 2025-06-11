# Load module and connect to Graph
Import-Module WindowsAutopilotIntune
Connect-MGGraph

# Path to your CSV
$csvPath = "C:\Path\To\SerialNumbers.csv"

# Import serial numbers from CSV
$serials = Import-Csv -Path $csvPath

# Loop through each serial number
foreach ($entry in $serials) {
    $serial = $entry.SerialNumber.Trim()
    Write-Host "Processing serial: $serial"

    # Find device in Autopilot
    $device = Get-AutopilotDevice | Where-Object { $_.serialNumber -eq $serial }

    if ($device) {
        # Update group tag
        Set-AutopilotDevice -id $device.id -groupTag "shared"
        Write-Host "✔ Group tag 'shared' applied to $serial" -ForegroundColor Green
    } else {
        Write-Host "⚠ Device with serial $serial not found in Autopilot" -ForegroundColor Yellow
    }
}
