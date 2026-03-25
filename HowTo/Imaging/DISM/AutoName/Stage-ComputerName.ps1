param(
    [string]$CsvPath = "Z:\Scripts\AutoName\DeviceNames.csv",
    [string]$OsDrive = ""
)

function Get-OfflineWindowsDrive {
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' }

    foreach ($drive in $drives) {
        $windowsPath = Join-Path $drive.Root "Windows"
        $systemHive  = Join-Path $windowsPath "System32\Config\SYSTEM"

        if ((Test-Path $windowsPath) -and (Test-Path $systemHive)) {
            return $drive.Root.TrimEnd('\')
        }
    }

    return $null
}

function Test-ValidComputerName {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($Name.Length -lt 1 -or $Name.Length -gt 15) {
        return $false
    }

    if ($Name -notmatch '^[A-Za-z0-9-]+$') {
        return $false
    }

    if ($Name.StartsWith('-') -or $Name.EndsWith('-')) {
        return $false
    }

    return $true
}

$LogPath = "Z:\Stage-ComputerName.log"
Start-Transcript -Path $LogPath -Append

$StageFailed = $false

try {
    Write-Host "Starting Stage-ComputerName.ps1"

    if ([string]::IsNullOrWhiteSpace($OsDrive)) {
        $OsDrive = Get-OfflineWindowsDrive
    }

    if (-not $OsDrive) {
        throw "Could not locate the offline Windows installation."
    }

    Write-Host "Offline Windows installation found at: $OsDrive"

    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found at $CsvPath"
    }

    $ServiceTag = (Get-CimInstance Win32_BIOS).SerialNumber.Trim().ToUpper()
    Write-Host "Detected Service Tag: $ServiceTag"

    $DeviceList = Import-Csv -Path $CsvPath
    if (-not $DeviceList) {
        throw "CSV file is empty or unreadable."
    }

    $Match = $DeviceList | Where-Object {
        $_.ServiceTag -and $_.ComputerName -and
        $_.ServiceTag.Trim().ToUpper() -eq $ServiceTag
    } | Select-Object -First 1

    if (-not $Match) {
        Write-Host "No matching Service Tag found in CSV. Skipping computer naming."
        Write-Host "No SetupComplete files will be staged."
        exit 0
    }

    $ComputerName = $Match.ComputerName.Trim()
    Write-Host "Matched computer name: $ComputerName"

    if (-not (Test-ValidComputerName -Name $ComputerName)) {
        throw "Matched computer name '$ComputerName' is invalid."
    }

    $SetupScriptsPath = Join-Path $OsDrive "Windows\Setup\Scripts"
    if (-not (Test-Path $SetupScriptsPath)) {
        New-Item -ItemType Directory -Path $SetupScriptsPath -Force | Out-Null
    }

    $ComputerNameFile = Join-Path $SetupScriptsPath "ComputerName.txt"
    Set-Content -Path $ComputerNameFile -Value $ComputerName -Encoding ASCII -Force
    Write-Host "Wrote computer name to: $ComputerNameFile"

    $SourceSetupComplete = "Z:\Scripts\AutoName\SetupComplete.cmd"
    $SourceApplyScript   = "Z:\Scripts\AutoName\Apply-ComputerName.ps1"

    if (-not (Test-Path $SourceSetupComplete)) {
        throw "SetupComplete.cmd not found at $SourceSetupComplete"
    }

    if (-not (Test-Path $SourceApplyScript)) {
        throw "Apply-ComputerName.ps1 not found at $SourceApplyScript"
    }

    Copy-Item -Path $SourceSetupComplete -Destination (Join-Path $SetupScriptsPath "SetupComplete.cmd") -Force
    Copy-Item -Path $SourceApplyScript   -Destination (Join-Path $SetupScriptsPath "Apply-ComputerName.ps1") -Force

    Write-Host "Copied SetupComplete.cmd and Apply-ComputerName.ps1"
    Write-Host "Computer naming has been staged successfully."
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    $StageFailed = $true
}
finally {
    try { Stop-Transcript } catch {}
}

if ($StageFailed) {
    exit 1
}
else {
    exit 0
}