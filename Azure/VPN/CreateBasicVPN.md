# Using some basic commands you could create a P2P VPN connection into Azure

```
$location = "eastus2"
$resourceGroup = "vpn-rg"
$vnetAddressSpace = "10.20.0.0/16"
$gatewaySubnet = "10.20.0.0/27"
New-AzResourceGroup -Name $resourceGroup -Location $location
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $gatewaySubnet
$vngwPIP = New-AzPublicIpAddress -Name myvngw-ip -ResourceGroupName $resourceGroup -Location $location -Sku Basic -AllocationMethod Dynamic
$vnet = New-AzVirtualNetwork -Name myvngw-vnet -ResourceGroupName $resourceGroup -Location $location -AddressPrefix $vnetAddressSpace -Subnet $subnetConfig
$subnet = Get-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet
$vngwIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name vngwipconfig -SubnetId $subnet.Id -PublicIpAddressId $vngwPIP.Id
New-AzVirtualNetworkGateway -Name myvngw-gw -ResourceGroupName $resourceGroup -Location $location -IpConfigurations $vngwIpConfig -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
```