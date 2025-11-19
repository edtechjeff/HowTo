$DriverName = "KONICA MINOLTA Universal PCL"

try {
    $driver = Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue
} catch {}

if ($driver) {
    Write-Host "Driver already installed."
    exit 0
} else {
    Write-Host "Driver NOT installed."
    exit 1
}