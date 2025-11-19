# Number of days to check for recent logons
$daysActive = 30

# Cutoff date
$activeDate = (Get-Date).AddDays(-$daysActive)

# Get computers with LastLogonDate in the last 30 days
$recentComputers = Get-ADComputer `
    -Filter {LastLogonDate -ge $activeDate} `
    -Properties LastLogonDate |
    Select-Object Name, LastLogonDate |
    Sort-Object LastLogonDate -Descending

# Display results
if ($recentComputers) {
    Write-Host "Devices that have logged on in the last $daysActive days:" -ForegroundColor Green
    $recentComputers | Format-Table -AutoSize
} else {
    Write-Host "No devices have logged on in the last $daysActive days." -ForegroundColor Yellow
}

# Optional: export to CSV
$csv = "C:\Temp\Devices_LoggedIn_Last30Days.csv"
$recentComputers | Export-Csv -Path $csv -NoTypeInformation
Write-Host "CSV exported to $csv" -ForegroundColor Cyan
