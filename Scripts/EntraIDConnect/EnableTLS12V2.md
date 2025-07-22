# Enable TLS 1.2 on new AD Connect Server V2
## ***Note: Updated version to handle changes better if already on the system***

```powershell
# Enable TLS 1.2 for .NET Framework (32-bit and 64-bit)
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

# Enable TLS 1.2 for Schannel (Client and Server)
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
```