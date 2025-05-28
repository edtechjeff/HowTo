# This script will force initiate Intune Sync on all Intune managed devices where the device name starts with 'DESKTOP-'.
# Ensure you have the necessary permissions to run this script and that the Microsoft.Graph.DeviceManagement module is installed.
try {
    # Connect to Microsoft Graph
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.PrivilegedOperations.All", "DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementManagedDevices.Read.All" -ErrorAction Stop

    # Get all managed devices
    $managedDevices = Get-MgDeviceManagementManagedDevice -All -ErrorAction Stop

    # Filter devices where name starts with 'DESKTOP-'
    $filteredDevices = $managedDevices | Where-Object { $_.DeviceName -like "DESKTOP-*" }

    foreach ($device in $filteredDevices) {
        try {
            Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $device.Id -ErrorAction Stop
            Write-Host "Invoking Intune Sync for $($device.DeviceName)" -ForegroundColor Yellow
        }
        catch {
            Write-Error "Failed to sync device $($device.DeviceName). Error: $_"
        }
    }
}
catch {
    Write-Error "An error occurred. Error: $_"
}