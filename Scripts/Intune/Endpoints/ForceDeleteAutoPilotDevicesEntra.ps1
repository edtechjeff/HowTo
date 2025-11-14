# Note: Reason for this script was because devices were showing up in Entra as devices in AutoPilot but not in Intune.
# Intune would not allow deletion of these devices since they were not present there.

# Requires the Microsoft.Graph module
# Connect to Graph with required permission
Connect-MgGraph -Scopes "Device.ReadWrite.All"

# Specify the device ID to delete
$deviceId = "ObjectID-of-the-device-to-delete"

# Delete the device
Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/devices/$deviceId"

# Confirm deletion
Write-Host "Deleted device $deviceId" -ForegroundColor Green
