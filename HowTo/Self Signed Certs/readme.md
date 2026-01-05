---
title: How to create Self Signed CERTS
author: Jeff Downs
date: January 5, 2026
---

# Information on how to setup Certs
## Reference Website : https://adamtheautomator.com/hyper-v-replication/

## Create Certs for Replication
```powershell

# Setup the Certificates Variables

## Specify the name of the new Root CA certificate.
$rootCA_Name = 'Hyper-V Root CA'

## Specify the Hyper-V server names.
$hostnames = @('hyper1','hyper2')

## What is the password for the exported PFX certificates.
$CertPassword = 'this is a strong password' | ConvertTo-SecureString -Force -AsPlainText

## Where to export the PFX certificate after creating. Make sure that this folder exists.
$CertFolder = 'C:\HPVCerts'

## Create and save the Root CA certificate into the 'Personal' certificates store.
## Valid for 10 years.
$rootCA = New-SelfSignedCertificate `
-Subject $rootCA_Name  `
-FriendlyName $rootCA_Name `
-KeyExportPolicy Exportable  `
-KeyUsage CertSign  `
-KeyLength 2048  `
-KeyUsageProperty All  `
-KeyAlgorithm 'RSA'  `
-HashAlgorithm 'SHA256'  `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"  `
-NotAfter (Get-Date).AddYears(10)
```

## Copy the Root CA from the 'Personal' store to the 'Trusted Root Certification Authorities' store.
```powershell

$rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")
$rootStore.Open("ReadWrite")
$rootStore.Add($rootCA)
$rootStore.Close()
```


###########################################
## Export the Root CA
```powershell
$rootCA | Export-PfxCertificate -FilePath "$CertFolder\$($rootCA_Name).pfx" -Password $CertPassword -Force
```

## Generate the server certificates signed by the root certificate you have created. Run the command below to create the server certificates for each Hyper-V host and export each certificate to a file.

```Powershell
$hostnames | ForEach-Object {
	$name = $_
	## Create the certificate
	New-SelfSignedCertificate `
	-FriendlyName $name `
	-Subject $name `
	-KeyExportPolicy Exportable `
	-CertStoreLocation "Cert:\LocalMachine\My" `
	-Signer $rootCA `
	-KeyLength 2048  `
	-KeyAlgorithm 'RSA'  `
	-HashAlgorithm 'SHA256'  `
	-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"  `
	-NotAfter (Get-Date).AddYears(10) |
	## Export the certificate
	Export-PfxCertificate -FilePath "$CertFolder\$($name).pfx" -Password $CertPassword -Force
}
```

## Copy the Cert Root CA Cert and the Cert for the other server created from the previous step to the other host

## Run this command to import the Root CA on the other host
```powershell
## Specify the name of the Root CA certificate.
$rootCA_Name = 'Hyper-V Root CA'

## Where to find the PFX certificate files.
$CertFolder = 'C:\HPVCerts'

## What is the password for the exported PFX certificates.
$CertPassword = 'this is a strong password' | ConvertTo-SecureString -Force -AsPlainText

## Import the Root CA
Import-PfxCertificate  "$CertFolder\$($rootCA_Name).pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $CertPassword
```


## Import the Server Certificate
```powershell
Import-PfxCertificate  "$CertFolder\$($env:COMPUTERNAME).pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $CertPassword
```

#############################################
## Disable Hyper-V Certificate Revocation Check. Configure the Hyper-V registry to disable the checking for certificate revocation. Doing so, Hyper-V will not try to check the certificate’s revocation details – which does not exist in the self-signed certificate. Run the following New-ItemProperty PowerShell command. 
***Note: Needs to be done on both hosts***
```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Replication" -Name "DisableCertRevocationCheck" -Value 1 -PropertyType DWORD -Force
```