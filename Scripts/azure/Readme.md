# Commands you might have to run

- Ensure Az Module are Installed and Imported
```
Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber
```
- Import AZ Modules
```
Import-Module Az
```
Connect to Azure
```
Connect-AzAccount
```
- List Subscriptions
```
Get-AzSubscription
```
- Set Subscription by ID
```
Set-AzContext -SubscriptionId "your-subscription-id"
```
- Set Subscription by Name
```
Set-AzContext -SubscriptionName "your-subscription-name"
```
- Verify Subscription
```
Get-AzContext
```

