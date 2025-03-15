# Import Active Directory module (if not already loaded)
Import-Module ActiveDirectory

# Define output file
$outputFile = "C:\Temp\AD_Groups_Members.csv"

# Excluded default groups
$excludedGroups = @(
    "Domain Admins", "Enterprise Admins", "Schema Admins", "Administrators", "Users",
    "Guests", "Domain Users", "Domain Guests", "Pre-Windows 2000 Compatible Access",
    "Authenticated Users", "Everyone"
)

# Retrieve groups excluding default groups
$groups = Get-ADGroup -Filter * | Where-Object { $_.Name -notin $excludedGroups } | Select-Object Name, DistinguishedName

# Initialize an array to store results
$results = @()

foreach ($group in $groups) {
    # Get members
    $members = Get-ADGroupMember -Identity $group.DistinguishedName -ErrorAction SilentlyContinue

    # Skip groups with no members
    if (-not $members) { continue }

    # Convert members to a semicolon-separated list
    $memberList = ($members | ForEach-Object { $_.SamAccountName }) -join ";"

    # Store the result as an object
    $results += [PSCustomObject]@{
        GroupName  = $group.Name
        Members    = $memberList
    }
}

# Export to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Filtered group membership list exported to $outputFile"