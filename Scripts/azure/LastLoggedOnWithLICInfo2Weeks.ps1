Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All", "User.Read.All"

# Set the date range to the last two weeks
$twoWeeksAgo = (Get-Date).AddDays(-14)

# Fetch sign-in logs for the last two weeks
$logons = Get-MgAuditLogSignIn -Filter "createdDateTime ge $($twoWeeksAgo.ToString('yyyy-MM-ddTHH:mm:ssZ'))" -All

# Prepare the result with unique UPNs only
$users = $logons | Select-Object -Property @{Name="UserPrincipalName";Expression={$_.UserPrincipalName}},
                                        @{Name="ObjectId";Expression={$_.UserId}} |
    Sort-Object UserPrincipalName -Unique

# Fetch license details for each user
$results = foreach ($user in $users) {
    $licenses = Get-MgUserLicenseDetail -UserId $user.ObjectId 2>$null
    $skuNames = if ($licenses) { ($licenses | Select-Object -ExpandProperty SkuPartNumber) -join ";" } else { "No License Assigned" }
    
    [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        ObjectId          = $user.ObjectId
        Licenses          = $skuNames
    }
}

# Export the result to CSV
$results | Export-Csv -Path "C:\temp2\UsersLoggedOn.csv" -NoTypeInformation


# Disconnect from Microsoft Graph
Disconnect-MgGraph