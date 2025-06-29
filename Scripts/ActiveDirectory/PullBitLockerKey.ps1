$computerName = "MYPC01"  # Replace with your actual computer name
$computer = Get-ADComputer $computerName
$dn = $computer.DistinguishedName
Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase "CN=$computerName,$($dn.Substring($dn.IndexOf(',') + 1))" -Properties msFVE-RecoveryPassword |
Select-Object Name, msFVE-RecoveryPassword