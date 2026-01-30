$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$valueName    = "TaskbarAl"
$value        = 0

# Ensure the registry path exists
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Create or update the value
New-ItemProperty `
    -Path $registryPath `
    -Name $valueName `
    -Value $value `
    -PropertyType DWORD `
    -Force | Out-Null

Write-Host "Remediation complete. Taskbar Start Menu set to Left."
exit 0
