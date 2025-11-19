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