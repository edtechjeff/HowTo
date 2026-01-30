# Remediate Desktop Icons settings (HKCU)
# Sets required values to 0 (show icons)

$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

$icons = @{
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" = 0 # This PC
    "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" = 0 # User Files
    "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" = 0 # Network
    "{645FF040-5081-101B-9F08-00AA002F954E}" = 0 # Recycle Bin
}

# Ensure path exists
if (!(Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Create/update values
foreach ($name in $icons.Keys) {
    New-ItemProperty -Path $path -Name $name -Value $icons[$name] -PropertyType DWord -Force | Out-Null
}

Write-Host "Remediation applied: Desktop icon registry values set to 0."

# Restart Explorer to apply immediately (optional but helpful)
try {
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Write-Host "Explorer restarted."
}
catch {
    Write-Host "Could not restart Explorer (may not be running or permissions issue)."
}
