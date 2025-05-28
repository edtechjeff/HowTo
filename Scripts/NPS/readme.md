## Get list of Certificate Servers

## Command to tell the name of the NPS cert being used

```
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
    $_.EnhancedKeyUsageList | Where-Object { $_.FriendlyName -eq "Server Authentication" }
} | Select-Object Subject, Issuer, Thumbprint, NotAfter | Format-List
```

## Export the CERT
```
$thumbprint = "F4B70D0982009AE44A54E1EFEF2F46F983FEDEFD"
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
    $_.Thumbprint -eq $thumbprint
}

$exportPath = "C:\Temp\radius_cert.cer"
Export-Certificate -Cert $cert -FilePath $exportPath
```
#

## Setup of Profiles
1. Export your Root CA cert (from earlier instructions)
Make sure you have your .cer file ready (Root CA that issued your RADIUS server certificate).

2. Upload the Root CA certificate to Intune
Sign in to Microsoft Endpoint Manager admin center.

Go to Devices > Configuration profiles > Create profile.

Select:

Platform: Windows 10 and later

Profile type: Trusted certificate

Click Create.

Name it (e.g., RADIUS Root CA Cert).

Upload your .cer file.

Assign to your device groups (the devices that will connect to Wi-Fi).

Create and save.

3. Create the Wi-Fi profile with PEAP machine authentication
In MEM admin center, go to Devices > Configuration profiles > Create profile.

Select:

Platform: Windows 10 and later

Profile type: Wi-Fi

Fill in the basics:

Name: e.g., Wi-Fi - SDCSC_Secure

Description: Optional

Under Configuration settings:

SSID: SDCSC_Secure

Connect automatically: Yes

Connect even if the SSID is not broadcasting: Yes (matches your XML’s <nonBroadcast>true</nonBroadcast>)

Network type: Infrastructure

Security type: WPA2-Enterprise

Authentication method: Select Protected EAP (PEAP)

Trusted Root Certificate: Select the Root CA profile you uploaded in step 2 (RADIUS Root CA Cert). This tells the client to trust that CA.

EAP type settings:

Validate server certificate: Yes (to validate RADIUS server identity)

Enable Fast Reconnect: Yes (matches <FastReconnect>true</FastReconnect>)

Inner authentication method: Choose Microsoft: Secured password (EAP-MSCHAP v2) (default inside PEAP)

Specify authentication mode:

Since your XML uses <authMode>machine</authMode>, select Use computer certificates for authentication (single sign-on) or Use SSO with computer authentication (depends on Intune version)

This means the device authenticates using its machine identity, not user credentials.

Leave other settings as default or configure as needed.