# Define the number of days for recent logon
$days = 30

# Calculate the date 30 days ago
$cutoffDate = (Get-Date).AddDays(-$days)

# Import the Active Directory module
Import-Module ActiveDirectory

# Find all users who HAVE logged on in the last 30 days
$recentUsers = Get-ADUser -Filter {LastLogonDate -gt $cutoffDate} -Properties LastLogonDate |
               Select-Object Name, SamAccountName, LastLogonDate |
               Sort-Object LastLogonDate -Descending

# Display the results
$recentUsers | Format-Table -AutoSize
