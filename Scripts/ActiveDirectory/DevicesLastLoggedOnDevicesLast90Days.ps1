# Define the number of days to check
$daysActive = 60

# Calculate the date threshold
$activeDate = (Get-Date).AddDays(-$daysActive)

# Import Active Directory module
Import-Module ActiveDirectory

# Get computers with a recent lastLogonDate
$activeComputers = Get-ADComputer -Filter {LastLogonDate -ge $activeDate} -Properties LastLogonDate |
                   Select-Object Name, LastLogonDate |
                   Sort-Object LastLogonDate -Descending

# Display the result
$activeComputers | Format-Table -AutoSize
