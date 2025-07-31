# 🚫 How to Deploy AppLocker Policy via Intune with Custom OMA-URI

This guide outlines how to create and deploy an AppLocker policy using a **custom OMA-URI** in **Microsoft Intune**.

---

## ✅ Prerequisites

Before you begin, ensure:

- You have access to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com/).
- Your account has permissions to create and assign Intune policies.
- You’ve prepared a valid, **well-formatted AppLocker XML policy**.

---

## 🛠️ Step-by-Step Instructions

### 1. Sign in to Endpoint Manager

1. Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Sign in with your administrator account.

---

### 2. Create a New Configuration Profile

1. Navigate to **Devices** > **Configuration profiles**.
2. Click **+ Create profile**.
3. Choose:
   - **Platform**: `Windows 10 and later`
   - **Profile type**: `Custom`
4. Click **Create**.

---

### 3. Define OMA-URI Setting

1. In the **Configuration settings** section, click **+ Add**.
2. Fill out the fields as follows:

   | Field        | Value                                                                 |
   |--------------|-----------------------------------------------------------------------|
   | **Name**     | AppLocker Policy (or any descriptive name)                           |
   | **Description** | Optional description of the policy                                 |
   | **OMA-URI**  | `./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/EXEGroup/EXE/Policy` |
   | **Data type**| `String`                                                              |
   | **Value**    | Paste the full XML contents of your AppLocker policy                 |

3. Click **Save**.

---

### 4. Assign the Policy

1. Click **Next** to proceed to **Assignments**.
2. Assign the policy to targeted **groups** or **devices**.
3. Click **Next**.

---

### 5. Review + Create

1. Review your configuration.
2. Click **Create** to deploy the policy.

---

## 💡 Tips & Recommendations

- Use **Audit Only** mode in the XML during initial testing to avoid accidental app blocks.
- Always **test on a pilot group** before broad deployment.
- Validate your XML using Microsoft’s tools or schema references.

---

## 🔗 Useful Resources

- [📘 AppLocker Overview](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker-overview)  
- [📘 Intune Custom OMA-URI Settings](https://learn.microsoft.com/en-us/mem/intune/configuration/custom-settings-windows)  
- [📘 AppLocker XML Syntax Reference](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/create-applocker-policies)  

---

## 📄 Additional OMA-URI Paths

Depending on your AppLocker rules, you may need to use other OMA-URIs:

```text
./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/EXEGroup/EXE/Policy
./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/MSIGroup/MSI/Policy
./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/ScriptGroup/Script/Policy
./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/DLLGroup/DLL/Policy
./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/StoreAppsGroup/StoreApps/Policy
```