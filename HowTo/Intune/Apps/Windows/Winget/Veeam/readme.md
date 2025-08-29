# Process to get Veeam Standalone Desktop Client Installed
# For this process I opted to set this up instead of a application deployment, this process can be used as a detection remediation script

## Command to Install Veeam as a system account via RMM type of tool
```Powershell
# Find the latest winget.exe (App Installer package) when running as SYSTEM
$winget = Get-ChildItem "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*__8wekyb3d8bbwe\winget.exe" -Recurse -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName

if (-not $winget) {
    Write-Host "winget.exe not found. Ensure App Installer (Microsoft.DesktopAppInstaller) is installed."
    exit 1
}

# Refresh sources (important on first run as SYSTEM)
& $winget source update --disable-interactivity | Out-Null

# Install Veeam Agent silently, auto-accepting agreements
& $winget install --id Veeam.VeeamAgent `
  --accept-source-agreements --accept-package-agreements `
  --silent --disable-interactivity

# Return exit code for RMM
exit $LASTEXITCODE
```

## Detection Script
```Powershell
# Detect-VeeamAgent.ps1
# Compliant if Veeam Agent for Microsoft Windows is installed

$ErrorActionPreference = 'Stop'

function Test-VeeamInstalled {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($p in $paths) {
        if (Test-Path $p) {
            $apps = Get-ChildItem $p | ForEach-Object {
                Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            }
            $hit = $apps | Where-Object {
                $_.DisplayName -match 'Veeam Agent for Microsoft Windows'
            }
            if ($hit) { return $true }
        }
    }
    return $false
}

if (Test-VeeamInstalled) {
    Write-Output "Veeam Agent is installed."
    exit 0   # compliant
} else {
    Write-Output "Veeam Agent is NOT installed."
    exit 1   # not compliant -> trigger remediation
}
```

## Remediation Script
```Powershell
# Remediate-VeeamAgent.ps1
# Install Veeam Agent using winget when running as SYSTEM

$ErrorActionPreference = 'Stop'
$LogRoot = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
if (-not (Test-Path $LogRoot)) { New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null }
$Log = Join-Path $LogRoot 'Remediation-VeeamAgent.log'

function Write-Log($msg) {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$ts  $msg" | Tee-Object -FilePath $Log -Append
}

function Get-WingetPath {
    # Try App Installer registration first (fastest/cleanest)
    try {
        $pkg = Get-AppxPackage -AllUsers Microsoft.DesktopAppInstaller -ErrorAction Stop
        $exe = Join-Path $pkg.InstallLocation 'winget.exe'
        if (Test-Path $exe) { return $exe }
    } catch { }

    # Fallback: scan WindowsApps
    $glob = 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*__8wekyb3d8bbwe\winget.exe'
    $found = Get-ChildItem $glob -Recurse -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
    if ($found) { return $found }

    return $null
}

function Test-VeeamInstalled {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $apps = Get-ChildItem $p | ForEach-Object {
                Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            }
            $hit = $apps | Where-Object {
                $_.DisplayName -match 'Veeam Agent for Microsoft Windows'
            }
            if ($hit) { return $true }
        }
    }
    return $false
}

try {
    Write-Log "Starting remediation: ensure Veeam Agent is installed."

    if (Test-VeeamInstalled) {
        Write-Log "Veeam Agent already installed. Exiting compliant."
        exit 0
    }

    $winget = Get-WingetPath
    if (-not $winget) {
        Write-Log "ERROR: winget.exe (App Installer) not found. Install Microsoft.DesktopAppInstaller first."
        exit 1
    }

    # Seed/refresh sources for the SYSTEM profile (avoids first-run prompts)
    Write-Log "Refreshing winget sources..."
    & $winget source update --disable-interactivity | Tee-Object -FilePath $Log -Append
    if ($LASTEXITCODE -ne 0) { Write-Log "WARN: winget source update exit code $LASTEXITCODE" }

    # Install Veeam Agent silently & non-interactively
    $args = @(
        'install','--id','Veeam.VeeamAgent',
        '--accept-source-agreements','--accept-package-agreements',
        '--silent','--disable-interactivity'
    )
    Write-Log "Running: winget $($args -join ' ')"
    & $winget @args | Tee-Object -FilePath $Log -Append
    $code = $LASTEXITCODE
    Write-Log "winget install exit code: $code"

    # Small wait to allow registration to complete
    Start-Sleep -Seconds 10

    if (Test-VeeamInstalled) {
        Write-Log "SUCCESS: Veeam Agent is now installed."
        exit 0
    } else {
        Write-Log "ERROR: Veeam Agent still not detected after install."
        exit 1
    }
}
catch {
    Write-Log "EXCEPTION: $($_.Exception.Message)"
    exit 1
}
```

