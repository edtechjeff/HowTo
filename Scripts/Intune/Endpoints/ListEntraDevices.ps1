# Get a list of device in Entra ID

# Import the required module
Import-Module Microsoft.Graph

# Define all required variables at the beginning
$scopes = "Device.Read.All", "Group.ReadWrite.All"  # Adjust scopes as needed

# Authenticate to Microsoft Graph
Connect-MgGraph -Scopes $scopes

# Get a list of Devices in AzureAD
$list = Get-MgDevice -All -Property DisplayName, DeviceId, Id, ApproximateLastSignInDateTime | Select-Object DisplayName, DeviceId, Id, ApproximateLastSignInDateTime

# Define output file path
$OutputFile = "C:\Temp\FullDeviceList.csv"

# Export the result to CSV
$List | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "CSV export complete: $OutputFile"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
