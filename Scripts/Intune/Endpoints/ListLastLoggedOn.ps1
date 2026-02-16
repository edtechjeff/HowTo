# Requires: Microsoft Graph PowerShell SDK
# Install once: Install-Module Microsoft.Graph -Scope CurrentUser
# You need: AuditLog.Read.All (admin consent)
# Docs: auditLogs/signIns supports filtering by createdDateTime and userPrincipalName. :contentReference[oaicite:1]{index=1}
# Will prompt you for full user UPN

# Usage
# .\ListLastLoggedOn.ps1 
# .\ListLastLoggedOn.ps1 -UserUPN erikad@contoso.com -HoursBack 72



param(
    [Parameter(Mandatory = $false)]
    [string]$UserUPN,

    [Parameter(Mandatory = $false)]
    [int]$HoursBack = 48,

    [Parameter(Mandatory = $false)]
    [int]$Top = 200
)

# Prompt if not provided
if (-not $UserUPN) {
    $UserUPN = Read-Host "Enter the user's UPN (ex: erikad@contoso.com)"
}

# Connect (interactive). You can also use app-only auth if you want later.
Import-Module Microsoft.Graph.Reports -ErrorAction Stop
Connect-MgGraph -Scopes "AuditLog.Read.All" | Out-Null

$since = (Get-Date).ToUniversalTime().AddHours(-1 * $HoursBack).ToString("o")

# Filter: user + time window (UTC)
$filter = "userPrincipalName eq '$UserUPN' and createdDateTime ge $since"

# Pull sign-ins (most recent first)
$signIns = Get-MgAuditLogSignIn -Filter $filter -Top $Top -All -ErrorAction Stop |
    Sort-Object CreatedDateTime -Descending

if (-not $signIns) {
    Write-Host "No sign-ins found for $UserUPN in the last $HoursBack hours." -ForegroundColor Yellow
    return
}

# Build a "latest per device" view (best answer to: what device + when)
$results = $signIns |
    ForEach-Object {
        [pscustomobject]@{
            CreatedDateTime = $_.CreatedDateTime
            DeviceName      = $_.DeviceDetail.DisplayName
            DeviceId        = $_.DeviceDetail.DeviceId
            ClientAppUsed   = $_.ClientAppUsed
            IpAddress       = $_.IpAddress
            Status          = if ($_.Status) { "$($_.Status.ErrorCode) - $($_.Status.FailureReason)" } else { $null }
        }
    } |
    # Sometimes DeviceName/Id can be empty; group by what we have
    Group-Object -Property DeviceId, DeviceName |
    ForEach-Object {
        $_.Group | Sort-Object CreatedDateTime -Descending | Select-Object -First 1
    } |
    Sort-Object CreatedDateTime -Descending

# Output
$results | Format-Table -AutoSize

# Optional: also show the single most recent sign-in overall
"`nMost recent sign-in:" | Write-Host
($signIns | Select-Object -First 1 |
    Select-Object CreatedDateTime,
                  @{n="DeviceName";e={$_.DeviceDetail.DisplayName}},
                  @{n="DeviceId";e={$_.DeviceDetail.DeviceId}},
                  ClientAppUsed, IpAddress) | Format-List
