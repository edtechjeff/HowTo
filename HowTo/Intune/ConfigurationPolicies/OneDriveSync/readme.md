# 📘 How to Create an Intune Configuration Profile via the Settings Catalog

This guide walks you through the process of creating a configuration profile in Intune using the Settings Catalog.

## Prerequisites

- You must have appropriate permissions (e.g., Intune Administrator or Policy and Profile Manager).
- Devices must be enrolled in Intune.
- Access to Microsoft Intune via the [Intune Portal](https://intune.microsoft.com).

---

## Steps to Create a Configuration Profile Using the Settings Catalog

### 1. Sign in to the Intune Admin Center
- Go to: [https://intune.microsoft.com](https://intune.microsoft.com)

---

### 2. Navigate to Configuration Profiles
- In the left-hand menu, click **Devices**.
- Under **Policy**, select **Configuration profiles**.

---

### 3. Create a New Profile
- Click **+ Create profile**.
- Platform: Select your target platform (e.g., **Windows 10 and later**).
- Profile type: Choose **Settings catalog**.
- Click **Create**.

---

### 4. Name and Describe the Profile
- **Name**: Enter a name (e.g., *Disable OneDrive Sync*).
- **Description**: (Optional) Enter a description.
- Click **Next**.

---

### 5. Configure Settings
- Click **+ Add settings**.
- Browse or search for the setting category (e.g., *OneDrive*).
- Expand the category and check the following boxes for settings. There are more but these are the basic ones.
    ## 📋 OneDrive Settings – Intune Configuration Profile (Settings Catalog)

| Setting                                                                 | Value                                           |
|-------------------------------------------------------------------------|-------------------------------------------------|
| Prevent users from redirecting their Windows known folders to their PC | Enabled                                         |
| Silently move Windows known folders to OneDrive                        | Enabled                                         |
| Desktop (Device)                                                       | True                                            |
| Documents (Device)                                                     | True                                            |
| Pictures (Device)                                                      | True                                            |
| Show notification to users after folders have been redirected (Device) | No                                              |
| Tenant ID (Device)                                                     | 2238ddfb-9425-4fed-8482-c2cdef1a8793           |
| Silently sign in users to the OneDrive sync app with Windows credentials | Enabled                                      |
| Use OneDrive Files On-Demand                                           | Enabled                                         |

- Click **Next**.

---

### 6. Assign the Profile
- Choose which **groups** to assign the policy to.
  - Example: Add a group of test devices or users.
- Click **Next**.

---

### 7. Review + Create
- Review the summary of your settings and assignments.
- Click **Create** to deploy the policy.

---

## Monitoring
- Go back to **Configuration profiles**.
- Select your profile to monitor deployment status, check for errors, or view per-device and per-user reports.

---

## Notes
- Test new policies on a small group before deploying widely.
- Use filters for more granular targeting if needed.

