# Create NAT HyperV
## Original Source: https://activedirectorypro.com/how-to-create-a-nat-switch-on-hyper-v/

## My Notes

## Create Switch
```powershell
New-VMSwitch -Name SWITCHNAME -SwitchType Internal
```

## Get Index of new NetAdapter
```powershell
Get-NetAdapter
```
## Set IP Address Range for Switch
***Note: IP address range must be different compared to the range that is on the host***
```powershell
New-NetIPAddress –IPAddress 192.168.100.1 -PrefixLength 24 -InterfaceIndex 28
```

## Configure new Nat Network
```powershell
New-NetNat -Name Nat-Switch-Outside -InternalIPInterfaceAddressPrefix 192.168.100.0/24
```

## Configure VM 
Configure VM with the correct IP information and you are set
