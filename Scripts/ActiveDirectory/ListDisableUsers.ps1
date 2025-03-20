# Import the Active Directory module
Import-Module ActiveDirectory

# Get a list of disabled users
$DisabledUsers = Get-ADUser -Filter {Enabled -eq $false} -Properties SamAccountName, Name, UserPrincipalName, Enabled

# Export the list to a CSV file
$DisabledUsers | Select-Object SamAccountName, Name, UserPrincipalName, Enabled | Export-Csv -Path "C:\DisabledUsers.csv" -NoTypeInformation

Write-Host "Disabled users exported to C:\DisabledUsers.csv"
