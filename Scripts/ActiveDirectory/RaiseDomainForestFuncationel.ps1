# Import the Active Directory module
Import-Module ActiveDirectory

# Get current Domain Functional Level
Get-ADDomain | Select-Object Name, DomainMode

# Get current Forest Functional Level
Get-ADForest | Select-Object Name, ForestMode

# Raise the Domain Functional Level to Windows Server 2016
# Example: Raise to Windows Server 2016
Set-ADDomainMode -Identity "domain.local" -DomainMode Windows2016Domain

# Example: Raise to Windows Server 2016
Set-ADForestMode -Identity "domain.local" -ForestMode Windows2016Forest


