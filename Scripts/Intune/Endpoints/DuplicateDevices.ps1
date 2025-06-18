# Script 1: Find duplicate Intune devices with older check-in dates

# Connect to Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Get all Intune managed devices
$devices = Get-MgDeviceManagementManagedDevice -All

# Group by device name to find duplicates
$duplicates = $devices | Group-Object DeviceName | Where-Object { $_.Count -gt 1 }

# Prepare an array to hold devices to delete
$devicesToDelete = @()

foreach ($group in $duplicates) {
    $sorted = $group.Group | Sort-Object LastCheckInDateTime -Descending

    # Keep the newest check-in (first in sorted), delete the rest
    $devicesToDelete += $sorted[1..($sorted.Count - 1)] | ForEach-Object {
        [PSCustomObject]@{
            DeviceName = $_.DeviceName
            DeviceId = $_.Id
            LastCheckIn = $_.LastCheckInDateTime
        }
    }
}

# Export to CSV
$devicesToDelete | Export-Csv -Path "c:\temp\IntuneDevicesToDelete.csv" -NoTypeInformation

Write-Host "Devices to delete exported to IntuneDevicesToDelete.csv"