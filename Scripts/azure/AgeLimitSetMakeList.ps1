# Requires Microsoft.Graph module
# Install-Module Microsoft.Graph -Scope AllUsers

# Connect with read permissions (User.Read.All is enough for export)
Connect-MgGraph -Scopes "User.Read.All"

# Get all users that have AgeGroup set to 'minor'
$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AgeGroup | Where-Object { $_.AgeGroup -eq "minor" }

# Select useful fields
$export = $users | Select-Object DisplayName, UserPrincipalName, AgeGroup

# Ensure output folder exists
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory | Out-Null
}

# Export to CSV
$export | Export-Csv -Path "C:\Temp\AzureAD-Users-AgeGroup-Minor.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Export complete. File saved to C:\Temp\AzureAD-Users-AgeGroup-Minor.csv"
# Disconnect the session
Disconnect-MgGraph