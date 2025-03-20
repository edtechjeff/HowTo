# Import Active Directory module (if not already available)
Import-Module ActiveDirectory

# Get all distribution groups (non-security groups)
$distributionGroups = Get-ADGroup -Filter {GroupCategory -eq "Distribution"} -Properties Name, SamAccountName, Mail

# Define output file path
$csvPath = "C:\Temp\DistributionGroups.csv"

# Export to CSV
$distributionGroups | Select-Object Name, SamAccountName, Mail | Export-Csv -Path $csvPath -NoTypeInformation

# Confirm completion
Write-Host "Export completed. File saved to: $csvPath"
