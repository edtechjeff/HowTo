# Sript to find stale devices in Azure AD using Microsoft Graph API
# This script requires the Microsoft Graph PowerShell SDK to be installed.
# Install the Microsoft Graph PowerShell SDK if not already installed
# Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
# Install Modules
Connect-MgGraph -Scopes "Directory.Read.All"

# Set the threshold to 90 days ago
$cutoffDate = (Get-Date).AddDays(-90)

# Get all devices
$devices = Get-MgDevice -All

# Filter devices that have not signed in in over 90 days or have never signed in
$staleDevices = $devices | Where-Object {
    ($_.ApproximateLastSignInDateTime -eq $null) -or ($_.ApproximateLastSignInDateTime -lt $cutoffDate)
}

# Select relevant properties
$result = $staleDevices | Select-Object DisplayName, Id, DeviceId, AccountEnabled, ApproximateLastSignInDateTime

# Export to CSV
$result | Export-Csv -Path "C:\temp2\DevicesNotSignedIn90Days.csv" -NoTypeInformation

# Disconnect from Microsoft Graph
Disconnect-MgGraph