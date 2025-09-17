# Detection script for ArmorPoint version 3.2.4

$targetVersion = "3.2.4"
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $registryPaths) {
    $subKeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
    foreach ($subKey in $subKeys) {
        $props = Get-ItemProperty -Path $subKey.PSPath -ErrorAction SilentlyContinue
        if ($props.DisplayName -like "*ArmorPoint*") {
            if ($props.DisplayVersion -eq $targetVersion) {
                Write-Host "Application is installed: ArmorPoint version $targetVersion"
                exit 0   # Exit with success
            }
        }
    }
}

Write-Host "ArmorPoint $targetVersion not detected"
exit 1   # Exit with failure
