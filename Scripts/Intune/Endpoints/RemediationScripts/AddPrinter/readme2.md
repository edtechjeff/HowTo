Server-Side Configuration (Windows Print Server)
Enable Guest Access on the Server:

Open Local Security Policy (secpol.msc)
Navigate to:
Local Policies > Security Options
Set the following:
Network access: Let Everyone permissions apply to anonymous users → Enabled
Network access: Shares that can be accessed anonymously → Add the printer share name
Accounts: Guest account status → Enabled
Share the Printer with Everyone:

Go to Printers & Scanners
Right-click the printer → Printer Properties
Under Sharing tab:
Check Share this printer
Give it a simple share name
Under Security tab:
Add Everyone and Guest
Grant Print permissions
Firewall Rules:

Ensure File and Printer Sharing is allowed through Windows Firewall.
✅ Client-Side Configuration (Entra ID-only Devices)
Since these devices are not domain-joined, they won’t be able to authenticate to the print server using AD credentials. But with anonymous access:

You can connect using the UNC path:
\\printserver\printersharename
Or deploy the printer using a script or Intune (see below).
🚀 Deploy via Intune (Optional)
You can use a PowerShell script deployed via Intune to add the printer:




PowerShell
$printerPath = "\\printserver\printersharename"
Add-Printer -ConnectionName $printerPath

Make sure the script runs in user context if needed.

⚠️ Security Considerations
Anonymous access means no authentication, so anyone on the network can print.
Consider isolating the print server in a restricted VLAN or subnet.
Monitor usage and restrict access via network-level controls if needed.
Would you like help generating the Intune deployment script or testing connectivity from an Entra-only device?








You said:

so its not domain joined standalone print server
Copilot said:
Copilot
Thanks for the clarification! Since your print server is not domain-joined (i.e., it's a standalone Windows server) and your clients are Entra ID-only joined, here's how you can set up anonymous access for printing:

✅ Goal Recap
Standalone Windows print server (not joined to AD)
Clients are Entra ID-only joined (no hybrid identity)
No user authentication — allow anonymous access to shared printers
🔧 Steps to Configure Anonymous Access on Standalone Print Server
1. Enable Guest Account
Open Computer Management → Local Users and Groups > Users
Enable the Guest account (if disabled)
Optionally, rename it for security, but keep it enabled
2. Configure Local Security Policy
Open secpol.msc and adjust these settings:

Network access: Let Everyone permissions apply to anonymous users → Enabled
Network access: Shares that can be accessed anonymously → Add your printer share name (e.g., PrinterShare)
Accounts: Guest account status → Enabled
Network access: Do not allow anonymous enumeration of SAM accounts and shares → Disabled
3. Share the Printer
Go to Control Panel > Devices and Printers
Right-click the printer → Printer Properties
Under Sharing tab:
Check Share this printer
Give it a simple name (e.g., PrinterShare)
Under Security tab:
Add Everyone and Guest
Grant Print permission
4. Firewall Configuration
Ensure File and Printer Sharing is allowed in Windows Firewall
Open wf.msc → Enable inbound rules for:
File and Printer Sharing (Echo Request - ICMPv4-In)
File and Printer Sharing (SMB-In)
🖥️ Client-Side (Entra ID-only Devices)
These clients can connect using:




Plain Text
\\<print-server-ip>\PrinterShare

You can manually add the printer or deploy it via Intune using a PowerShell script:




PowerShell
Add-Printer -ConnectionName "\\<print-server-ip>\PrinterShare"

Make sure the script runs in user context if deployed via Intune.

⚠️ Security Notes
Anonymous access means no authentication, so anyone on the network can print.
Consider placing the print server in a restricted subnet or VLAN.
Use network ACLs or firewall rules to limit access to trusted devices.
Would you like help packaging this into an Intune deployment script or testing it in your environment?








You said:

would file shares also work this way 
Copilot said:
Copilot
Yes — file shares can also work this way on a standalone (non-domain-joined) Windows server, using anonymous access. This is especially useful in environments like yours where clients are Entra ID-only joined and can't authenticate to local accounts or AD.

✅ How to Set Up Anonymous File Share Access
1. Enable Guest Account
Open Computer Management → Local Users and Groups > Users
Enable the Guest account
Optionally, remove password or rename it for security
2. Configure Local Security Policy
Open secpol.msc and set:

Network access: Let Everyone permissions apply to anonymous users → Enabled
Network access: Shares that can be accessed anonymously → Add your share name(s) (e.g., PublicShare)
Accounts: Guest account status → Enabled
Network access: Do not allow anonymous enumeration of SAM accounts and shares → Disabled
3. Create and Share the Folder
Create a folder (e.g., C:\PublicShare)
Right-click → Properties > Sharing > Advanced Sharing
Check Share this folder
Set share name (e.g., PublicShare)
Click Permissions:
Add Everyone and Guest
Grant Read or Full Control as needed
4. Set NTFS Permissions
Go to Security tab
Add Everyone and/or Guest
Grant appropriate permissions (e.g., Read, Write)
5. Firewall Rules
Open wf.msc (Windows Firewall)
Enable inbound rules for:
File and Printer Sharing (SMB-In)
File and Printer Sharing (NB-Session-In)
🖥️ Accessing from Entra ID-only Clients
Clients can access the share using:




Plain Text
\\<server-ip>\PublicShare

You can map it manually or deploy via Intune with a PowerShell script:




PowerShell
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\<server-ip>\PublicShare" -Persist

⚠️ Security Considerations
Anonymous access means no authentication, so anyone on the network can access the share.
Use network segmentation, firewall rules, or VPN to restrict access.
Avoid storing sensitive data in anonymous shares.
Would you like help creating an Intune deployment package for this, or testing access from a sample Entra-only device?








You said:

when I did that setting on a client I get the following

You can't access this shared folder because your organization's security policies block unauthenticated guest access. These policies help protect your PC from unsafe or malicious devices on the network.
Copilot said:
Copilot
That error message — "Your organization's security policies block unauthenticated guest access" — is caused by a Windows security setting that blocks SMB guest access by default on Windows 10/11 and Server 2016+. This is a client-side policy, not a server issue.

🔧 Fix: Allow Unauthenticated Guest Access on the Client
You need to modify a local group policy or registry setting on the Entra ID-only client to allow guest access to SMB shares.

✅ Option 1: Group Policy (if available)
Open Local Group Policy Editor (gpedit.msc)
Navigate to:
Computer Configuration > Administrative Templates > Network > Lanman Workstation
Set:
Enable insecure guest logons → Enabled
If you're managing devices via Intune, this can be deployed as a custom policy.

✅ Option 2: Registry (for Intune or manual config)
If gpedit.msc is not available (common on Home editions or Entra-only devices), use this registry key:




PowerShell
reg isn’t fully supported. Syntax highlighting is based on PowerShell.

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters]
"AllowInsecureGuestAuth"=dword:00000001

