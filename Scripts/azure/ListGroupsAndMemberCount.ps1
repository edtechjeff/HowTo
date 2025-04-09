# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All", "Directory.Read.All"

# Get all groups (you can filter by SecurityEnabled or MailEnabled if needed)
$groups = Get-MgGroup -All

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
        GroupType   = if ($group.SecurityEnabled -and -not $group.MailEnabled) { "Security" } elseif ($group.MailEnabled -and $group.GroupTypes -contains "Unified") { "M365" } else { "Other" }
        MemberCount = $memberCount
    }
}

# Output to screen
$groupResults | Format-Table -AutoSize

# Optionally export to CSV
$groupResults | Export-Csv -Path "c:\temp\GroupMembershipReport.csv" -NoTypeInformation