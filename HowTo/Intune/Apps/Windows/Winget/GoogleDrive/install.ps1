# Define the package ID for Zoom
$packageId = "Zoom.Zoom"
$logFile = "C:\ProgramData\ZoomInstall-Winget.log"

function Write-Log {
    param ([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

# Try to resolve winget path
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
    }
    catch {
        return $null
    }
}

# Resolve the winget path
$winget = Get-WingetPath

if (-not $winget) {
    Write-Log "Winget.exe not found. Ensure App Installer is available in the system context."
    exit 1
} else {
    Write-Log "Using winget at: $winget"
}

# Attempt to install Zoom
try {
    Write-Log "Starting silent install for $packageId"
    & $winget install --id $packageId --silent --accept-package-agreements --accept-source-agreements --exact

    if ($LASTEXITCODE -eq 0) {
        Write-Log "Zoom installed successfully."
        exit 0
    } else {
        Write-Log "Zoom install failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
catch {
    Write-Log "Exception during install: $_"
    exit 1
}
