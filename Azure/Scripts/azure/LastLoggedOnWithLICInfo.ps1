Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All", "User.Read.All"

# Fetch all users from Microsoft Graph
$users = Get-MgUser -All -Select UserPrincipalName, Id

# Fetch license details for each user
$results = foreach ($user in $users) {
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id 2>$null
    $skuNames = if ($licenses) { ($licenses | Select-Object -ExpandProperty SkuPartNumber) -join ";" } else { "No License Assigned" }
    
    [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        ObjectId          = $user.Id
        Licenses          = $skuNames
    }
}

# Export the result to CSV
$results | Export-Csv -Path "C:\temp2\AllUsersWithLicenses.csv" -NoTypeInformation

# Disconnect from Microsoft Graph
Disconnect-MgGraph