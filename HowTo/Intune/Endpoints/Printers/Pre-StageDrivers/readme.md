# Method to prestage the drivers for pritners via intune
## Method does work better with V4 drivers

- First download the drivers
- Note the following
    - INF Driver Name
- Folder Structure for Deployment
    - install.ps1
    - uninstall.ps1
    - \driver

## Install.ps1
```powershell
$DriverFolder = "$PSScriptRoot\driver"
$InfFile = Join-Path $DriverFolder "KOAWNJ__.inf"

Write-Host "Installing KONICA MINOLTA Universal PCL driver..."
Write-Host "Driver INF: $InfFile"

# Stage + install driver into driver store
pnputil /add-driver "$InfFile" /install

if ($LASTEXITCODE -eq 0) {
    Write-Host "Driver installed successfully."
    exit 0
} else {
    Write-Host "Driver installation failed with exit code $LASTEXITCODE"
    exit 1
}
```
## Uninstall.ps1
```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$InfFileName = "KOAWNJ__.inf"
$ProviderMatch = "KONICA MINOLTA"

Write-Host "Searching driver store for Konica Minolta Universal PCL..."

# Get the full driver enumeration
$drivers = pnputil /enum-drivers

# Parse blocks for Published Name, Original Name, Provider
$blocks = @()
$current = @()

foreach ($line in $drivers) {
    if ($line -match "^Published Name\s*:") {
        if ($current.Count -gt 0) { $blocks += ,@($current) }
        $current = @($line)
    }
    elseif ($current.Count -gt 0) {
        $current += $line
    }
}
if ($current.Count -gt 0) { $blocks += ,@($current) }

$targets = @()

foreach ($block in $blocks) {
    $published = ""
    $original  = ""
    $provider  = ""

    foreach ($line in $block) {
        if ($line -match "Published Name\s*:\s*(.+)$") { $published = $Matches[1].Trim() }
        if ($line -match "Original Name\s*:\s*(.+)$")  { $original  = $Matches[1].Trim() }
        if ($line -match "Provider Name\s*:\s*(.+)$")  { $provider  = $Matches[1].Trim() }
    }

    if ($published -and ($original -eq $InfFileName -or $provider -like "*$ProviderMatch*")) {
        $targets += [PSCustomObject]@{
            PublishedName = $published
            OriginalName  = $original
            ProviderName  = $provider
        }
    }
}

if ($targets.Count -eq 0) {
    Write-Host "No Konica Minolta driver packages found. Nothing to remove."
    exit 0
}

Write-Host "Found driver packages:"
$targets | Format-Table

# Remove printers using the driver
Write-Host "Removing any printers using Konica Minolta driver..."
Get-Printer -ErrorAction SilentlyContinue | Where-Object {
    $_.DriverName -like "*KONICA*" -or $_.DriverName -like "*MINOLTA*"
} | ForEach-Object {
    Write-Host "Removing printer $($_.Name)..."
    Remove-Printer -Name $_.Name -ErrorAction SilentlyContinue
}

# Remove each driver package
foreach ($t in $targets) {
    Write-Host "Removing driver store package: $($t.PublishedName) (Original: $($t.OriginalName), Provider: $($t.ProviderName))"

    $args = "/delete-driver", $t.PublishedName, "/uninstall", "/force"
    Write-Host "Executing: pnputil $($args -join ' ')"

    $proc = Start-Process -FilePath "pnputil.exe" -ArgumentList $args -PassThru -Wait
    Write-Host "pnputil exit code: $($proc.ExitCode)"
}

Write-Host "Driver removal complete."
exit 0

```

## Script to expand compressed files if they are
```powershell
Get-ChildItem -File | Where-Object { $_.Extension -match '_$' } | ForEach-Object {
    $source = $_.FullName
    $dest = ($_.FullName).TrimEnd('_')  # remove underscore to create correct name

    Write-Host "Expanding $source to $dest"
    expand.exe $source $dest
}
```

## Check to see if the driver was loaded into the driver store
***Note: You will need to change the name tot he name of the driver***
```
pnputil /enum-drivers | findstr /i "konic"
```

## Will come back with something like this
```
Provider Name:      KONICA MINOLTA
```

## Check to see if the driver is detected
***Note:Driver will not be fully loaded till its connected to the printer. Could also be used as detection method for install.***
```powershell
$infName = "KOAWNJ__.inf"

$driver = pnputil /enum-drivers | Select-String -Pattern $infName

if ($driver) {
    Write-Host "Driver INF is present in the driver store."
    exit 0
} else {
    Write-Host "Driver INF not found."
    exit 1
}
```



