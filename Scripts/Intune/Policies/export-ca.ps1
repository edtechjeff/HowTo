<#
    .SYNOPSIS
    Export-CAPolicies.ps1

    .DESCRIPTION
    Export Conditional Access policies to JSON files for backup purposes.

    .LINK
    www.alitajran.com/export-conditional-access-policies/

    .NOTES
    Written by: ALI TAJRAN
    Website:    www.alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 11/16/2023 - Initial version
#>

# Connect to Microsoft Graph API
Connect-MgGraph -Scopes 'Policy.Read.All'

# Export path for CA policies
$ExportPath = "C:\temp\"

try {
    # Retrieve all conditional access policies from Microsoft Graph API
    $AllPolicies = Get-MgIdentityConditionalAccessPolicy -All

    if ($AllPolicies.Count -eq 0) {
        Write-Host "There are no CA policies found to export." -ForegroundColor Yellow
    }
    else {
        # Iterate through each policy
        foreach ($Policy in $AllPolicies) {
            try {
                # Get the display name of the policy
                $PolicyName = $Policy.DisplayName
            
                # Convert the policy object to JSON with a depth of 6
                $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
            
                # Write the JSON to a file in the export path
                $PolicyJSON | Out-File "$ExportPath\$PolicyName.json" -Force
            
                # Print a success message for the policy backup
                Write-Host "Successfully backed up CA policy: $($PolicyName)" -ForegroundColor Green
            }
            catch {
                # Print an error message for the policy backup
                Write-Host "Error occurred while backing up CA policy: $($Policy.DisplayName). $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}
catch {
    # Print a generic error message
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}