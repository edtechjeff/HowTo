# Define the output directory
$outputDir = "C:\Temp"

# Ensure the output directory exists
if (-Not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Get the date 90 days ago
$90DaysAgo = (Get-Date).AddDays(-90)

# Helper function to extract CN from distinguished names
function Get-GroupNames($memberOf) {
    if ($memberOf) {
        return ($memberOf | ForEach-Object { ($_ -split ',')[0] -replace '^CN=' }) -join ", "
    } else {
        return ""
    }
}

# Inactive users
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $90DaysAgo} -Properties LastLogonDate, MemberOf, DistinguishedName | 
    Select-Object Name, LastLogonDate, 
        @{Name="Groups";Expression={Get-GroupNames $_.MemberOf}}, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Disabled users
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false} -Properties Enabled, MemberOf, DistinguishedName | 
    Select-Object Name, Enabled, 
        @{Name="Groups";Expression={Get-GroupNames $_.MemberOf}}, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Inactive and disabled users
$inactiveDisabledUsers = Get-ADUser -Filter {Enabled -eq $false -and LastLogonDate -lt $90DaysAgo} -Properties LastLogonDate, Enabled, MemberOf, DistinguishedName | 
    Select-Object Name, LastLogonDate, Enabled, 
        @{Name="Groups";Expression={Get-GroupNames $_.MemberOf}}, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Users with administrative roles
$adminGroups = @("Domain Admins", "Enterprise Admins", "Administrators", "Account Operators", "Server Operators", "Backup Operators")
$adminUsers = Get-ADUser -Filter * -Properties MemberOf, DistinguishedName | Where-Object {
    ($_.MemberOf | ForEach-Object { ($_ -split ',')[0] -replace '^CN=' }) -match ($adminGroups -join '|')
} | Select-Object Name, 
        @{Name="Groups";Expression={Get-GroupNames $_.MemberOf}}, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Users with passwords set to never expire
$neverExpireUsers = Get-ADUser -Filter * -Properties PasswordNeverExpires, MemberOf, DistinguishedName | Where-Object {
    $_.PasswordNeverExpires -eq $true
} | Select-Object Name, 
        @{Name="PasswordNeverExpires";Expression={$_.PasswordNeverExpires}}, 
        @{Name="Groups";Expression={Get-GroupNames $_.MemberOf}}, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Inactive computer accounts (devices)
$inactiveDevices = Get-ADComputer -Filter {LastLogonDate -lt $90DaysAgo} -Properties LastLogonDate, DistinguishedName | 
    Select-Object Name, LastLogonDate, 
        @{Name="OU";Expression={($_.DistinguishedName -replace '^CN=.*?,', '') -replace ',DC=.*',''}}

# Export CSVs
$inactiveUsers = $inactiveUsers | ForEach-Object { $_ }
$inactiveUsers | Export-Csv -Path "$outputDir\InactiveUsers.csv" -NoTypeInformation

$disabledUsers = $disabledUsers | ForEach-Object { $_ }
$disabledUsers | Export-Csv -Path "$outputDir\DisabledUsers.csv" -NoTypeInformation

$inactiveDisabledUsers = $inactiveDisabledUsers | ForEach-Object { $_ }
$inactiveDisabledUsers | Export-Csv -Path "$outputDir\InactiveDisabledUsers.csv" -NoTypeInformation

$adminUsers = $adminUsers | ForEach-Object { $_ }
$adminUsers | Export-Csv -Path "$outputDir\AdminUsers.csv" -NoTypeInformation

$neverExpireUsers = $neverExpireUsers | ForEach-Object { $_ }
$neverExpireUsers | Export-Csv -Path "$outputDir\NeverExpireUsers.csv" -NoTypeInformation

$inactiveDevices = $inactiveDevices | ForEach-Object { $_ }
$inactiveDevices | Export-Csv -Path "$outputDir\InactiveDevices.csv" -NoTypeInformation

# Generate HTML report
$htmlReport = @"
<html>
<head>
    <title>Active Directory Report</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Active Directory Report</h1>
"@

function Add-TableSection($title, $headers, $data) {
    $section = "<h2>$title</h2><table><tr>"
    foreach ($header in $headers) { $section += "<th>$header</th>" }
    $section += "</tr>"
    foreach ($row in $data) {
        $section += "<tr>"
        foreach ($header in $headers) { $section += "<td>$($row.$header)</td>" }
        $section += "</tr>"
    }
    $section += "</table>"
    return $section
}

$htmlReport += Add-TableSection "Users who have not logged on in the last 90 days" @("Name", "LastLogonDate", "Groups", "OU") $inactiveUsers
$htmlReport += Add-TableSection "Users who are disabled" @("Name", "Enabled", "Groups", "OU") $disabledUsers
$htmlReport += Add-TableSection "Users who are both disabled and inactive" @("Name", "LastLogonDate", "Enabled", "Groups", "OU") $inactiveDisabledUsers
$htmlReport += Add-TableSection "Users with Administrative Roles" @("Name", "Groups", "OU") $adminUsers
$htmlReport += Add-TableSection "Users with Passwords Set to Never Expire" @("Name", "PasswordNeverExpires", "Groups", "OU") $neverExpireUsers
$htmlReport += Add-TableSection "Inactive Devices (Not Logged In for 90+ Days)" @("Name", "LastLogonDate", "OU") $inactiveDevices

$htmlReport += "</body></html>"

# Save the HTML report
$htmlReport | Out-File -FilePath "$outputDir\ADReport.html" -Encoding utf8