You can deploy this via Intune using a PowerShell script:




PowerShell
New-ItemProperty -Path "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
  -Name "AllowInsecureGuestAuth" -PropertyType DWord -Value 1 -Force

⚠️ Security Warning
Enabling insecure guest access reduces security — it allows unauthenticated access to SMB shares. You should:

Use this only on trusted networks
Limit access to specific IP ranges via firewall
Avoid storing sensitive data in guest-accessible shares
Would you like help packaging this into an Intune configuration profile or deployment script?








You said:

is there a way to lock down that lanman to just one particular workstation
Copilot said:
Copilot
Great question — yes, you can lock down the insecure guest access policy to apply only when connecting to a specific server, but not directly through the LanmanWorkstation policy itself. That setting is global. However, there are a few workarounds you can use to limit exposure while still enabling access to your standalone print or file server.

🔐 Option 1: Use Windows Firewall to Restrict SMB Guest Access by IP
Instead of enabling insecure guest access for all SMB connections, you can:

Enable guest access via registry or policy (as discussed earlier)
Restrict SMB traffic to only the IP address of your standalone server using Windows Defender Firewall on the client
Example:
Allow outbound SMB (TCP 445) only to192.168.1.100 (your print server)
Steps:

Open wf.msc on the client
Create a new Outbound Rule:
Program: All programs
Protocol: TCP, port 445
Remote IP: 192.168.1.100 (your server)
Action: Allow
Profile: Domain/Private
Then create a block rule for all other SMB traffic (optional)
🔐 Option 2: Use a Scheduled Script to Temporarily Enable Guest Access
You could deploy a PowerShell script via Intune that:

Enables AllowInsecureGuestAuth
Connects to the share
Then removes the registry key after the connection is established
This minimizes the window of exposure.

🔐 Option 3: Use a Local Loopback Proxy or SMB Gateway
This is more advanced, but you could:

Set up a local SMB proxy or gateway that only forwards traffic to your print server
Allow guest access only through that proxy
Block all other SMB guest traffic
This is more common in enterprise environments with strict segmentation.

Summary
Approach	Limits Guest Access To	Complexity	Recommended For
Firewall Rules	Specific IPs	Low	Most environments
Scheduled Script	Specific time window	Medium	Temporary access
SMB Proxy	Specific path	High	Advanced setups
Would you like help creating the firewall rule script or an Intune deployment profile for one of these options?








You said:

how would enable the lanman policy via intune and then also set the firewall policy
Copilot said:
Copilot
To enable Lanman Workstation guest access and configure Windows Firewall rules via Intune, you'll need to deploy:

A custom configuration profile for the registry setting (AllowInsecureGuestAuth)
A custom PowerShell script or Endpoint Security policy to set the firewall rule
✅ Step 1: Enable Guest Access via Intune (Lanman Workstation)
This is done by deploying a custom configuration profile using OMA-URI.

🔧 Configuration Profile Details
Platform: Windows 10 and later
Profile type: Custom
OMA-URI:
./Device/Vendor/MSFT/Policy/Config/Network/AllowInsecureGuestAuth
Data type: Integer
Value: 1
📋 How to Create It in Intune
Go to Intune Admin Center → Devices > Configuration profiles
Click + Create profile
Choose:
Platform: Windows 10 and later
Profile type: Custom
Add a new setting:
Name: AllowInsecureGuestAuth
OMA-URI: ./Device/Vendor/MSFT/Policy/Config/Network/AllowInsecureGuestAuth
Data type: Integer
Value: 1
Assign to your target group
✅ Step 2: Create Firewall Rule via Intune
You can do this using a PowerShell script deployed via Intune.

🔧 PowerShell Script Example



PowerShell
# Allow outbound SMB only to your print server
$serverIP = "192.168.1.100"

New-NetFirewallRule -DisplayName "Allow SMB to Print Server" `
  -Direction Outbound -Protocol TCP -LocalPort Any -RemotePort 445 `
  -RemoteAddress $serverIP -Action Allow
# Optional: Block all other outbound SMB traffic
New-NetFirewallRule -DisplayName "Block SMB to Other Hosts" `
  -Direction Outbound -Protocol TCP -LocalPort Any -RemotePort 445 `
  -RemoteAddress "Any" -Action Block

📋 How to Deploy via Intune
Go to Intune Admin Center → Devices > Scripts
Click + Add → Windows 10 and later
Upload the .ps1 script
Set to run in system context
Assign to your target group
Would you like me to generate the .ps1 script file for download and deployment, or help with packaging both into an Intune deployment plan?