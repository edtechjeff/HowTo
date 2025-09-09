# Number of days to check for recent logons
$daysActive = 30

# Cutoff date for comparison
$activeDate = (Get-Date).AddDays(-$daysActive)

# Get all computers with LastLogonDate on or after the cutoff
$recentComputers = Get-ADComputer -Filter {LastLogonDate -ge $activeDate} -Properties LastLogonDate |
    Select-Object Name, LastLogonDate |
    Sort-Object LastLogonDate -Descending

# Display the results
if ($recentComputers) {
    Write-Host "Devices that have logged on in the last $daysActive days:" -ForegroundColor Green
    $recentComputers | Format-Table -AutoSize
} else {
    Write-Host "No devices have logged on in the last $daysActive days." -ForegroundColor Yellow
}
