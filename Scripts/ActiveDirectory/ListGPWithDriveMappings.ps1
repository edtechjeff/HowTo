Import-Module GroupPolicy

$results = @()

$gpos = Get-GPO -All

foreach ($gpo in $gpos) {

    $xmlText = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    [xml]$xml = $xmlText

    # Find ALL Drive nodes anywhere in the report (namespace-safe)
    $driveNodes = $xml.SelectNodes("//*[local-name()='Drive']")

    foreach ($drive in $driveNodes) {

        # Most common structure: Drive -> Properties attributes
        $props = $drive.SelectSingleNode("./*[local-name()='Properties']")

        if ($props -and $props.Path -and $props.Letter) {
            $results += [PSCustomObject]@{
                GPOName     = $gpo.DisplayName
                DriveLetter = $props.Letter
                Path        = $props.Path
                Action      = $props.Action
            }
        }
    }
}

if (-not $results) {
    Write-Host "No mapped drives found via GPO report XML. If you *know* they exist, run the debug steps below." -ForegroundColor Yellow
} else {
    $results | Sort-Object GPOName, DriveLetter | Format-Table -AutoSize
}
