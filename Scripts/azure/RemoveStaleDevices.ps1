# PowerShell script to remove stale devices from Azure AD that have not signed in for 90 days or more.
# This script requires the Microsoft Graph PowerShell SDK to be installed.  

Connect-MgGraph -Scopes "Device.ReadWrite.All", "Directory.Read.All"

# Import the CSV generated earlier
$devicesToRemove = Import-Csv -Path "C:\temp2\DevicesNotSignedIn90Days.csv"

foreach ($device in $devicesToRemove) {
    try {
        Write-Host "Removing device: $($device.DisplayName) [$($device.Id)]" -ForegroundColor Yellow
        Remove-MgDevice -DeviceId $device.Id -ErrorAction Stop
        Write-Host "Successfully removed $($device.DisplayName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to remove $($device.DisplayName): $_" -ForegroundColor Red
    }
}
# Disconnect from Microsoft Graph
Disconnect-MgGraph
