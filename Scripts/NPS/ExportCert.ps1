$thumbprint = "THUMBPRINT_HERE"
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }

# Export to DER format (binary .cer)
Export-Certificate -Cert $cert -FilePath "C:\Temp\NPSCert.cer"
