# Pulls EntrID,DeviceID,SerialNumber,AutoPilotID,DisplayName,ApproximateLastSignInDateTime,OperatingSystem,Make,Model

# Import the required module
Import-Module Microsoft.Graph

# Define all required variables at the beginning
$scopes = @(
    "Device.Read.All", 
    "Group.ReadWrite.All", 
    "DeviceManagementManagedDevices.Read.All"  # Needed for Intune managed devices
)

# Authenticate to Microsoft Graph
Connect-MgGraph -Scopes $scopes

# Create output folder if it doesn't exist
$OutputFolder = "C:\Temp"
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}
$OutputFile = "$OutputFolder\FullDeviceList.csv"

# Retrieve Entra ID devices
$Devices = Get-MgDevice -All -Property DisplayName, DeviceId, Id, ApproximateLastSignInDateTime, OperatingSystem | 
    Where-Object { $_.OperatingSystem -notin @("iOS", "Android", "macOS", "iPad", "Printer", "iPhone", "MacMDM") } |
    Select-Object DisplayName, DeviceId, Id, ApproximateLastSignInDateTime, OperatingSystem

# Retrieve Autopilot devices
$AutopilotDevices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity | 
    Select-Object SerialNumber, Id, AzureActiveDirectoryDeviceId

# Retrieve Intune Managed Devices (to get make/model)
$IntuneDevices = Get-MgDeviceManagementManagedDevice -All | 
    Select-Object AzureADDeviceId, Manufacturer, Model

# Join data
$CombinedList = foreach ($device in $Devices) {
    $autopilot = $AutopilotDevices | Where-Object { $_.AzureActiveDirectoryDeviceId -eq $device.DeviceId }
    $intune = $IntuneDevices | Where-Object { $_.AzureADDeviceId -eq $device.DeviceId }

    [PSCustomObject]@{
        EntraID                        = $device.Id
        DeviceId                       = $device.DeviceId
        SerialNumber                   = $autopilot.SerialNumber
        AutoPilotID                    = $autopilot.Id
        DisplayName                    = $device.DisplayName
        ApproximateLastSignInDateTime  = $device.ApproximateLastSignInDateTime
        OperatingSystem                = $device.OperatingSystem
        Make                           = $intune.Manufacturer
        Model                          = $intune.Model
    }
}

# Export to CSV
$CombinedList | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "CSV export complete: $OutputFile"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
