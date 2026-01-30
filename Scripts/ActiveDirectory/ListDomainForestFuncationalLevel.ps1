# List the Domain and Forest Functional Levels in Active Directory using PowerShell
Get-ADDomain | Select DomainMode
Get-ADForest | Select ForestMode
