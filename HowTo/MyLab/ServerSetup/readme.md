# My Lab Setup

### Enable All ICMP Firewall Rules
```Powershell
Get-NetFirewallRule | Where-Object DisplayName -like "*ICMP*" | Enable-NetFirewallRule
```

## Prep each Hyper-V host
- Install roles/features
- On each host:
    - Hyper-V
    - Failover Clustering
    - Multipath I/O (MPIO) (strongly recommended for iSCSI)

PowerShell (run as admin):
```powershell
Install-WindowsFeature Hyper-V, Failover-Clustering, Multipath-IO -IncludeManagementTools -Restart
```

## NIC / network best practices (quick)
- Give iSCSI its own NIC(s) and don’t register iSCSI NICs in DNS.
- Ideally no default gateway on iSCSI NICs.
- Jumbo frames only if end-to-end supported (hosts + switches + SAN) and consistent.

## Configure MPIO for iSCSI (each host)
- Open MPIO control panel applet.
- On Discover Multi-Paths, check “Add support for iSCSI devices”.
- Reboot if prompted.

### Powershell Alternative
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName MultiPathIO
mpclaim -r -i -d "MSFT2005iSCSIBusType_0x9"
Restart-Computer
```

## Configure iSCSI Initiator service on BOTH nodes
```powershell
Set-Service MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
```

## Confirm
```powershell
Get-Service MSiSCSI
```

## On Host 1
### Create Binding for iSCSI Network
```powershell
New-IscsiTargetPortal `
  -TargetPortalAddress 172.16.0.40 `
  -InitiatorPortalAddress 172.16.0.10
```

## Connect with Binding
Connect-IscsiTarget `
  -NodeAddress "iqn.1991-05.com.microsoft:san-hvclustertarget-target" `
  -InitiatorPortalAddress 172.16.0.10 `
  -TargetPortalAddress 172.16.0.40 `
  -IsPersistent $true

## On Host 2
### Create Binding for iSCSI Network
```powershell
New-IscsiTargetPortal `
  -TargetPortalAddress 172.16.0.40 `
  -InitiatorPortalAddress 172.16.0.20
```

## Connect with Binding
Connect-IscsiTarget `
  -NodeAddress "iqn.1991-05.com.microsoft:san-hvclustertarget-target" `
  -InitiatorPortalAddress 172.16.0.20 `
  -TargetPortalAddress 172.16.0.40 `
  -IsPersistent $true

############################################################
## On Host 1
```powershell
$TargetPortalIP = "172.16.0.40"

New-IscsiTargetPortal -TargetPortalAddress $TargetPortalIP

Get-IscsiTarget | Select NodeAddress, IsConnected

# Connect all discovered targets
Get-IscsiTarget | Connect-IscsiTarget -IsPersistent $true
```
## on Host 2
```powershell
$TargetPortalIP = "172.16.0.40"

New-IscsiTargetPortal -TargetPortalAddress $TargetPortalIP
Get-IscsiTarget | Connect-IscsiTarget -IsPersistent $true
```
##############################################################


## On one host do the following to formate the disk correctly (Update your sizes based on disk created earlier)

### CSV Disk
```powershell
Get-Disk |
Where-Object {
    $_.BusType -eq 'iSCSI' -and
    $_.Size -gt 1500GB
} |
ForEach-Object {
    $part = New-Partition -DiskNumber $_.Number -UseMaximumSize
    Format-Volume -Partition $part -FileSystem ReFS -NewFileSystemLabel "CSV01" -Confirm:$false
}
```
### Witness Disk
```powershell
# Target the 2GB-ish iSCSI LUN (witness)
$disk = Get-Disk | Where-Object { $_.BusType -eq 'iSCSI' -and $_.Size -le 3GB } | Select-Object -First 1

$disk | Format-List Number, FriendlyName, Size, IsOffline, IsReadOnly, PartitionStyle

# Make sure it's online and not read-only
if ($disk.IsOffline) { Set-Disk -Number $disk.Number -IsOffline $false }
if ($disk.IsReadOnly) { Set-Disk -Number $disk.Number -IsReadOnly $false }

# If it's RAW, initialize it (GPT is fine)
if ((Get-Disk -Number $disk.Number).PartitionStyle -eq 'RAW') {
    Initialize-Disk -Number $disk.Number -PartitionStyle GPT
}

# Create partition and format
$part = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
Format-Volume -Partition $part -FileSystem NTFS -NewFileSystemLabel "Witness" -Confirm:$false

```
## Take disk offline
```powershell
Get-Disk |
Where-Object {
    $_.BusType -eq 'iSCSI'
} |
Set-Disk -IsOffline $true
```

## Sanity Check
```powershell
Get-Disk |
Where-Object BusType -eq 'iSCSI' |
Select Number, PartitionStyle, IsOffline, IsReadOnly
```
### You want 
You want:
- GPT
- Offline
- Not Read-only



## Run Cluster Validation (Resolve any Errors) (Run on one of the HyperV Host)
```powershell
Test-Cluster -Node HyperV01,HyperV02 -Include "Inventory","Network","System Configuration","Storage"
```

## Create Cluster
```powershell
New-Cluster -Name "HVCLUSTER" -Node HyperV01,HyperV02 -StaticAddress "192.168.0.50" -NoStorage
```

## Verify
```powershell
Get-Cluster
Get-ClusterNode
```

## Add the iSCSI disk to the cluster
## Displays the disk
```powershell
Get-ClusterAvailableDisk | Format-Table -Auto
```
## Add Them
```powershell
Get-ClusterAvailableDisk | Add-ClusterDisk
```

## Verify
```powershell
Get-ClusterResource | Where-Object ResourceType -eq "Physical Disk" | Format-Table Name, State, OwnerGroup -Auto
```

## Turn the big disk into a CSV
```powershell
Add-ClusterSharedVolume -Name "Cluster Disk 2"
```

## verify
```powershell
Get-ClusterSharedVolume | Format-Table -Auto
```

## Configure Witness Disk
```powershell
Set-ClusterQuorum -DiskWitness "Cluster Disk 1"
```

# Switch Setup

## Display current network adaptors
```powershell
Get-NetAdapter | Sort-Object Name | Format-Table Name, Status, LinkSpeed
```

## Create VMNetwork Switch
```powershell
New-VMSwitch `
  -Name "vSwitch-VMNetwork" `
  -NetAdapterName "Ethernet 4" `
  -AllowManagementOS $false

```
## Verify
```powershell
Get-VMSwitch | Format-Table Name, SwitchType, NetAdapterInterfaceDescription
```

## Set Default Path for Cluster Storage
```powershell
Set-VMHost `
  -VirtualMachinePath "C:\ClusterStorage\Volume2\VMs" `
  -VirtualHardDiskPath "C:\ClusterStorage\Volume2\VHDX"
```

## Verify
```powershell
Get-VMHost | Select VirtualMachinePath, VirtualHardDiskPath
```

## Test Speed of your storage
.\diskspd64.exe -c20G -b1M -d60 -o4 -t4 -W0 -Sh -L C:\ClusterStorage\Volume2\test.dat
