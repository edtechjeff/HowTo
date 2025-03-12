$PrinterName = "\\servername\printer.name"

$Printer = Get-Printer | Where-Object { $_.Name -eq $PrinterName }

if ($Printer) {
    Write-Host "Printer '$PrinterName' does NOT exist on this system."
    exit 1
} else {
    Write-Host "Printer '$PrinterName' exists on this system."
    exit 0
}
