Get-ChildItem -Path Cert:\LocalMachine\My |
Where-Object {
    $_.EnhancedKeyUsageList | Where-Object { $_.FriendlyName -eq "Server Authentication" }
} |
Select-Object Subject, NotAfter, Thumbprint
