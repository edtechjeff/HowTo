Step-by-Step: Create PEAP Wi-Fi Profile in Intune
🔹 1. Upload Root Certificate from Your NPS Server’s CA
Your devices must trust the certificate your NPS server presents during 802.1X authentication.

Steps:
Go to Intune Admin Center → Devices > Configuration profiles > Create profile

Choose:

Platform: Windows 10 and later

Profile type: Templates → Trusted certificate

Upload the .cer file of your Root or Intermediate CA that issued the NPS server cert.

Assign this profile to the same group of devices/users that will get the Wi-Fi profile.

🔹 2. Create the PEAP Wi-Fi Profile
Steps:
Go to Intune Admin Center → Devices > Configuration profiles > Create profile

Choose:

Platform: Windows 10 and later

Profile type: Templates → Wi-Fi

Click Create and fill in:

Basics
Name: Wi-Fi - CorpSSID - PEAP

Description: (optional)

Configuration Settings
Wi-Fi name (SSID): YourSSID

Connect automatically when in range: ✅ Yes

Wi-Fi type: Enterprise

Authentication method: Protected EAP (PEAP)

EAP Type: MSCHAPv2

Authentication Mode: Choose:

User (standard if logging into Windows with Entra ID or AD accounts)

Machine or user (if both device and user auth are accepted by your NPS server)

Root Certificates: Choose the trusted certificate you created earlier.

Server Trust: Optionally, specify the RADIUS server FQDN (e.g., nps01.yourdomain.com)

🔹 3. Assign to Users or Devices
Assign to either:

Device groups (if machine-based auth or shared devices)

User groups (if user logs into Windows and auth is per-user)

📌 Important: The trusted cert profile must be deployed first, otherwise the Wi-Fi connection will fail due to untrusted server certificate errors.