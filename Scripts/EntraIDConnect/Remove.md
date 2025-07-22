1. Install Microsoft Graph PowerShell Modules:

    - Open PowerShell as an administrator and run:
        ```powershell
        Install-Module Microsoft.Graph -Force
        Install-Module Microsoft.Graph.Beta -AllowClobber -Force
        ```

2. Connect to Microsoft Graph:

    - Run and use a Hybrid Identity Administrator account:
        ```powershell
        Connect-MgGraph -scopes "Organization.ReadWrite.All,Directory.ReadWrite.All"
        ```

3. Verify Current Sync Status:

    - Run the following command

        ```powershell
        Get-MgOrganization | Select OnPremisesSyncEnabled
        ```

    - Confirm it shows True.


4. Disable Directory Synchronization:

    - Run and store the tenant ID and disable sync:

        ```powershell
        $organizationId = (Get-MgOrganization).Id
        $params = @{ onPremisesSyncEnabled = $false }
        Update-MgOrganization -OrganizationId $organizationId -BodyParameter $params
        ```

5. Run to verify the change:

        ```powershell
        Get-MgOrganization | Select OnPremisesSyncEnabled
        ```

    - It should now show Null (or nothing).

# Instructions to Turn Off Directory Synchronization:

6. Uninstall Azure AD Connect (Recommended First Step):

    - On the server where Azure AD Connect is installed, go to Control Panel > Programs and Features.
    - Find Microsoft Azure AD Connect, select it, and click Uninstall.
    - Action: Follow the prompts to remove the tool completely.

7. To monitor the progress you can run the following command

        ```powershell
        Get-MgUser -UserId user@domain.com | Select-Object UserPrincipalName, OnPremisesSyncEnabled
        ```

