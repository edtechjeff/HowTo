# Connect to Microsoft Graph if not already connected
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "User.Read.All"

# Fetch all role assignments (includes users, groups, service principals)
$roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -All

# Fetch all role definitions (to get role names)
$roleDefinitions = Get-MgRoleManagementDirectoryRoleDefinition -All | Select-Object Id, DisplayName

# Convert role definitions into a hashtable for quick lookup
$roleDefLookup = @{}
foreach ($role in $roleDefinitions) {
    $roleDefLookup[$role.Id] = $role.DisplayName
}

# Fetch all users (to get UserPrincipalName)
$users = Get-MgUser -All -Property Id, UserPrincipalName | Select-Object Id, UserPrincipalName

# Process role assignments and match them to users
$results = foreach ($assignment in $roleAssignments) {
    $user = $users | Where-Object { $_.Id -eq $assignment.PrincipalId }
    if ($user) {
        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            ObjectId          = $user.Id
            RoleAssigned      = $roleDefLookup[$assignment.RoleDefinitionId]
        }
    }
}

# Export the result to CSV
$results | Export-Csv -Path "C:\temp2\UsersWithRoles.csv" -NoTypeInformation

Write-Host "Export complete: C:\temp2\UsersWithRoles.csv"

# Disconnect from Microsoft Graph
Disconnect-MgGraph