<#
.SYNOPSIS
Retrieves full Entra (Azure AD) device object details for a list of Device IDs.

.DESCRIPTION
Reads a CSV containing Entra Device IDs (column name: DeviceId), queries Entra via Microsoft Graph,
and exports selected device object details into a CSV report.
#>

# ==== Configuration ====
$InputCsvPath  = "C:\Reports\DevicesNoSync.csv"                  # Input CSV path
$OutputCsvPath = "C:\Reports\EntraDeviceDetails_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss")

# ==== Connect to Microsoft Graph ====
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Device.Read.All","Directory.Read.All" | Out-Null

# ==== Validate input file ====
if (-not (Test-Path $InputCsvPath)) {
    Write-Host "Input file not found at $InputCsvPath" -ForegroundColor Red
    exit
}

$inputDevices = Import-Csv $InputCsvPath
if (-not ($inputDevices | Get-Member -Name "DeviceId")) {
    Write-Host "CSV must contain a column named 'DeviceId'." -ForegroundColor Red
    exit
}

Write-Host "Loaded $($inputDevices.Count) Device IDs from input file." -ForegroundColor Cyan

# ==== Retrieve Entra device details ====
$results = foreach ($item in $inputDevices) {
    $deviceId = $item.DeviceId.Trim()

    try {
        $entraDevice = Get-MgDevice -Filter "deviceId eq '$deviceId'" -ErrorAction Stop

        foreach ($d in $entraDevice) {
            [PSCustomObject]@{
                DeviceId                         = $d.deviceId
                ObjectId                         = $d.Id
                DisplayName                      = $d.DisplayName
                AccountEnabled                   = $d.AccountEnabled
                OperatingSystem                  = $d.OperatingSystem
                OperatingSystemVersion            = $d.OperatingSystemVersion
                TrustType                        = $d.TrustType
                DeviceOwnership                  = $d.DeviceOwnership
                IsCompliant                      = $d.IsCompliant
                IsManaged                        = $d.IsManaged
                ApproximateLastSignInDateTime     = $d.ApproximateLastSignInDateTime
                PhysicalIds                       = ($d.PhysicalIds -join "; ")
                RegistrationDateTime              = $d.RegistrationDateTime
                SystemLabels                      = ($d.SystemLabels -join "; ")
                Extensions                        = ($d.AdditionalProperties | ConvertTo-Json -Compress)
            }
        }
    }
    catch {
        Write-Host "❌ Device not found in Entra: $deviceId" -ForegroundColor Yellow
        [PSCustomObject]@{
            DeviceId     = $deviceId
            ObjectId     = ""
            DisplayName  = ""
            AccountEnabled = ""
            OperatingSystem = ""
            Status       = "Not found in Entra"
        }
    }
}

# ==== Export results ====
$results | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Report generated:`n$OutputCsvPath" -ForegroundColor Green
