$PrinterName = "\\servername\printer.name"

# Check if the printer exists
$Printer = Get-Printer | Where-Object { $_.Name -eq $PrinterName }

if ($Printer) {
    Write-Host "Printer '$PrinterName' already exists. No action needed."
    exit 0
} else {
    Write-Host "Printer '$PrinterName' does NOT exist. Adding printer..."
    
    try {
        Add-Printer -Name $PrinterName -ConnectionName $PrinterName
        Write-Host "Printer '$PrinterName' successfully added."
        exit 0
    } catch {
        Write-Host "Failed to add printer '$PrinterName'. Error: $_"
        exit 1
    }
}
