# Import the required module
Import-Module Microsoft.Graph

# Define all required variables at the beginning
$scopes = "Device.Read.All", "Group.ReadWrite.All"  # Adjust scopes as needed

# Authenticate to Microsoft Graph
Connect-MgGraph -Scopes $scopes

# Get the current year
$currentYear = (Get-Date).Year

# Get a list of Devices in Entra ID
$list = Get-MgDevice -All -Property DisplayName, DeviceId, Id, ApproximateLastSignInDateTime |
    Select-Object DisplayName, DeviceId, Id, ApproximateLastSignInDateTime |
    Where-Object {
        # Only include devices where the year of ApproximateLastSignInDateTime is NOT the current year
        # Also handle null values (never signed in)
        ($_.ApproximateLastSignInDateTime -eq $null) -or
        ($_.ApproximateLastSignInDateTime.Year -ne $currentYear)
    }

# Define output file path
$OutputFile = "C:\Temp\Devices_NotSignedIn_$currentYear.csv"

# Export the result to CSV
$list | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "CSV export complete: $OutputFile"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
