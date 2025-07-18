$logPath = "$env:ProgramData\FirefoxUninstall.log"
"Starting Firefox uninstall process at $(Get-Date)" | Out-File -FilePath $logPath -Append

# Registry paths
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$firefoxFound = $false

foreach ($key in $uninstallKeys) {
    $apps = Get-ChildItem -Path $key -ErrorAction SilentlyContinue

    foreach ($app in $apps) {
        $props = Get-ItemProperty -Path $app.PSPath -ErrorAction SilentlyContinue
        if ($props.DisplayName -like "*Mozilla Firefox*") {
            $firefoxFound = $true
            $uninstallString = $props.UninstallString
            "Found Firefox: $($props.DisplayName)" | Out-File -FilePath $logPath -Append
            "Original uninstall string: $uninstallString" | Out-File -FilePath $logPath -Append

            # Extract path properly, accounting for quotes
            if ($uninstallString.StartsWith('"')) {
                $exePath = $uninstallString.Split('"')[1]
            } else {
                $exePath = $uninstallString.Split(' ')[0]
            }

            if (Test-Path $exePath) {
                Start-Process -FilePath $exePath -ArgumentList "/S" -Wait
                "Successfully ran: $exePath /S" | Out-File -FilePath $logPath -Append
            } else {
                "Uninstall EXE not found at $exePath" | Out-File -FilePath $logPath -Append
            }
        }
    }
}

if (-not $firefoxFound) {
    "Mozilla Firefox not found in registry." | Out-File -FilePath $logPath -Append
}

"Firefox uninstall script completed at $(Get-Date)`r`n" | Out-File -FilePath $logPath -Append