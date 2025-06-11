# Connect to Microsoft Graph with appropriate scope
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Confirm beta profile is used (Autopilot is only in beta)
Select-MgProfile -Name "beta"

# Load CSV file (with header: SerialNumber)
$csvPath = "C:\Path\To\SerialNumbers.csv"
$serials = Import-Csv -Path $csvPath

foreach ($entry in $serials) {
    $serial = $entry.SerialNumber.Trim()
    Write-Host "Looking for serial: $serial"

    # Get Autopilot devices and match by serial
    $devices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All
    $device = $devices | Where-Object { $_.SerialNumber -eq $serial }

    if ($device) {
        # Set Group Tag
        Update-MgDeviceManagementWindowsAutopilotDeviceIdentity `
            -WindowsAutopilotDeviceIdentityId $device.Id `
            -GroupTag "shared"

        Write-Host "✔ Group tag 'shared' applied to $serial" -ForegroundColor Green
    } else {
        Write-Host "⚠ Serial $serial not found in Autopilot" -ForegroundColor Yellow
    }
}
