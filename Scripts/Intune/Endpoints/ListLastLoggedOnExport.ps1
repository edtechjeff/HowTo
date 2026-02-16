# Requires: Microsoft Graph PowerShell SDK
# Install once: Install-Module Microsoft.Graph -Scope CurrentUser
# Permissions: AuditLog.Read.All (admin consent)
# Used to pull and export users that were logged on in the last 48 Hours
# HoursBack can be changed

param(
    [int]$HoursBack = 48,
    [string]$OutCsv = ".\UserDeviceSignIns.csv",
    [string]$OutHtml = ".\UserDeviceSignIns.html",
    [int]$MaxRecords = 50000  # safety cap; adjust if you have a large tenant
)

Import-Module Microsoft.Graph.Reports -ErrorAction Stop
Connect-MgGraph -Scopes "AuditLog.Read.All" | Out-Null

$since = (Get-Date).ToUniversalTime().AddHours(-1 * $HoursBack).ToString("o")
$filter = "createdDateTime ge $since"

Write-Host "Pulling sign-ins since (UTC): $since" -ForegroundColor Cyan

# Pull sign-ins. -All can be heavy; we cap with MaxRecords to avoid pulling millions.
$raw = @()
$batch = Get-MgAuditLogSignIn -Filter $filter -Top 999 -All -ErrorAction Stop

foreach ($item in $batch) {
    $raw += $item
    if ($raw.Count -ge $MaxRecords) { break }
}

if (-not $raw) {
    Write-Host "No sign-ins found in the last $HoursBack hours." -ForegroundColor Yellow
    return
}

# Flatten to useful fields
$events = $raw | ForEach-Object {
    [pscustomobject]@{
        CreatedDateTime = $_.CreatedDateTime
        UserUPN         = $_.UserPrincipalName
        UserDisplayName = $_.UserDisplayName
        DeviceName      = $_.DeviceDetail.DisplayName
        DeviceId        = $_.DeviceDetail.DeviceId
        OS              = $_.DeviceDetail.OperatingSystem
        Browser         = $_.DeviceDetail.Browser
        ClientAppUsed   = $_.ClientAppUsed
        IpAddress       = $_.IpAddress
        StatusCode      = $_.Status.ErrorCode
        FailureReason   = $_.Status.FailureReason
    }
} | Where-Object {
    # Keep only sign-ins that have at least a UPN
    $_.UserUPN
}

# 1) “Latest per user+device” summary (what you usually want)
$latestPerUserDevice =
    $events |
    Sort-Object CreatedDateTime -Descending |
    Group-Object UserUPN, DeviceId, DeviceName |
    ForEach-Object { $_.Group | Select-Object -First 1 } |
    Sort-Object UserUPN, DeviceName

# Export CSV
$latestPerUserDevice | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $OutCsv
Write-Host "CSV written: $OutCsv" -ForegroundColor Green

# Optional HTML report (nice to email/share)
$latestPerUserDevice |
    Select-Object UserUPN, UserDisplayName, DeviceName, OS, ClientAppUsed, CreatedDateTime, IpAddress |
    ConvertTo-Html -Title "User → Device sign-ins (last $HoursBack hours)" -PreContent "<h2>User → Device sign-ins (last $HoursBack hours)</h2><p>Generated: $(Get-Date)</p>" |
    Out-File -Encoding UTF8 $OutHtml

Write-Host "HTML written: $OutHtml" -ForegroundColor Green

# Quick on-screen view
$latestPerUserDevice |
    Select-Object UserUPN, DeviceName, OS, ClientAppUsed, CreatedDateTime |
    Format-Table -AutoSize
