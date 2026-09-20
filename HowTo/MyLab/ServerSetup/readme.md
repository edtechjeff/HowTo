---
title: Server Side Setupl Information
author: Jeff Downs
date: January 5, 2026
---

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
***Note:*** Target is the iSCSI SAN and Initiator is the HyperV iSCSI IP
```powershell
New-IscsiTargetPortal `
  -TargetPortalAddress 10.10.20.36 `
  -InitiatorPortalAddress 10.10.20.33
```

## Connect with Binding
```powershell
Connect-IscsiTarget `
  -NodeAddress "iqn.1991-05.com.microsoft:storage1-hvclustertarget-target" `
  -InitiatorPortalAddress 10.10.20.36 `
  -TargetPortalAddress 10.10.20.33 `
  -IsPersistent $true
```

## On Host 2
### Create Binding for iSCSI Network
```powershell
New-IscsiTargetPortal `
  -TargetPortalAddress 10.10.20.36 `
  -InitiatorPortalAddress 10.10.20.34
```

## Connect with Binding
```powershell
Connect-IscsiTarget `
  -NodeAddress "iqn.1991-05.com.microsoft:san-hvclustertarget-target" `
  -InitiatorPortalAddress 10.10.20.36 `
  -TargetPortalAddress 10.10.20.34 `
  -IsPersistent $true
```

############################################################
## On Host 1
```powershell
$TargetPortalIP = "10.10.20.33"

New-IscsiTargetPortal -TargetPortalAddress $TargetPortalIP

Get-IscsiTarget | Select NodeAddress, IsConnected

# Connect all discovered targets
Get-IscsiTarget | Connect-IscsiTarget -IsPersistent $true
```
## on Host 2
```powershell
$TargetPortalIP = "10.10.20.33"

New-IscsiTargetPortal -TargetPortalAddress $TargetPortalIP
Get-IscsiTarget | Connect-IscsiTarget -IsPersistent $true
```
##############################################################


## On one host do the following to formate the disk correctly (Update your sizes based on disk created earlier)

1. Identify the iSCSI Disks

Display only disks connected through iSCSI:
```powershell
Get-Disk |
    Where-Object BusType -eq 'iSCSI' |
    Format-Table Number,FriendlyName,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},
        PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto
```
Example:

Number FriendlyName    SizeGB PartitionStyle OperationalStatus IsOffline IsReadOnly
------ ------------    ------ -------------- ----------------- --------- ----------
1      MSFT Virtual HD      2 RAW            Offline           True      True
2      MSFT Virtual HD   1536 RAW            Offline           True      True

In this example:

Disk 1 = 2 GB Witness
Disk 2 = 1.5 TB CSV

Verify the disk numbers and sizes before continuing. Do not assume your disk numbers will always be 1 and 2.

Prepare the CSV Disk

For this example, the CSV is Disk 2.

2. Make the CSV Disk Writable and Online
Set-Disk -Number 2 -IsReadOnly $false
Set-Disk -Number 2 -IsOffline $false

Verify:
```powershell
Get-Disk -Number 2 |
    Format-Table Number,Size,PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto
```
For a new disk, you want:

PartitionStyle : RAW
IsOffline      : False
IsReadOnly     : False
3. Initialize the CSV Disk

If the disk shows RAW, initialize it as GPT:

Initialize-Disk -Number 2 -PartitionStyle GPT

Verify:
```powershell
Get-Disk -Number 2 |
    Format-Table Number,PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto
```
The partition style should now be:

GPT
4. Create the CSV Partition
```powershell
$CSVPart = New-Partition `
    -DiskNumber 2 `
    -UseMaximumSize `
    -AssignDriveLetter
```

5. Format the CSV as ReFS
```powershell
Format-Volume `
    -Partition $CSVPart `
    -FileSystem ReFS `
    -NewFileSystemLabel "CSV01" `
    -Confirm:$false
```
Verify:
```powershell
Get-Volume |
    Where-Object FileSystemLabel -eq "CSV01" |
    Format-Table DriveLetter,FileSystemLabel,FileSystem,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},
        HealthStatus -Auto
```
The CSV should show:

FileSystemLabel : CSV01
FileSystem      : ReFS
HealthStatus    : Healthy
Prepare the Witness Disk

For this example, the 2 GB witness is Disk 1.

6. Make the Witness Disk Writable and Online
```powershell
Set-Disk -Number 1 -IsReadOnly $false
Set-Disk -Number 1 -IsOffline $false
```
Verify:
```powershell
Get-Disk -Number 1 |
    Format-Table Number,Size,PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto
```
For a new disk, you want:

PartitionStyle : RAW
IsOffline      : False
IsReadOnly     : False
7. Initialize the Witness Disk
```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
```powershell
8. Create the Witness Partition
```powershell
$WitnessPart = New-Partition `
    -DiskNumber 1 `
    -UseMaximumSize `
    -AssignDriveLetter
```
9. Format the Witness as NTFS
```powershell
Format-Volume `
    -Partition $WitnessPart `
    -FileSystem NTFS `
    -NewFileSystemLabel "Witness" `
    -Confirm:$false
```
10. Verify Both Disks

Check the iSCSI disks:
```powershell
Get-Disk |
    Where-Object BusType -eq 'iSCSI' |
    Format-Table Number,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},
        PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto
```
Check the formatted volumes:
```powershell
Get-Volume |
    Where-Object FileSystemLabel -in "Witness","CSV01" |
    Format-Table DriveLetter,FileSystemLabel,FileSystem,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},
        HealthStatus -Auto
```
Expected result:

FileSystemLabel   FileSystem   Approximate Size
---------------   ----------   ----------------
Witness           NTFS         2 GB
CSV01             ReFS         1.5 TB

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
Test-Cluster -Node HV01,HV02 -Include "Inventory","Network","System Configuration","Storage"
```

## Create Cluster
```powershell
New-Cluster -Name "HVCLUSTER" -Node HV01,HV02 -StaticAddress "10.10.30.33" -NoStorage
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
  -VirtualMachinePath "C:\ClusterStorage\Volume1\VMs" `
  -VirtualHardDiskPath "C:\ClusterStorage\Volume1\VHDX"
```

## Verify
```powershell
Get-VMHost | Select VirtualMachinePath, VirtualHardDiskPath
```

## Test Speed of your storage
.\diskspd64.exe -c20G -b1M -d60 -o4 -t4 -W0 -Sh -L C:\ClusterStorage\Volume2\test.dat
