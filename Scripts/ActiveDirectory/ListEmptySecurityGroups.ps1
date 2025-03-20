Import-Module ActiveDirectory

# Get all security groups
$groups = Get-ADGroup -Filter "GroupCategory -eq 'Security'" | Select-Object Name, DistinguishedName

# Initialize an array to store empty groups
$emptyGroups = @()

foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group.DistinguishedName -ErrorAction SilentlyContinue
    if (-not $members) {
        $emptyGroups += [PSCustomObject]@{
            Name = $group.Name
            DistinguishedName = $group.DistinguishedName
        }
    }
}

# Output the empty groups
$emptyGroups | Format-Table -AutoSize

# Optionally, export to CSV
#$emptyGroups | Export-Csv -Path "C:\Temp\EmptySecurityGroups.csv" -NoTypeInformation
