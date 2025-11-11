# Active Directory Assessment Script
# Creates a report folder and exports key AD data to CSV and TXT files

$reportPath = "C:\ADReports"
New-Item -Path $reportPath -ItemType Directory -Force | Out-Null

# 1. Domain and Forest Info
Get-ADDomain | Select Name, DomainMode | Export-Csv "$reportPath\DomainInfo.csv" -NoTypeInformation
Get-ADForest | Select ForestMode | Export-Csv "$reportPath\ForestInfo.csv" -NoTypeInformation
netdom query fsmo > "$reportPath\FSMORoles.txt"

# 2. Domain Controllers
Get-ADDomainController -Filter * |
    Select-Object HostName, IPv4Address, OperatingSystem, Site |
    Export-Csv "$reportPath\DomainControllers.csv" -NoTypeInformation

# 3. DC Health
Start-Process -FilePath "cmd.exe" -ArgumentList "/c dcdiag /v /c /d /e > $reportPath\DCDiag.txt" -Wait
Start-Process -FilePath "cmd.exe" -ArgumentList "/c repadmin /replsummary > $reportPath\ReplicationSummary.txt" -Wait

# 4. Privileged Groups
$groups = @("Domain Admins", "Enterprise Admins", "Schema Admins", "Administrators")
foreach ($group in $groups) {
    Get-ADGroupMember -Identity $group -Recursive |
        Select Name, SamAccountName, ObjectClass |
        Export-Csv "$reportPath\$($group.Replace(' ', ''))_Members.csv" -NoTypeInformation
}

# 5. Stale/Insecure Accounts
Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 |
    Select Name, LastLogonDate |
    Export-Csv "$reportPath\StaleUsers.csv" -NoTypeInformation

Get-ADUser -Filter {PasswordNeverExpires -eq $true} |
    Select Name, SamAccountName |
    Export-Csv "$reportPath\PasswordNeverExpires.csv" -NoTypeInformation

Get-ADUser -Filter {Enabled -eq $false} |
    Select Name, SamAccountName |
    Export-Csv "$reportPath\DisabledUsers.csv" -NoTypeInformation

# 6. GPO Summary
Get-GPO -All |
    Select DisplayName, GpoStatus, CreationTime, ModificationTime |
    Export-Csv "$reportPath\AllGPOs.csv" -NoTypeInformation

# 7. Service Accounts with SPNs
Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName |
    Select Name, SamAccountName, ServicePrincipalName |
    Export-Csv "$reportPath\ServiceAccounts_SPNs.csv" -NoTypeInformation

# 8. OUs and Protection Status
Get-ADOrganizationalUnit -Filter * -Properties ProtectedFromAccidentalDeletion |
    Select-Object Name, DistinguishedName, ProtectedFromAccidentalDeletion |
    Export-Csv "$reportPath\OrganizationalUnits.csv" -NoTypeInformation

# 9. AD Recycle Bin Status
$recycleBinStatus = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes
$recycleBinStatus | Out-File "$reportPath\RecycleBinStatus.txt"

Write-Host "AD Assessment report generated in: $reportPath" -ForegroundColor Green