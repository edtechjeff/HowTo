# Winget to Install applications in Intune

## In the following documentation you will find examples of how you can install and detect applications via Winget. 

## The basic script used as part of detection script

```
# Search both HKLM and HKCU for all uninstall keys
$paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$application = "*Mozilla Firefox*"

foreach ($path in $paths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like $application } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation
}
```

