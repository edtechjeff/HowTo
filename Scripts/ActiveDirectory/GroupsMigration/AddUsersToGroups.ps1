# Import Active Directory module
Import-Module ActiveDirectory

# Define input CSV file
$inputFile = "C:\Temp\AD_Groups_Members.csv"

# Import CSV
$groupData = Import-Csv -Path $inputFile

foreach ($group in $groupData) {
    $groupName = $group."GroupName"   # Explicitly reference the column
    $members = $group."Members" -split ";"

    # Check if group exists
    if (Get-ADGroup -Filter { Name -eq $groupName }) {
        # Add members
        foreach ($member in $members) {
            $user = Get-ADUser -Filter { SamAccountName -eq $member } -ErrorAction SilentlyContinue
            if ($user) {
                Add-ADGroupMember -Identity $groupName -Members $user
                Write-Host "Added $member to $groupName"
            } else {
                Write-Host "User $member not found, skipping..."
            }
        }
    } else {
        Write-Host "Group $groupName does not exist, skipping member addition..."
    }
}
