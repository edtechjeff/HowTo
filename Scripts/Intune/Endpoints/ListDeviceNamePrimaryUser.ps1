# Make sure you have the Microsoft Graph PowerShell SDK installed
# Install-Module Microsoft.Graph -Scope AllUsers

# Connect to Microsoft Graph (you'll be prompted to sign in)
Connect-MgGraph -Scopes "Device.Read.All","User.Read.All"

# Get all managed devices from Intune
$devices = Get-MgDeviceManagementManagedDevice -All

# Create an array to hold results
$results = @()

foreach ($device in $devices) {
    # Try to get the primary user of the device
    $primaryUser = $null
    try {
        $user = Get-MgDeviceManagementManagedDeviceUser -ManagedDeviceId $device.Id -ErrorAction SilentlyContinue
        if ($user) {
            $primaryUser = $user.UserPrincipalName
        }
    } catch {
        $primaryUser = "N/A"
    }

    $results += [pscustomobject]@{
        DeviceName   = $device.DeviceName
        PrimaryUser  = $primaryUser
    }
}

# Display results in table
$results | Format-Table -AutoSize

# Export to CSV if desired
$results | Export-Csv -Path "c:\temp\IntuneDevicesAndPrimaryUsers.csv" -NoTypeInformation -Encoding UTF8