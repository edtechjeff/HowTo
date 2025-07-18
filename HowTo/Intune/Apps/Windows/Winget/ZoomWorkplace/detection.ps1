# Check both standard and WOW6432Node uninstall registry paths
$zoomFound = $false

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $registryPaths) {
    $subKeys = Get-ChildItem $path -ErrorAction SilentlyContinue
    foreach ($subKey in $subKeys) {
        $displayName = (Get-ItemProperty $subKey.PSPath -ErrorAction SilentlyContinue).DisplayName
        if ($displayName -like "*Zoom*") {
            Write-Output "Zoom detected: $displayName"
            $zoomFound = $true
            break
        }
    }
}

if ($zoomFound) {
    exit 0  # Detected
} else {
    Write-Output "Zoom not detected"
    exit 1  # Not detected
}
