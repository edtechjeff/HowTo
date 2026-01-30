# Detect Desktop Icons settings (HKCU)
# Exit 0 = keys exist and are correct
# Exit 1 = missing or incorrect

$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

$required = @(
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", # This PC
    "{59031a47-3f72-44a7-89c5-5595fe6b30ee}", # User Files
    "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}", # Network
    "{645FF040-5081-101B-9F08-00AA002F954E}"  # Recycle Bin
)

if (-not (Test-Path $path)) {
    Write-Host "Keys do not exist (registry path missing): $path"
    exit 1
}

foreach ($name in $required) {
    try {
        $val = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
        if ($val -ne 0) {
            Write-Host "Keys do not exist or are incorrect: $name is '$val' (expected 0)"
            exit 1
        }
    }
    catch {
        Write-Host "Keys do not exist: missing value name $name"
        exit 1
    }
}

Write-Host "Key exist (all desktop icon settings present and set to 0)"
exit 0
