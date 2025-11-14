# Scripts for Endpoints

## Query Bitlocker Key on Device
```powershell
(Get-BitLockerVolume).KeyProtector
```

## Query Bitlocker to extract Key
```powershell
(Get-BitLockerVolume).KeyProtector | 
Where-Object KeyProtectorType -eq 'RecoveryPassword' | 
Select-Object -ExpandProperty RecoveryPassword
```

## Query Bitlocker Key and What Drive
```powershell
Get-BitLockerVolume | ForEach-Object {
    $mount = $_.MountPoint
    $_.KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword' | 
    Select-Object @{n='Drive';e={$mount}}, @{n='RecoveryKey';e={$_.RecoveryPassword}}
}
```

## Query Intune devices with or without keys
```powershell
<#
.SYNOPSIS
    Report which Intune Windows devices have a BitLocker recovery key escrowed in Entra ID (Azure AD).

.DESCRIPTION
    - No use of Select-MgProfile (avoids your error).
    - Installs/imports required Microsoft Graph submodules if missing.
    - Connects to Graph (delegated).
    - Enumerates Intune Windows devices, checks BitLocker recovery key *presence*.
    - Outputs a minimal CSV: DeviceName, UserPrincipalName, AzureAdDeviceId, KeysFound, LastKeyCreatedDateTime.

.PARAMETER OutputPath
    Folder path for the CSV output. Defaults to current directory.

.NOTES
    Required delegated permissions:
      - DeviceManagementManagedDevices.Read.All
      - BitLockerKey.ReadBasic.All
#>

[CmdletBinding()]
param(
    [string]$OutputPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

# ---------- Helpers ----------
function Ensure-Module {
    param(
        [Parameter(Mandatory)][string]$Name
    )

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Installing $Name..." -ForegroundColor Yellow
        try {
            if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
                Register-PSRepository -Default
            }
            $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
            if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        } catch {
            Write-Verbose "Could not set PSGallery as Trusted. Proceeding with install..."
        }

        Install-Module $Name -Scope CurrentUser -Force -AllowClobber
    }

    Import-Module $Name -Force
}

# Install/import only what we need — no Select-MgProfile required
Ensure-Module -Name Microsoft.Graph.Authentication
Ensure-Module -Name Microsoft.Graph.DeviceManagement

# Connect (reuse session if possible)
$requiredScopes = @(
    'DeviceManagementManagedDevices.Read.All',
    'BitLockerKey.ReadBasic.All'
)

$ctx = Get-MgContext -ErrorAction SilentlyContinue
if (-not $ctx) {
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes $requiredScopes
} else {
    Write-Host "Reusing existing Microsoft Graph connection to $($ctx.Environment)" -ForegroundColor Cyan
}

# ---------- Data retrieval ----------
Write-Host "Fetching Intune-managed Windows devices..." -ForegroundColor Cyan
$devices = Get-MgDeviceManagementManagedDevice -All -PageSize 200 |
           Where-Object { $_.OperatingSystem -eq 'Windows' }

if (-not $devices) {
    Write-Warning "No Windows managed devices found."
}

$rows = New-Object System.Collections.Generic.List[object]
$idx  = 0

foreach ($d in $devices) {
    $idx++
    Write-Progress -Activity "Checking BitLocker key presence" `
                   -Status "$($d.DeviceName) ($idx of $($devices.Count))" `
                   -PercentComplete (($idx/$devices.Count)*100)

    $aadId = $d.AzureAdDeviceId

    if ([string]::IsNullOrWhiteSpace($aadId)) {
        $rows.Add([pscustomobject]@{
            DeviceName             = $d.DeviceName
            UserPrincipalName      = $d.UserPrincipalName
            AzureAdDeviceId        = $null
            KeysFound              = 0
            LastKeyCreatedDateTime = $null
            Note                   = 'Missing AzureAdDeviceId'
        })
        continue
    }

    # Query recovery key objects for this Azure AD deviceId (no key values)
    $keyObjs = Get-MgInformationProtectionBitlockerRecoveryKey `
                 -Filter "deviceId eq '$aadId'" `
                 -All `
                 -Property "id,deviceId,createdDateTime,volumeType"

    $rows.Add([pscustomobject]@{
        DeviceName             = $d.DeviceName
        UserPrincipalName      = $d.UserPrincipalName
        AzureAdDeviceId        = $aadId
        KeysFound              = ($keyObjs | Measure-Object).Count
        LastKeyCreatedDateTime = ($keyObjs | Sort-Object createdDateTime -Descending |
                                   Select-Object -First 1 -ExpandProperty createdDateTime)
        Note                   = $null
    })
}

# ---------- Output ----------
$timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
$outFile   = Join-Path -Path $OutputPath -ChildPath "BitLocker-KeyPresence-$timestamp.csv"

$rows | Sort-Object DeviceName, AzureAdDeviceId | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outFile

Write-Host ""
Write-Host "Done. CSV written to: $outFile" -ForegroundColor Green
Write-Host ""

# Small on-screen summary
$rows | Group-Object { if ($_.KeysFound -gt 0) {'HasKey'} else {'NoKey'} } |
    Select-Object Name, Count |
    Format-Table -AutoSize
```