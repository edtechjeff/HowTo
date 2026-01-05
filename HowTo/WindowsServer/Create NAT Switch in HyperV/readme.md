---
title: Create NAT switch in HyperV
author: Jeff Downs
date: January 5, 2026
---

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


## Full Script to Remove and Add Back in Netswitch
```powershell
<#
.SYNOPSIS
    Rebuilds a clean Hyper-V NAT switch and NAT object.

.DESCRIPTION
    - Removes any existing NAT objects named "NATNetwork"
    - Removes any existing VMSwitch named "NATSwitch"
    - Creates a new Internal switch called "NATSwitch"
    - Assigns host IP 10.5.1.1/23 to vEthernet (NATSwitch)
    - Creates NAT object covering 10.5.0.0/23

.NOTES
    Gateway (host) IP = 10.5.1.1
    Subnet mask       = 255.255.254.0 (/23)
    VM IP range       = 10.5.0.2 – 10.5.1.254
    NAT object name   = NATNetwork
    Switch name       = NATSwitch
#>

Write-Host "Cleaning up old NAT and switch..." -ForegroundColor Cyan
Get-NetNat -Name "NATNetwork" -ErrorAction SilentlyContinue | Remove-NetNat -Confirm:$false
Get-VMSwitch -Name "NATSwitch" -ErrorAction SilentlyContinue | Remove-VMSwitch -Force

Write-Host "Creating new NAT switch..." -ForegroundColor Cyan
New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal | Out-Null

Write-Host "Assigning host IP (10.5.1.1/23)..." -ForegroundColor Cyan
New-NetIPAddress -IPAddress 10.5.1.1 -PrefixLength 23 -InterfaceAlias "vEthernet (NATSwitch)" -DefaultGateway 10.5.1.1 -ErrorAction SilentlyContinue | Out-Null

Write-Host "Creating NAT object for 10.5.0.0/23..." -ForegroundColor Cyan
New-NetNat -Name "NATNetwork" -InternalIPInterfaceAddressPrefix 10.5.0.0/23 | Out-Null

Write-Host "Done! NAT switch rebuilt successfully." -ForegroundColor Green
Write-Host "Use the following VM settings:" -ForegroundColor Yellow
Write-Host "  IP Address   : 10.5.0.x or 10.5.1.x"
Write-Host "  Subnet Mask  : 255.255.254.0"
Write-Host "  Gateway      : 10.5.1.1"
Write-Host "  DNS          : 8.8.8.8 (or your preferred DNS)"
```