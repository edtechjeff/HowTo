<#
.SYNOPSIS
Checks whether a list of Entra Device IDs are still active in Intune.
.DESCRIPTION
This script reads a CSV file containing Entra Device IDs, queries Intune for managed devices, and generates a report indicating their status.
#>

# ==== Configuration ====
$InputCsvPath  = "C:\Reports\DeviceList.csv"           # Input CSV with a column "DeviceId"
$OutputCsvPath = "C:\Reports\DeviceStatusReport_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss")

# ==== Connect to Microsoft Graph ====
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Device.Read.All","DeviceManagementManagedDevices.Read.All" | Out-Null

# ==== Load device IDs from CSV ====
if (-not (Test-Path $InputCsvPath)) {
    Write-Host "Input file not found at $InputCsvPath" -ForegroundColor Red
    exit
}

$inputDevices = Import-Csv $InputCsvPath
if (-not ($inputDevices | Get-Member -Name "DeviceId")) {
    Write-Host "CSV must contain a column named 'DeviceId'." -ForegroundColor Red
    exit
}

Write-Host "Loaded $($inputDevices.Count) devices from input file." -ForegroundColor Cyan

# ==== Retrieve Intune devices once ====
Write-Host "Retrieving current Intune managed devices..." -ForegroundColor Cyan
$intuneDevices = Get-MgDeviceManagementManagedDevice -All -Property deviceName,azureADDeviceId,lastSyncDateTime,operatingSystem

# Build hashset for quick matching
$intuneIds = $intuneDevices.azureADDeviceId | Where-Object { $_ } | ForEach-Object { $_.ToLower() }

# ==== Cross-reference ====
$results = foreach ($item in $inputDevices) {
    $entraId = $item.DeviceId.Trim().ToLower()
    $match   = $intuneDevices | Where-Object { $_.azureADDeviceId -eq $entraId }

    if ($match) {
        [pscustomobject]@{
            DeviceId        = $item.DeviceId
            DeviceName      = $match.deviceName
            OperatingSystem = $match.operatingSystem
            LastSync        = $match.lastSyncDateTime
            Status          = "Active in Intune"
        }
    }
    else {
        [pscustomobject]@{
            DeviceId        = $item.DeviceId
            DeviceName      = ""
            OperatingSystem = ""
            LastSync        = ""
            Status          = "Not found / Inactive"
        }
    }
}

# ==== Export results ====
$results | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
Write-Host "`nReport generated: $OutputCsvPath" -ForegroundColor Green

# ==== Optional summary ====
$activeCount = ($results | Where-Object { $_.Status -eq "Active in Intune" }).Count
$inactiveCount = ($results | Where-Object { $_.Status -ne "Active in Intune" }).Count

Write-Host "`nSummary:" -ForegroundColor Yellow
Write-Host "Active in Intune: $activeCount"
Write-Host "Not found / inactive: $inactiveCount"
