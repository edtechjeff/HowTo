# How to Create an AppLocker Policy in Intune Using Custom OMA-URI

Follow these steps to create and deploy an AppLocker policy using a custom OMA-URI in Microsoft Intune:

## Prerequisites
- Access to the Microsoft Endpoint Manager admin center.
- Appropriate permissions to create and assign policies in Intune.
- A valid XML file defining the AppLocker policy.

## Steps

### 1. Open the Microsoft Endpoint Manager Admin Center
1. Navigate to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Sign in with your administrator credentials.

### 2. Create a New Configuration Profile
1. In the left-hand menu, select **Devices**.
2. Under **Policy**, click **Configuration profiles**.
3. Click **+ Create profile**.

### 3. Configure the Profile
1. In the **Platform** dropdown, select **Windows 10 and later**.
2. In the **Profile type** dropdown, select **Custom**.
3. Click **Create**.

### 4. Add Custom OMA-URI Settings
1. In the **Configuration settings** section, click **Add**.
2. Fill in the following fields:
    - **Name**: Enter a descriptive name (e.g., "AppLocker Policy").
    - **Description**: Optionally, provide a description of the policy.
    - **OMA-URI**: Enter the OMA-URI path: `./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/EXEGroup/EXE/Policy`.
    - **Data type**: Select **String**.
    - **Value**: Paste the XML content of your AppLocker policy.
3. Click **Save**.

### 5. Assign the Policy
1. Click **Next** to proceed to the **Assignments** section.
2. Select the groups or devices to which you want to apply the policy.
3. Click **Next**.

### 6. Review and Create
1. Review the settings you configured.
2. Click **Create** to save and deploy the policy.

## Notes
- Ensure the XML file is properly formatted and validated before uploading.
- Test the policy on a small group of devices before deploying it broadly.
- Use the **Audit only** mode in the XML to monitor the impact of the policy without enforcing it.

## Additional Resources
- [Microsoft Documentation on AppLocker](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker-overview)
- [OMA-URI Settings in Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/custom-settings-windows)
- [AppLocker Policy XML Reference](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/create-applocker-policies)

## Additional OMA-URI's
- ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/EXEGroup/EXE/Policy

- ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/MSIGroup/MSI/Policy

- ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/ScriptGroup/Script/Policy

- ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/DLLGroup/DLL/Policy

- ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/StoreAppsGroup/StoreApps/Policy

