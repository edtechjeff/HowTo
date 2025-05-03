To allow **ICMP (Internet Control Message Protocol)** traffic—commonly used for **ping**—you can create a similar firewall rule in **Intune**. Here's how:

---

### ✅ **Steps to Allow ICMP Inbound Traffic via Intune Firewall Policy**

1. **Go to Intune Admin Center**  
   https://intune.microsoft.com

2. **Navigate to Endpoint Security > Firewall**  
   - Click **+ Create Policy**
   - **Platform**: Windows 10 and later  
   - **Profile**: Windows Firewall Rules

3. **Basics Tab**
   - **Name**: e.g., `Allow ICMP Inbound`
   - **Description**: e.g., `Allows inbound ICMP Echo Requests (ping)`

4. **Configuration Settings**
   - Click **+ Add** to create a new rule
   - Fill in the following:
     - **Name**: Allow ICMP
     - **Direction**: Inbound
     - **Action**: Allow
     - **Enabled**: Yes
     - **Interface Types**: All
     - **Protocol**: ICMPv4 (Protocol number **1**) or ICMPv6 (Protocol number **58**) depending on your needs
     - **ICMP Types and Codes**:  
       - For Echo Request (ping):  
         - **Type**: 8  
         - **Code**: 0  
     - **Local/Remote Port Ranges**: Leave blank (ICMP doesn’t use ports)
     - **Local/Remote Address Ranges**: * (or restrict as needed)
     - **Profile**: Domain, Private, Public (select as needed)

5. **Assignments**
   - Assign to the appropriate **device groups**

6. **Review + Create**
   - Review your settings and click **Create**

---

### 🧪 Optional: Allow ICMP Outbound Too
If you want devices to **send** ping requests, create a second rule:
- **Direction**: Outbound
- **Type**: 8 (Echo Request)
- **Code**: 0

---

In Microsoft Intune, when you're configuring a firewall rule and need to specify **ICMP types and codes**, the format is as follows:

---

### 🧾 **ICMP Types and Codes Format in Intune**

- Use the format:  
  ```
  <Type>:<Code>
  ```

- **Examples**:
  - `8:0` → ICMP Echo Request (used for ping)
  - `0:0` → ICMP Echo Reply
  - `3:*` → All Destination Unreachable messages
  - `*:*` → All ICMP types and codes

- You can also use wildcards:
  - `8:*` → All codes for Echo Request
  - `*:0` → Code 0 for all types
  - `*:*` → All ICMP traffic (use with caution)

---

### ✅ For Allowing Ping (Echo Request)
Use:
```
8:0
```

This will allow inbound ICMP Echo Requests, which is what `ping` uses.
