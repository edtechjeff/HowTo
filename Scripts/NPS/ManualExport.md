🔍 Step 1: Identify the certificate
On your NPS server:
Open mmc.exe (Microsoft Management Console).
Go to File > Add/Remove Snap-in...
Add the Certificates snap-in:
Choose Computer account
Then Local computer
Click OK.
Now you're viewing the local computer's certificate store.

🔎 Step 2: Find the NPS (RADIUS) certificate
Look in:

```
Certificates (Local Computer)
 └─ Personal
     └─ Certificates
```

You're looking for a certificate that:
Has a purpose of Server Authentication
Is issued by a trusted internal or public CA
Often has a CN or SAN like nps.contoso.com or radius.corp.local
Check the Intended Purposes column or open the cert and look under the Details > Enhanced Key Usage.

📤 Step 3: Export the certificate (public key only)
To export it (for review or to distribute the public cert to clients):
Right-click the certificate.
Select All Tasks > Export...
In the Certificate Export Wizard:
Do not export the private key
Choose DER encoded binary (.CER) or Base-64 encoded (.CER)
Save it somewhere (e.g., nps_cert.cer)
This file can now be:
Viewed on other systems
Used to confirm the CN/SAN name
Imported to clients if needed for trust

🧪 Optional: View the certificate
You can double-click the exported .cer file on any machine to:

See the Subject and SAN names
Confirm expiration
See issuing CA