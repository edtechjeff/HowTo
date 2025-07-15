# Mozilla Firefox

## Custom Detecton Script
```
# Define registry paths to search
$paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Define the application name to search for
$applicationName = "*Mozilla Firefox*"
$found = $false

foreach ($path in $paths) {
    $items = Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $applicationName }

    if ($items) {
        Write-Output "Application detected: $($items.DisplayName)"
        exit 0
    }
}

Write-Output "Application not detected"
exit 1
```