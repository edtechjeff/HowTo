# Requires Microsoft.Graph module
# Install-Module Microsoft.Graph -Scope AllUsers

# Connect with write permissions
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Import the list of users you previously exported (those with AgeGroup=minor)
$users = Import-Csv -Path "C:\Temp\AzureAD-Users-AgeGroup-Minor.csv"

foreach ($user in $users) {
    try {
        Write-Host "Clearing AgeGroup and Consent for $($user.DisplayName) ($($user.UserPrincipalName))..."

        $body = @{
            ageGroup = $null
            consentProvidedForMinor = $null
        } | ConvertTo-Json

        Invoke-MgGraphRequest -Method PATCH `
            -Uri "https://graph.microsoft.com/v1.0/users/$($user.UserPrincipalName)" `
            -Body $body `
            -ContentType "application/json"

        Write-Host "✔ Cleared successfully for $($user.UserPrincipalName)"
    }
    catch {
        Write-Warning "❌ Failed to update $($user.UserPrincipalName): $_"
    }
}

Write-Host "✅ Completed clearing AgeGroup + ConsentProvidedForMinor for all users from CSV."

# Disconnect the session
# Disconnect-MgGraph