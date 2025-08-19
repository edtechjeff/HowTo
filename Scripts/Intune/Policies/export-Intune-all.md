# This Script will export all policies. you will need to create an enterprise application with the following permissions

| PermissionName|Value|
|DeviceManagementManagedDevices|Read.All| 
|DeviceManagementRBAC|Read.All|
|DeviceManagementConfiguration|Read.All| 
|DeviceManagementApps|Read.All|

# script Run Example
```
 export-intune.ps1 -client_Id <String> -client_Secret <string> -tenant_Id <String> -location <String>
 ```

 ```powershell
 <#PSScriptInfo
.VERSION 0.3
.GUID a7d9a727-03d3-4521-972a-0f46d7e21edc
.AUTHOR
 Maarten Peeters / Modified by ChatGPT
.COMPANYNAME
 CloudSecuritea
#>

<#
.SYNOPSIS
 Export Intune policies to JSON files.

.DESCRIPTION
 Uses client credentials to connect to Microsoft Graph and export:
 - Compliance policies
 - Classic configuration profiles
 - Settings Catalog profiles
 - Endpoint security policies
 - Managed app policies

.PARAMETER client_Id
 Application (client) ID of the registered app.

.PARAMETER client_Secret
 Client secret of the registered app.

.PARAMETER tenant_Id
 Directory (tenant) ID.

.PARAMETER location
 Destination folder for exported JSON files.

.EXAMPLE
 .\export-intune.ps1 -client_Id "xxxxx" -client_Secret "xxxxx" -tenant_Id "xxxxx" -location "C:\Exports"
#>

param(
  [Parameter(Mandatory = $true)]
  [String]$client_Id,
  [Parameter(Mandatory = $true)]
  [String]$client_Secret,
  [Parameter(Mandatory = $true)]
  [String]$tenant_Id,
  [Parameter(Mandatory = $true)]
  [String]$location
)

######################
# Connect to Graph API
######################
$Body = @{
  grant_type    = "client_credentials"
  scope         = "https://graph.microsoft.com/.default"
  client_id     = $client_Id
  client_secret = $client_Secret
}

$ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenant_Id/oauth2/v2.0/token" -Method POST -Body $Body 

$HeaderParams = @{
  'Content-Type'  = "application/json"
  'Authorization' = "Bearer $($ConnectGraph.access_token)"
}

########################
# Helper: Safe filenames
########################
function Get-SafeFileName {
    param([string]$name)
    # Replace anything not alphanumeric, space, dash, or underscore with "_"
    $safe = ($name -replace '[^a-zA-Z0-9\-_ ]', '_')
    if ($safe.Length -gt 120) { $safe = $safe.Substring(0,120) }
    return $safe
}

##################
# Fetch policies
##################
try { $compliancePolicies = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies").value } catch {}
try { $configurationPolicies = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations").value } catch {}
try { $settingsCatalogPolicies = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies").value } catch {}
try { $endpointSecurityPolicies = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/intents").value } catch {}
try { $endpointSecurityTemplates = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/templates?`$filter=(isof('microsoft.graph.securityBaselineTemplate'))").value } catch {}
try { $managedAppPolicies = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceAppManagement/managedAppPolicies").value } catch {}

##################
# Export policies
##################

# Compliance
if ($compliancePolicies) {
  foreach ($policy in $compliancePolicies) {
    try {
      $filePath = Join-Path $location ("Compliance - " + (Get-SafeFileName $policy.displayName) + ".json")
      $policy | ConvertTo-Json -Depth 10 | Out-File $filePath -Encoding UTF8
      Write-Host "Exported compliance policy: $($policy.displayName)" -ForegroundColor Green
    }
    catch { Write-Host "Error exporting compliance policy $($policy.displayName): $($_.Exception.Message)" -ForegroundColor Red }
  }
} else { Write-Host "No compliance policies found." -ForegroundColor Yellow }

# Classic Configuration
if ($configurationPolicies) {
  foreach ($policy in $configurationPolicies) {
    try {
      $filePath = Join-Path $location ("Configuration - " + (Get-SafeFileName $policy.displayName) + ".json")
      $policy | ConvertTo-Json -Depth 10 | Out-File $filePath -Encoding UTF8
      if (Test-Path $filePath) {
        $Clean = Get-Content $filePath | Select-String -Pattern '"id":', '"createdDateTime":', '"modifiedDateTime":', '"version":', '"supportsScopeTags":' -NotMatch
        $Clean | Out-File -FilePath $filePath -Encoding UTF8
      }
      Write-Host "Exported configuration policy: $($policy.displayName)" -ForegroundColor Green
    }
    catch { Write-Host "Error exporting configuration policy $($policy.displayName): $($_.Exception.Message)" -ForegroundColor Red }
  }
} else { Write-Host "No configuration policies found." -ForegroundColor Yellow }

# Settings Catalog
if ($settingsCatalogPolicies) {
  foreach ($policy in $settingsCatalogPolicies) {
    try {
      $filePath = Join-Path $location ("SettingsCatalog - " + (Get-SafeFileName $policy.name) + ".json")
      $expandedPolicy = Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($policy.id)?`$expand=settings" -Method Get
      $expandedPolicy | ConvertTo-Json -Depth 15 | Out-File $filePath -Encoding UTF8
      Write-Host "Exported Settings Catalog policy: $($policy.name)" -ForegroundColor Green
    }
    catch { Write-Host "Error exporting Settings Catalog policy $($policy.name): $($_.Exception.Message)" -ForegroundColor Red }
  }
} else { Write-Host "No Settings Catalog policies found." -ForegroundColor Yellow }

# Endpoint Security
if ($endpointSecurityPolicies) {
  foreach ($policy in $endpointSecurityPolicies) {
    try {
      $filePath = Join-Path $location ("EndPointSecurity - " + (Get-SafeFileName $policy.displayName) + ".json")
      $JSON = [PSCustomObject]@{
        displayName     = $policy.displayName
        description     = $policy.description
        roleScopeTagIds = $policy.roleScopeTagIds
      }
      $ES_Template = $endpointSecurityTemplates | Where-Object { $_.id -eq $policy.templateId }
      if ($ES_Template) {
        $JSON | Add-Member -NotePropertyName 'TemplateDisplayName' -NotePropertyValue $ES_Template.displayName
        $JSON | Add-Member -NotePropertyName 'TemplateId'          -NotePropertyValue $ES_Template.id
        $JSON | Add-Member -NotePropertyName 'versionInfo'         -NotePropertyValue $ES_Template.versionInfo
      }
      $settings = @()
      if ($ES_Template) {
        $categories = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/templates/$($ES_Template.id)/categories").value
        foreach ($category in $categories) {
          $categorySettings = (Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/intents/$($policy.id)/categories/$($category.id)/settings?`$expand=Microsoft.Graph.DeviceManagementComplexSettingInstance/Value").value
          $settings += $categorySettings
        }
      }
      $JSON | Add-Member -NotePropertyName 'settingsDelta' -NotePropertyValue @($settings)
      $JSON | ConvertTo-Json -Depth 10 | Out-File $filePath -Encoding UTF8
      Write-Host "Exported endpoint security policy: $($policy.displayName)" -ForegroundColor Green
    }
    catch { Write-Host "Error exporting endpoint security policy $($policy.displayName): $($_.Exception.Message)" -ForegroundColor Red }
  }
} else { Write-Host "No endpoint security policies found." -ForegroundColor Yellow }

# Managed App Policies
if ($managedAppPolicies) {
  foreach ($policy in $managedAppPolicies) {
    try {
      $filePath = Join-Path $location ("ManagedApp - " + (Get-SafeFileName $policy.displayName) + ".json")
      $policy | ConvertTo-Json -Depth 10 | Out-File $filePath -Encoding UTF8
      if (Test-Path $filePath) {
        $Clean = Get-Content $filePath | Select-String -Pattern '"id":', '"createdDateTime":', '"lastModifiedDateTime":', '"version":' -NotMatch
        $Clean | Out-File -FilePath $filePath -Encoding UTF8
      }
      Write-Host "Exported managed app policy: $($policy.displayName)" -ForegroundColor Green
    }
    catch { Write-Host "Error exporting managed app policy $($policy.displayName): $($_.Exception.Message)" -ForegroundColor Red }
  }
} else { Write-Host "No managed app policies found." -ForegroundColor Yellow }
```