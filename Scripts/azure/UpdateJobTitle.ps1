# Connect to MgGraph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Desired job title
$NewJobTitle = "Staff"

# Get all users
$users = Get-MgUser -All -Property Id,UserPrincipalName,JobTitle

foreach ($user in $users) {
    # Split UPN into username and domain
    $username = $user.UserPrincipalName.Split('@')[0]

    if ($username -notmatch '\.') {
        Write-Host "Updating user: $($user.UserPrincipalName)"

        # Update job title
        Update-MgUser -UserId $user.Id -JobTitle $NewJobTitle
    } else {
        Write-Host "Skipping user (username contains '.'): $($user.UserPrincipalName)"
    }
}
