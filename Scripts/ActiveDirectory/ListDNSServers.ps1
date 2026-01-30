# Check the DNS servers for a specific domain using PowerShell
# Replace 'yourdomain.local' with the domain you want to check
Resolve-DnsName yourdomain.local -Type NS
