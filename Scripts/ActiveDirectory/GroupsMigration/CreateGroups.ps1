# Import Active Directory module
Import-Module ActiveDirectory

# Define input CSV file
$inputFile = "C:\Temp\AD_Groups_Members.csv"

# Import CSV
$groupData = Import-Csv -Path $inputFile

foreach ($group in $groupData) {
    $groupName = $group."GroupName"   # Explicitly reference the column

    # Check if group exists, if not create it
    if (-not (Get-ADGroup -Filter { Name -eq $groupName })) {
        New-ADGroup -Name $groupName -GroupScope Global -Path "OU=YourOU,DC=YourDomain,DC=com"
        Write-Host "Created group: $groupName"
    } else {
        Write-Host "Group $groupName already exists, skipping..."
    }
}
