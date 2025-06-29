# Connect to Microsoft Graph (with appropriate scopes)
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All"

# Get all directory roles (e.g., Global Admin, User Admin, etc.)
$roles = Get-MgDirectoryRole

# Create a list to store role assignments
$results = @()

foreach ($role in $roles) {
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
    foreach ($member in $members) {
        $results += [PSCustomObject]@{
            DisplayName       = $member.AdditionalProperties.displayName
            UserPrincipalName = $member.AdditionalProperties.userPrincipalName
            RoleName          = $role.DisplayName
        }
    }
}

# Export to CSV
$results | Export-Csv -Path "c:\temp\AzureAD_AssignedRoles.csv" -NoTypeInformation

# Optional: show results in console
$results | Format-Table