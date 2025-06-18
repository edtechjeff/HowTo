# Connect to Graph with required permission
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.ReadWrite.All"

# Import the CSV generated from the previous script
$devicesToDelete = Import-Csv -Path "C:\Temp\IntuneDevicesToDelete.csv"

foreach ($device in $devicesToDelete) {
    try {
        Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $device.DeviceId -ErrorAction Stop
        Write-Host "Deleted device: $($device.DeviceName) with ID: $($device.DeviceId)"
    } catch {
        Write-Warning "Failed to delete device $($device.DeviceName): $_"
    }
}
