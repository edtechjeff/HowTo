# Script to export all Group Policies out of Active Directory into Current Working Directory

```powershell
Import-Module GroupPolicy

$exportPath = (Get-Location).Path

foreach ($gpo in (Get-GPO -All)) {
    $file = Join-Path $exportPath "$($gpo.DisplayName -replace '[\\/:*?""<>|]', '_').xml"
    Get-GPOReport -Guid $gpo.Id -ReportType Xml | Out-File -Encoding UTF8 $file
    Write-Host "Exported $($gpo.DisplayName) -> $file"
}
```

# Script to search all policies that were exported and look for policies with Software Installations

```powershell
$results = foreach ($file in Get-ChildItem -Filter *.xml) {
    [xml]$xml = Get-Content $file

    # Look for MSI applications in the Computer section
    $compApps = $xml.GPO.Computer.ExtensionData.Extension.MsiApplication
    foreach ($app in $compApps) {
        [PSCustomObject]@{
            FileName    = $file.Name
            GPOName     = $xml.GPO.Name
            Scope       = "Computer"
            AppName     = $app.Name
            PackagePath = $app.Path
        }
    }

    # Look for MSI applications in the User section
    $userApps = $xml.GPO.User.ExtensionData.Extension.MsiApplication
    foreach ($app in $userApps) {
        [PSCustomObject]@{
            FileName    = $file.Name
            GPOName     = $xml.GPO.Name
            Scope       = "User"
            AppName     = $app.Name
            PackagePath = $app.Path
        }
    }
}

# Show results
$results | Format-Table -AutoSize

# Export to CSV
$results | Export-Csv ".\GPO_AssignedApplications.csv" -NoTypeInformation