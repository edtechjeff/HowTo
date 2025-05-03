To create a firewall rule in **Microsoft Intune** to allow **RDP (Remote Desktop Protocol)** inbound traffic (typically on **TCP port 3389**), follow these steps:

---

### ✅ **Steps to Create an RDP Inbound Firewall Rule in Intune**

1. **Sign in to the Intune Admin Center**  
   Go to https://intune.microsoft.com

2. **Navigate to Endpoint Security**  
   - Go to **Endpoint Security** > **Firewall**  
   - Click **+ Create Policy**

3. **Configure the Policy**
   - **Platform**: Windows 10 and later  
   - **Profile**: Windows Firewall Rules  
   - Click **Create**

4. **Basics Tab**
   - **Name**: e.g., `Allow RDP Inbound`
   - **Description**: e.g., `Allows inbound RDP traffic on TCP port 3389`

5. **Configuration Settings**
   - Click **+ Add** to create a new rule
   - Fill in the following:
     - **Name**: Allow RDP
     - **Direction**: Inbound
     - **Action**: Allow
     - **Enabled**: Yes
     - **Interface Types**: All
     - **Protocol**: TCP (Protocol number 6)
     - **Local Port Ranges**: 3389
     - **Remote Port Ranges**: All
     - **Local Address Ranges**: * (or specify if needed)
     - **Remote Address Ranges**: * (or restrict to specific IPs)
     - **Profile**: Domain, Private, Public (select as needed)

6. **Assignments**
   - Assign the policy to the appropriate **device groups** or **users**

7. **Review + Create**
   - Review your settings and click **Create**

---

### 🔍 Verification
After the policy is deployed and the device checks in:
- Open **Windows Defender Firewall with Advanced Security** (`wf.msc`)
- Go to **Monitoring > Firewall** to confirm the rule is applied

---

