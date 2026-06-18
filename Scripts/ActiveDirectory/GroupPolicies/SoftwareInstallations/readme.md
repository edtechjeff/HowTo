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
$rawResults = foreach ($file in Get-ChildItem -Filter *.xml) {
    [xml]$xml = Get-Content $file

    foreach ($scope in @('Computer','User')) {
        $extData = $xml.GPO.$scope.ExtensionData.Extension
        if (-not $extData) { continue }

        foreach ($ext in $extData) {
            if (-not $ext.MsiApplication) { continue }

            foreach ($app in $ext.MsiApplication) {
                [PSCustomObject]@{
                    FileName    = $file.Name
                    GPOName     = $xml.GPO.Name
                    Scope       = $scope
                    AppName     = $app.Name
                    PackagePath = $app.Path
                }
            }
        }
    }
}

# Deduplicate by logical identity
$results = $rawResults |
    Sort-Object GPOName, Scope, AppName, PackagePath -Unique

# Display
$results | Format-Table -AutoSize

# Export
$results | Export-Csv ".\GPO_AssignedApplications.csv" -NoTypeInformation
```

# Added to pull the link informaton

## Step 1: Pull Live Link Info
```powershell
Import-Module GroupPolicy

$gpoLinks = foreach ($ou in Get-ADOrganizationalUnit -Filter *) {
    $inheritance = Get-GPInheritance -Target $ou.DistinguishedName
    foreach ($link in $inheritance.GpoLinks) {
        [PSCustomObject]@{
            GPOName     = $link.DisplayName
            TargetOU   = $ou.DistinguishedName
            LinkEnabled = $link.Enabled
            Enforced    = $link.Enforced
        }
    }
}

# Add Domain root links
$domain = (Get-ADDomain).DistinguishedName
$inheritance = Get-GPInheritance -Target $domain
foreach ($link in $inheritance.GpoLinks) {
    $gpoLinks += [PSCustomObject]@{
        GPOName     = $link.DisplayName
        TargetOU   = $domain
        LinkEnabled = $link.Enabled
        Enforced    = $link.Enforced
    }
}
```

## Step 2: Join MSI data with Link Data
```powershell
$finalResults = foreach ($item in $results) {

    $links = $gpoLinks | Where-Object { $_.GPOName -eq $item.GPOName }

    if ($links) {
        foreach ($link in $links) {
            $item | Select-Object *,
                @{Name="LinkTarget";Expression={$link.TargetOU}},
                @{Name="LinkEnabled";Expression={$link.LinkEnabled}},
                @{Name="Enforced";Expression={$link.Enforced}}
        }
    }
    else {
        $item | Select-Object *,
            @{Name="LinkTarget";Expression={"Not linked"}},
            @{Name="LinkEnabled";Expression={$false}},
            @{Name="Enforced";Expression={$false}}
    }
}
```

## Step 3: Export
```powershell
$finalResults | Export-Csv ".\GPO_AssignedApplications_WithLinks.csv" -NoTypeInformation
```
