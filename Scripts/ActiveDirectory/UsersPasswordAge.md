# Script to tell you if an accounts password is older than 60 days

```powershell
# Import the Active Directory module (if not already loaded)
Import-Module ActiveDirectory

# Set threshold in days
$Days = 60
$Threshold = (Get-Date).AddDays(-$Days)

# Find users with passwords older than threshold
Get-ADUser -Filter * -Properties DisplayName, SamAccountName, PasswordLastSet, Enabled |
    Where-Object { $_.Enabled -eq $true -and $_.PasswordLastSet -lt $Threshold } |
    Select-Object DisplayName, SamAccountName, PasswordLastSet |
    Sort-Object PasswordLastSet
```
