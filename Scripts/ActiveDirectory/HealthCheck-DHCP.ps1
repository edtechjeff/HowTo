<#
.SYNOPSIS
    DHCP Health Check Script
.DESCRIPTION
    Checks service status, scopes, utilization, failover, event logs, and backup state.
    Works on Windows Server 2012+ with DHCP RSAT or role installed.
#>

# Imports the DHCP Server module
Import-Module DhcpServer -ErrorAction Stop


# ---------- Setup ----------
$ErrorActionPreference = "SilentlyContinue"
$dhcpServer = $env:COMPUTERNAME
Write-Host "Starting DHCP Health Check on $dhcpServer..." -ForegroundColor Cyan

# ---------- 1. Check Service Status ----------
$service = Get-Service -Name DHCPServer -ErrorAction SilentlyContinue
if ($service.Status -eq "Running") {
    Write-Host "`n[Service] DHCP Server service is running and set to $($service.StartType)" -ForegroundColor Green
} else {
    Write-Host "`n[Service] DHCP Server service is NOT running!" -ForegroundColor Red
}

# ---------- 2. Check Authorized DHCP Servers ----------
Write-Host "`n[Authorization] Authorized DHCP Servers:" -ForegroundColor Yellow
netsh dhcp show server | Select-String "DHCP Server"

# ---------- 3. List Scopes and Utilization ----------
Write-Host "`n[Scopes]" -ForegroundColor Yellow
$scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer
if ($scopes) {
    $stats = Get-DhcpServerv4ScopeStatistics -ComputerName $dhcpServer
    $stats | ForEach-Object {
        $color = if ($_.PercentageInUse -lt 70) { "Green" } elseif ($_.PercentageInUse -lt 90) { "Yellow" } else { "Red" }
        Write-Host ("Scope {0,-15} - {1,3}% In Use ({2}/{3} leases)" -f $_.ScopeId, $_.PercentageInUse, $_.InUse, ($_.InUse + $_.Available)) -ForegroundColor $color
    }
} else {
    Write-Host "No IPv4 scopes found on this server." -ForegroundColor DarkGray
}

# ---------- 4. Check Failover Relationships ----------
Get-DhcpServerv4Failover -ComputerName $dhcpServer -Verbose

# ---------- 5. Review Recent Errors ----------
Write-Host "`n[Event Log] Recent Errors (last 24 hours)" -ForegroundColor Yellow
$events = Get-WinEvent -LogName "Microsoft-Windows-DHCP-Server/Operational" -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Critical','Error' -and $_.TimeCreated -gt (Get-Date).AddHours(-24) } |
    Select-Object TimeCreated, Id, LevelDisplayName, Message -First 5
if ($events) {
    $events | Format-Table -AutoSize
} else {
    Write-Host "No DHCP errors found in the last 24 hours." -ForegroundColor Green
}

# ---------- 6. Check Database & Backup ----------
Write-Host "`n[Database & Backup]" -ForegroundColor Yellow
$db = Get-DhcpServerDatabase -ComputerName $dhcpServer
$bk = Get-DhcpServerDatabaseBackup -ComputerName $dhcpServer
Write-Host "Database Path: $($db.FileName)" -ForegroundColor Gray
Write-Host "Backup Path:   $($bk.Path)" -ForegroundColor Gray
Write-Host "Last Backup:   $($bk.BackupDate)" -ForegroundColor Gray

# ---------- 7. Optional Audit Log Review ----------
$dhcpLog = "C:\Windows\System32\Dhcp\DhcpSrvLog-$((Get-Date).ToString('ddd')).log"
if (Test-Path $dhcpLog) {
    Write-Host "`n[Audit Log] Last 20 entries from $dhcpLog" -ForegroundColor Yellow
    Get-Content $dhcpLog -Tail 20
} else {
    Write-Host "No DHCP audit log found at $dhcpLog" -ForegroundColor DarkGray
}

# ---------- Summary ----------
Write-Host "`nDHCP Health Check Completed for $dhcpServer" -ForegroundColor Cyan
