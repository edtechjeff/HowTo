$packageId = "Google.GoogleDrive"
$logFile = "C:\ProgramData\ZoomUninstall-Winget.log"

function Write-Log {
    param ([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

function Get-WingetPath {
    try {
        $wingetPath = (Get-Command winget.exe -ErrorAction SilentlyContinue).Source
        if (-not $wingetPath) {
            $wingetStorePath = Get-ChildItem "C:\Program Files\WindowsApps\" -Filter "Microsoft.DesktopAppInstaller*_x64__8wekyb3d8bbwe" -ErrorAction SilentlyContinue |
                               Sort-Object LastWriteTime -Descending |
                               Select-Object -First 1

            if ($wingetStorePath) {
                $wingetExe = Join-Path $wingetStorePath.FullName "winget.exe"
                if (Test-Path $wingetExe) {
                    return $wingetExe
                }
            }
            return $null
        } else {
            return $wingetPath
        }
    } catch {
        return $null
    }
}

$winget = Get-WingetPath

if (-not $winget) {
    Write-Log "Winget not found. Cannot proceed with uninstall."
    exit 1
} else {
    Write-Log "Winget path resolved: $winget"
}

# Run the uninstall command
try {
    Write-Log "Starting uninstall of $packageId"
    & $winget uninstall --id $packageId --silent --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Log "Zoom uninstalled successfully."
        exit 0
    } else {
        Write-Log "Uninstall failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Log "Exception during uninstall: $_"
    exit 1
}
