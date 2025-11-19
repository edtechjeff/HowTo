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
