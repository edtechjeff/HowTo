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
        foreach ($member in $members) {
            # Check if the member is a user
            $user = Get-ADUser -Filter { SamAccountName -eq $member } -ErrorAction SilentlyContinue
            # Check if the member is a group
            $adGroup = Get-ADGroup -Filter { Name -eq $member } -ErrorAction SilentlyContinue

            if ($user) {
                Add-ADGroupMember -Identity $groupName -Members $user
                Write-Host "Added user $member to $groupName"
            } elseif ($adGroup) {
                Add-ADGroupMember -Identity $groupName -Members $adGroup
                Write-Host "Added group $member to $groupName"
            } else {
                Write-Host "Member $member not found, skipping..."
            }
        }
    } else {
        Write-Host "Group $groupName does not exist, skipping member addition..."
    }
}