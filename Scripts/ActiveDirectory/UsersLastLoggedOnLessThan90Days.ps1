# Define the number of days to check for activity
$daysActive = 90

# Calculate the date 90 days ago
$activeDate = (Get-Date).AddDays(-$daysActive)

# Import the Active Directory module
Import-Module ActiveDirectory

# Find all users who have logged on in the last 90 days
$activeUsers = Get-ADUser -Filter {LastLogonDate -ge $activeDate} -Properties LastLogonDate |
               Select-Object Name, SamAccountName, LastLogonDate |
               Sort-Object LastLogonDate -Descending

# Display the results
$activeUsers | Format-Table -AutoSize
