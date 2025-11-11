<#
.SYNOPSIS
    DNS Health Check Script
.DESCRIPTION
    Generates a timestamped DNS health report in C:\adReports.
    Works on Windows Server DNS role or any RSAT-enabled admin workstation.
#>

# ---------- Setup ----------
$ErrorActionPreference = "SilentlyContinue"
$timestamp     = (Get-Date).ToString("yyyyMMdd-HHmmss")
$reportFolder  = "C:\adReports"
$reportFile    = Join-Path $reportFolder "DNS-Health-$timestamp.txt"

# Ensure folder exists
New-Item -ItemType Directory -Path $reportFolder -Force | Out-Null

# ---------- Header ----------
"=========================================================" | Out-File $reportFile
" DNS Health Report                                        " | Out-File $reportFile -Append
" Generated: $(Get-Date)                                   " | Out-File $reportFile -Append
"=========================================================" | Out-File $reportFile -Append
"" | Out-File $reportFile -Append

try {
    $dnsServer = $env:COMPUTERNAME

    # ---------- 1. Service ----------
    "=== Service Status ===" | Out-File $reportFile -Append
    $dnsService = Get-Service -Name DNS -ErrorAction SilentlyContinue
    if ($null -ne $dnsService) {
        "Service Name : $($dnsService.DisplayName)" | Out-File $reportFile -Append
        "Status       : $($dnsService.Status)" | Out-File $reportFile -Append
        "Start Type   : $($dnsService.StartType)" | Out-File $reportFile -Append
    } else {
        "DNS Server role not installed on this system." | Out-File $reportFile -Append
        throw "No DNS role found"
    }

    # ---------- 2. Zones ----------
    "`n=== DNS Zones ===" | Out-File $reportFile -Append
    $zones = Get-DnsServerZone -ComputerName $dnsServer
    if ($zones) {
        $zones | Select-Object ZoneName, ZoneType, IsDsIntegrated |
            Format-Table | Out-String | Out-File $reportFile -Append
    } else {
        "No DNS zones found on this server." | Out-File $reportFile -Append
    }

    # ---------- 3. Forwarders ----------
    "`n=== Forwarders ===" | Out-File $reportFile -Append
    $forwarders = Get-DnsServerForwarder -ComputerName $dnsServer
    if ($forwarders) {
        $forwarders | Format-Table IPAddress, UseRecursion | Out-String | Out-File $reportFile -Append
    } else {
        "No forwarders configured; server is using root hints for recursion." | Out-File $reportFile -Append
    }

    # ---------- 4. Root Hints ----------
    "`n=== Root Hints ===" | Out-File $reportFile -Append
    $rootHints = Get-DnsServerRootHint -ComputerName $dnsServer
    if ($rootHints) {
        "Root hints count: $($rootHints.Count)" | Out-File $reportFile -Append
    } else {
        "No root hints configured!" | Out-File $reportFile -Append
    }

    # ---------- 5. Resolution Tests ----------
    "`n=== Resolution Tests ===" | Out-File $reportFile -Append
    $testNames = @("www.microsoft.com", "www.google.com", "time.windows.com")
    foreach ($testName in $testNames) {
        try {
            $res = Resolve-DnsName $testName -Server $dnsServer -ErrorAction Stop
            "✔ $testName -> $($res.IPAddress -join ', ')" | Out-File $reportFile -Append
        } catch {
            "✖ $testName -> FAILED" | Out-File $reportFile -Append
        }
    }

    # ---------- 6. Event Log Errors ----------
    "`n=== Recent DNS Errors (last 24 hours) ===" | Out-File $reportFile -Append
    $events = Get-WinEvent -LogName "Microsoft-Windows-DNS-Server/Operational" -ErrorAction SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Critical','Error' -and $_.TimeCreated -gt (Get-Date).AddHours(-24) } |
        Select-Object TimeCreated, Id, Message -First 10
    if ($events) {
        $events | Format-Table -AutoSize | Out-String | Out-File $reportFile -Append
    } else {
        "No DNS errors found in the last 24 hours." | Out-File $reportFile -Append
    }

    # ---------- 7. Server Settings ----------
    "`n=== Server Settings ===" | Out-File $reportFile -Append
    $settings = Get-DnsServerSetting -ComputerName $dnsServer -All
    "ListenAddresses : $($settings.ListenAddresses -join ', ')" | Out-File $reportFile -Append
    "Forwarders      : $($settings.Forwarders -join ', ')" | Out-File $reportFile -Append
    "LogFilePath     : $($settings.LogFilePath)" | Out-File $reportFile -Append

} catch {
    "`nError occurred: $_" | Out-File $reportFile -Append
}

# ---------- Footer ----------
"" | Out-File $reportFile -Append
"=========================================================" | Out-File $reportFile -Append
" Report saved to: $reportFile" | Out-File $reportFile -Append
"=========================================================" | Out-File $reportFile -Append

Write-Host "`nDNS Health Report saved to:" -ForegroundColor Cyan
Write-Host $reportFile -ForegroundColor Yellow
