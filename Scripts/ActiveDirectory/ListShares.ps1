# -------------------------------
# Local Server Share Inventory
# -------------------------------

# Output file
$outputFile = "C:\Temp\SMB_Shares.csv"

# Ensure output folder exists
New-Item -ItemType Directory -Path (Split-Path $outputFile) -Force | Out-Null

# Get local server name
$serverName = $env:COMPUTERNAME

# Get SMB shares (exclude default/admin shares)
$shares = Get-CimInstance -ClassName Win32_Share |
    Where-Object {
        $_.Name -notmatch '^\w\$$' -and $_.Name -notin @('ADMIN$', 'IPC$', 'print$', 'prnproc$')
    } |
    Select-Object `
        @{Name='ServerName'; Expression={$serverName}},
        @{Name='ShareName';  Expression={$_.Name}},
        @{Name='SharePath';  Expression={$_.Path}}

# ----- Output to screen -----
$shares | Sort-Object ShareName | Format-Table -AutoSize

# ----- Export to CSV -----
$shares | Sort-Object ShareName |
    Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "`nShare inventory exported to $outputFile"
