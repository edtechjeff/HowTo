# Lists all Global Catalog servers in the Active Directory domain
Get-ADDomainController -Filter * | Where-Object {$_.IsGlobalCatalog -eq $true} |
Select-Object HostName, Site, IPv4Address
