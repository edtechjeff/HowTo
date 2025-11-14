# ==============================
# BULK DELETE ENTRA DEVICES
# ==============================

# Note: Reason for this script was because devices were showing up in Entra as devices in AutoPilot but not in Intune.
# Intune would not allow deletion of these devices since they were not present there.


# CSV Location
$csvPath = "C:\temps\devices.csv"

# Connect to Graph
Connect-MgGraph -Scopes "Device.ReadWrite.All"

# Import CSV
$devices = Import-Csv -Path $csvPath

foreach ($entry in $devices) {

    $id = $entry.ObjectId.Trim()

    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "Skipping empty ObjectId row..." -ForegroundColor Yellow
        continue
    }

    Write-Host "Attempting to delete device: $id" -ForegroundColor Cyan

    try {
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/devices/$id"
        Write-Host "SUCCESS: Deleted device $id" -ForegroundColor Green
    }
    catch {
        Write-Host "FAILED to delete $id : $($_.Exception.Message)" -ForegroundColor Red
    }
}
