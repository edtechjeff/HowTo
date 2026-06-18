
    # Get all managed devices
    $managedDevices = Get-MgDeviceManagementManagedDevice -All -ErrorAction Stop

    # ✅ Filter only Windows devices
    $windowsDevices = $managedDevices | Where-Object { $_.OperatingSystem -eq "Windows" }

    Write-Host "Total devices found: $($managedDevices.Count)" -ForegroundColor Cyan
    Write-Host "Windows devices to sync: $($windowsDevices.Count)" -ForegroundColor Green

    # Synchronize each Windows device
    foreach ($device in $windowsDevices) {
        try {
            Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $device.Id -ErrorAction Stop
            Write-Host "Invoking Intune Sync for $($device.DeviceName)" -ForegroundColor Yellow
        }
        catch {
            Write-Error "Failed to sync device $($device.DeviceName). Error: $_"
        }
    }
