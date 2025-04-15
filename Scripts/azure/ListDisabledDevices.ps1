# PowerShell script to list all disabled devices in Azure AD and export the results to a CSV file.
# This script requires the Microsoft Graph PowerShell SDK to be installed.
# Install the Microsoft Graph PowerShell SDK if not already installed
# Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
# Install Modules
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All"

# Get all devices
$devices = Get-MgDevice -All

# Filter for disabled device accounts
$disabledDevices = $devices | Where-Object { $_.AccountEnabled -eq $false }

# Select relevant properties
$result = $disabledDevices | Select-Object DisplayName, Id, DeviceId, AccountEnabled, ApproximateLastSignInDateTime

# Export to CSV
$result | Export-Csv -Path "C:\temp2\DisabledDevices.csv" -NoTypeInformation

# Disconnect from Microsoft Graph
Disconnect-MgGraph
