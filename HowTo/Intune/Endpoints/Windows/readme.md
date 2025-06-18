# Information on various topics when it comes to Endpoints and Intune

- Force Device to checkin and syncapps
    - From a run prompt run the following command 
        ```
        intunemanagementextension://syncapp
        ```
- Great Article about deployments and applications
    -  https://www.deploymentresearch.com/force-application-reinstall-in-microsoft-intune-win32-apps/

- Restart the Microsoft Intune Management Extension Service (Powershell)
    ```powershell
    Restart-Service -Name "IntuneManagementExtension"
    ```

- Delete the registry key
    ```
    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\{SID}\{App GUID}
    ```
        If the exit code is not zero its failed... delete that appguid registry key