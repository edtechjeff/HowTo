$csvPath = "F:\path\to\file.csv"
$cleanedCsvPath = Join-Path -Path (Split-Path $csvPath) -ChildPath ("Cleaned_" + (Split-Path $csvPath -Leaf))

# Import the original CSV
$csv = Import-Csv -Path $csvPath

# Clean FolderPath values
foreach ($row in $csv) {
    $row.FolderPath = $row.FolderPath -replace '^"+|"+$', ''  # Remove leading/trailing quotes
}

# Export the cleaned CSV
$csv | Export-Csv -Path $cleanedCsvPath -NoTypeInformation

Write-Output "Cleaned CSV saved to $cleanedCsvPath"
