# Install Modules and Connect to Microsoft Graph
# This script retrieves all devices in a specified Azure AD security group and exports their details to a CSV file.
Install-Module Microsoft.Graph -Scope CurrentUser

Connect-MgGraph -Scopes "Device.Read.All", "GroupMember.Read.All"

# Define Security Group ID
$GroupId = "<GroupID>"

# Get all members of the security group (IDs only)
$groupMembers = Get-MgGroupMember -GroupId $GroupId -All

# Get all devices in Azure AD (to match against group members)
$allDevices = Get-MgDevice -All

# Cross-reference the group members with devices
$deviceList = foreach ($member in $groupMembers) {
    $device = $allDevices | Where-Object { $_.Id -eq $member.Id }
    if ($device) {
        [PSCustomObject]@{
            DeviceName  = $device.DisplayName
            ObjectID    = $device.Id
            DeviceID    = $device.DeviceId
            LastCheckIn = $device.ApproximateLastSignInDateTime
        }
    }
}

# Export to CSV
$deviceList | Export-Csv -Path "c:\temp\AzureSecurityGroupDevices.csv" -NoTypeInformation

# Output results to console
$deviceList
