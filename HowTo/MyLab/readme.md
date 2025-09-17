# My Lab Setup

### Enable All ICMP Firewall Rules
```Powershell
Get-NetFirewallRule | Where-Object DisplayName -like "*ICMP*" | Enable-NetFirewallRule
```

