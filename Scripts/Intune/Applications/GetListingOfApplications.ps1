# Install MS Graph module if not already installed
if (!(Get-Module -ListAvailable -Name Microsoft.Graph.Intune)) {
    Install-Module Microsoft.Graph.Intune -Force -Scope CurrentUser
}

# Import the module
Import-Module Microsoft.Graph.Intune

# Connect to Graph API (ensure you have the right permissions)
Connect-MgGraph -Scopes "DeviceManagementApps.Read.All"

# Get list of all mobile applications deployed in Intune
$apps = Get-MgDeviceAppManagementMobileApp

# Display results
$apps | Select-Object Id, DisplayName | Format-Table -AutoSize

# Optional: Export to CSV
$apps | Select-Object Id, DisplayName | Export-Csv -Path "c:\temp\Intune_Apps.csv" -NoTypeInformation

# Disconnect from Graph API
Disconnect-MgGraph