Import-Module ActiveDirectory -ErrorAction Stop

$domain = Get-ADDomain
$forest = Get-ADForest

$dcs = Get-ADDomainController -Filter * | Sort-Object HostName

# DNS servers: try to discover from each DC (WinRM); otherwise fall back to DC IPs
$dnsServers = foreach ($dc in $dcs) {
    try {
        Invoke-Command -ComputerName $dc.HostName -ErrorAction Stop -ScriptBlock {
            Get-DnsClientServerAddress -AddressFamily IPv4 |
                Where-Object { $_.ServerAddresses } |
                Select-Object -ExpandProperty ServerAddresses
        }
    } catch {
        $null
    }
}

if (-not $dnsServers) {
    $dnsServers = $dcs | Select-Object -ExpandProperty IPv4Address
}
$dnsServers = $dnsServers | Where-Object { $_ } | Sort-Object -Unique

$gcServers = $forest.GlobalCatalogs | Sort-Object

$domainAdmins = Get-ADGroupMember -Identity "Domain Admins" -Recursive |
    Where-Object { $_.objectClass -eq "user" } |
    Sort-Object SamAccountName |
    Select-Object SamAccountName

$rodcList = $dcs | Where-Object { $_.IsReadOnly } | Sort-Object HostName

# --- Summary block ---
$summary = [PSCustomObject]@{
    "AD Full Name (DNS)"          = $domain.DNSRoot
    "AD Short Name (NetBIOS)"     = $domain.NetBIOSName
    "Forest Functional Level"     = $forest.ForestMode
    "Domain Functional Level"     = $domain.DomainMode
    "PDC Emulator"                = $domain.PDCEmulator
    "Schema Master"               = $forest.SchemaMaster
    "Domain Naming Master"        = $forest.DomainNamingMaster
    "RID Master"                  = $domain.RIDMaster
    "Infrastructure Master"       = $domain.InfrastructureMaster
}

Write-Host ""
Write-Host "=== Active Directory Report ===" -ForegroundColor Cyan
Write-Host ""
$summary | Format-List

Write-Host ""
Write-Host "Domain Controllers:" -ForegroundColor Yellow
$dcs | Select-Object HostName, IPv4Address, Site, IsGlobalCatalog, IsReadOnly | Format-Table -AutoSize

Write-Host ""
Write-Host "DNS Servers (IPv4):" -ForegroundColor Yellow
$dnsServers | ForEach-Object { Write-Host " - $_" }

Write-Host ""
Write-Host "Global Catalog Servers:" -ForegroundColor Yellow
$gcServers | ForEach-Object { Write-Host " - $_" }

Write-Host ""
Write-Host "Domain Admins (users only, recursive):" -ForegroundColor Yellow
$domainAdmins | Format-Table -AutoSize

Write-Host ""
Write-Host "Read-Only Domain Controllers (RODCs):" -ForegroundColor Yellow
if ($rodcList) {
    $rodcList | Select-Object HostName, IPv4Address, Site | Format-Table -AutoSize
} else {
    Write-Host " - None found" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
