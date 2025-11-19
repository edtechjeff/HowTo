# Define the number of days for inactivity
$daysInactive = 90

# Calculate the date 90 days ago
$inactiveDate = (Get-Date).AddDays(-$daysInactive)

# Import the Active Directory module
Import-Module ActiveDirectory

# Find all users who have not logged on in the last 90 days
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $inactiveDate} -Properties LastLogonDate |
    Select-Object Name, SamAccountName, LastLogonDate |
    Sort-Object LastLogonDate

# Export to CSV
$inactiveUsers | Export-Csv -Path "C:\temp\StaleUsers.csv" -NoTypeInformation -Encoding UTF8

# Import the CSV
$users = Import-Csv -Path "C:\temp\StaleUsers.csv"

# Prepare an array to store results
$groupMemberships = @()

foreach ($user in $users) {
    $sam = $user.SamAccountName
    $adUser = Get-ADUser -Identity $sam -Properties MemberOf

    $groups = @()
    if ($adUser.MemberOf) {
        $groups = $adUser.MemberOf | ForEach-Object {
            (Get-ADGroup -Identity $_).Name
        }
    }

    # Add to results
    $groupMemberships += [PSCustomObject]@{
        Name           = $user.Name
        SamAccountName = $sam
        Groups         = ($groups -join '; ')
    }
}

# Export to CSV
$groupMemberships | Export-Csv -Path "C:\temp\StaleUsers_GroupMemberships.csv" -NoTypeInformation -Encoding UTF8
