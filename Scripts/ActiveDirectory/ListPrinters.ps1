# Define output file
$outputFile = "C:\Temp\Printers_Shares.csv"

# Retrieve all printers (include Published)
$printers = Get-Printer | Select-Object Name, Shared, ShareName, DriverName, PortName, Published

# Initialize an array to store results
$results = @()

foreach ($printer in $printers) {
    $results += [PSCustomObject]@{
        PrinterName = $printer.Name
        Shared      = $printer.Shared
        ShareName   = if ($printer.Shared) { $printer.ShareName } else { "Not Shared" }
        PublishedToAD = $printer.Published
        DriverName  = $printer.DriverName
        PortName    = $printer.PortName
    }
}

# Print to screen
$results | Format-Table -AutoSize

# Export to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Printer/share list exported to $outputFile"
