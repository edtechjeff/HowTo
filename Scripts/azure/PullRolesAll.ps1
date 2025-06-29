# Connect with the right scopes
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "PrivilegedAccess.Read.AzureAD", "User.Read.All"

# Get all eligible PIM role assignments (Entra ID)
$eligibles = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -All

# Get all role definitions to match by ID later
$roleDefs = Get-MgRoleManagementDirectoryRoleDefinition -All

# Process and build report
$results = foreach ($e in $eligibles) {
    try {
        $user = Get-MgUser -UserId $e.PrincipalId -ErrorAction Stop
        $roleDef = $roleDefs | Where-Object { $_.Id -eq $e.RoleDefinitionId }

        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            RoleName          = $roleDef.DisplayName
            AssignmentType    = "Eligible"
        }
    } catch {
        Write-Warning "Skipping: Could not resolve PrincipalId $($e.PrincipalId)"
    }
}

# Output the result
$results | Format-Table
# Optional: Export
# $results | Export-Csv -Path "PIM_EligibleUsers.csv" -NoTypeInformation
