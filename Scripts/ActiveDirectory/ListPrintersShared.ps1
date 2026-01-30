# Define output file
$outputFile = "C:\Temp\Printers_Shares.csv"

# Retrieve ONLY shared printers
$printers = Get-Printer |
    Where-Object { $_.Shared -eq $true } |
    Select-Object Name, Shared, ShareName, DriverName, PortName, Published

# Build results
$results = foreach ($printer in $printers) {
    [PSCustomObject]@{
        PrintServerName = $printServerName
        Shared        = $printer.Shared
        ShareName     = $printer.ShareName
        PublishedToAD = $printer.Published
        # DriverName    = $printer.DriverName
        # PortName      = $printer.PortName
    }
}

# Print to screen
$results | Format-Table -AutoSize

# Export to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Shared printer list exported to $outputFile"
