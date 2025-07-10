# Connect to Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Get all Intune managed devices
$devices = Get-MgDeviceManagementManagedDevice -All

# Define version threshold for Windows 11
$windows11Version = [version]"10.0.26100.4061"

# Filter to only Windows devices with version less than 10.0.26100.4061 (Windows 10)
$windows10Devices = $devices | Where-Object {
    $_.OperatingSystem -eq "Windows" -and
    ([version]$_.OperatingSystemVersion) -lt $windows11Version
}

# Group by device name to find duplicates
$duplicates = $windows10Devices | Group-Object DeviceName | Where-Object { $_.Count -gt 1 }

# Prepare list of devices to delete (all but most recent check-in)
$devicesToDelete = @()

foreach ($group in $duplicates) {
    $sorted = $group.Group | Sort-Object LastCheckInDateTime -Descending

    $devicesToDelete += $sorted[1..($sorted.Count - 1)] | ForEach-Object {
        [PSCustomObject]@{
            DeviceName     = $_.DeviceName
            DeviceId       = $_.Id
            LastCheckIn    = $_.LastCheckInDateTime
            OS             = $_.OperatingSystem
            OSVersion      = $_.OperatingSystemVersion
        }
    }
}

# Export to CSV
$devicesToDelete | Export-Csv -Path "C:\Temp\IntuneDevicesToDelete1.csv" -NoTypeInformation

Write-Host "✅ Devices to delete exported to IntuneDevicesToDelete1.csv"
