# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All", "Directory.Read.All"

# Get only security groups (not mail-enabled, not Microsoft 365 groups)
$groups = Get-MgGroup -Filter "securityEnabled eq true and mailEnabled eq false" -All

# Prepare an array to store the result
$groupResults = @()

# Loop through each group and get member count
foreach ($group in $groups) {
    Write-Host "Processing group: $($group.DisplayName)"
    
    # Get member count
    try {
        $members = Get-MgGroupMember -GroupId $group.Id -All
        $memberCount = $members.Count
    } catch {
        $memberCount = 0
    }

    # Add to results
    $groupResults += [PSCustomObject]@{
        GroupName   = $group.DisplayName
        GroupId     = $group.Id
        GroupType   = "Security"
        MemberCount = $memberCount
    }
}

# Output to screen
$groupResults | Format-Table -AutoSize

# Optionally export to CSV
$groupResults | Export-Csv -Path "C:\temp\SecurityGroupMembershipReport.csv" -NoTypeInformation