# Script will detect if TLS 1.2 is enabled or not and will enable

```powershell
Function Get-ADSyncToolsTls12RegValue {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $RegPath,

        [Parameter(Mandatory=$true, Position=1)]
        [string] $RegName
    )
    $regItem = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore
    $output = "" | Select-Object Path, Name, Value
    $output.Path = $RegPath
    $output.Name = $RegName
    $output.Value = if ($regItem -eq $null) { "Not Found" } else { $regItem.$RegName }
    $output
}

# Define registry keys and values to check
$regSettings = @()
$expectedValues = @{
    'SystemDefaultTlsVersions' = 1
    'SchUseStrongCrypto' = 1
    'Enabled' = 1
    'DisabledByDefault' = 0
}

$regPaths = @(
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319',
    'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319',
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server',
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
)

foreach ($path in $regPaths) {
    foreach ($name in $expectedValues.Keys) {
        $regSettings += Get-ADSyncToolsTls12RegValue $path $name
    }
}

# Check if any setting is missing or incorrect
$needsUpdate = $false
foreach ($setting in $regSettings) {
    if ($expectedValues.ContainsKey($setting.Name)) {
        if ($setting.Value -eq "Not Found" -or $setting.Value -ne $expectedValues[$setting.Name]) {
            $needsUpdate = $true
            break
        }
    }
}

# If update is needed, apply TLS 1.2 settings
if ($needsUpdate) {
    Write-Host "🔧 TLS 1.2 settings are missing or incorrect. Applying updates..." -ForegroundColor Yellow

    $dotNetPaths = @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319',
        'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'
    )

    foreach ($path in $dotNetPaths) {
        if (-Not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name 'SystemDefaultTlsVersions' -Value 1 -Type DWord
        Set-ItemProperty -Path $path -Name 'SchUseStrongCrypto' -Value 1 -Type DWord
    }

    $schannelPaths = @(
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server',
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
    )

    foreach ($path in $schannelPaths) {
        if (-Not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name 'Enabled' -Value 1 -Type DWord
        Set-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 0 -Type DWord
    }

    Write-Host '✅ TLS 1.2 has been enabled. A system restart is required for the changes to take effect.' -ForegroundColor Cyan
} else {
    Write-Host '✅ TLS 1.2 is already correctly configured. No changes needed.' -ForegroundColor Green
}
