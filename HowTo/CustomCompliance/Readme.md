# Intune Custom Compliance Policies

Below you will find the basic steps for creating  a custom compliance policy. Its pretty basic how to do it, but you may ask, Why would I need one? Good question. In the following example we have created a standard policy but for some reason the Microsoft Defender Antimalware and also the Real-time protection is showing up as Not compliant. 

![alt text](/1.png)

Why is that? In this environment we are using a third party anti virus and so its not registering correctly. How do we address this? Custom Compliance Policy. 

In this repo you will find some examples. You will need 2 items. 

1. JSON File, used to define the variables that will be checked for and displayed in Custom Compliance
2. PowerShell script that will be used to query that device

Once you have those files it is pretty easy. I do want to talk about those files

1. PowerShell
    - In the following example I am using the PowerShell command Get-MpComputerStatus to pull if 
        - Realtime-protection is enabled
        - Anti Malware is enabled
        - Anti Spyware is enabled
        - Anti Virus is enabled

There are many different methods to pull this information, you can pull it from a file, or folder or registry key. What ever method you can use with PowerShell to pull that information and then put that information into a readable JSON format.

```
# Get the Defender status values
$mpStatus = Get-MpComputerStatus
$RTPEnabled = $mpStatus.RealTimeProtectionEnabled
$AMServiceEnabled = $mpStatus.AMServiceEnabled
$AntiSpyware = $mpStatus.AntispywareEnabled
$AntiVirus = $mpStatus.AntivirusEnabled

# Build the output hashtable
$output = @{
    RTPEnabled      = $RTPEnabled
    AMServiceEnabled = $AMServiceEnabled
    AntiSpyware     = $AntiSpyware
    AntiVirus       = $AntiVirus
}

# Convert to compressed JSON
return $output | ConvertTo-Json -Compress

```
From a script breakdown 
1. First block is creating the variables to be used and what command to be used
2. Second block is creating the output based on the commands ran and also these same variables will be used in the JSON and will be what is displayed when you are looking at the compliance results in Intune
3. To me, almost the most important, this is out-putting the commands and the variables to a readable JSON format.

Now you have your PowerShell script created its time for the JSON

```
{
    "Rules": [
      {
        "ruleType": "script",
        "SettingName": "RTPEnabled",
        "Operator": "IsEquals",
        "Operand": "true",
        "DataType": "Boolean",
        "MoreInfoUrl": "https://google.com",
        "RemediationStrings": [
          {
            "Language": "en_US",
            "Title": "This machine has no active RealtimeProtection.",
            "Description": "To continue to use this device you have to activate RealtimeProtection"
          }
        ]
      },
      {
        "ruleType": "script",
        "SettingName": "AMServiceEnabled",
        "Operator": "IsEquals",
        "Operand": "true",
        "DataType": "Boolean",
        "MoreInfoUrl": "https://google.com",
        "RemediationStrings": [
          {
            "Language": "en_US",
            "Title": "The AntiMalware Service is not running.",
            "Description": "To continue to use this device you have to ensure the AM service is enabled"
          }
        ]
      },
      {
        "ruleType": "script",
        "SettingName": "AntiSpyware",
        "Operator": "IsEquals",
        "Operand": "true",
        "DataType": "Boolean",
        "MoreInfoUrl": "https://google.com",
        "RemediationStrings": [
          {
            "Language": "en_US",
            "Title": "Antispyware is not enabled.",
            "Description": "To continue to use this device you must enable antispyware protection"
          }
        ]
      },
      {
        "ruleType": "script",
        "SettingName": "AntiVirus",
        "Operator": "IsEquals",
        "Operand": "true",
        "DataType": "Boolean",
        "MoreInfoUrl": "https://google.com",
        "RemediationStrings": [
          {
            "Language": "en_US",
            "Title": "Antivirus is not enabled.",
            "Description": "To continue to use this device you must enable antivirus protection"
          }
        ]
      }
    ]
  }

  ```
