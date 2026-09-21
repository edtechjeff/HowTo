---
title: Lab Setup
author: Jeff Downs
date: January 5, 2026
---

## The following document is intended to show you how to setup iSCSI in a lab and also setup a HyperV cluster.  
***IP Information***

| Host Name |  IP Address | Description |
| ---------|--------------|-------------|
| HV01 | 192.168.0.31 | Management  |
| HV01 | 10.10.20.31  | iSCSI       |
| HV02 | 192.168.0.32| Management  |
| HV02 | 10.10.20.32  | iSCSI       |
| HV03 | 192.168.0.33 | Management |
| HV03 | 10.10.20.33 | iSCSI |
| HV04 | 192.168.0.34 | Management |
| HV04 | 10.10.20.34 | iSCSI |
| STORAGE01 | 192.168.0.36 | Management  |
| STORAGE01 | 10.10.20.36  | iSCSI       |
| Cluster  | 10.10.30.40 | Cluster IP  |
| DC1      | 192.168.0.30 | Management  |
| DC2      | 192.168.0.35 | Management  |




| DHCP1    | 192.168.0.12 | DHCP Server |
| DHCP2    | 192.168.0.22 | DHCP Server |

|----------|--------------|-------------|


### Pre-Reqs
- Domain Controller - I have mine hosted on an external box, very important
- 2 Host both joined to domain
- 1 Windows host for iSCSI. Can be any iSCSI, but I used Windows

### Server Specs
- Each Hyper-V host will need the following
  - 1 NIC for management
  - 1 NIC for iSCSI traffic
- San Specs
  - 1 NIC for management
  - 1 NIC for iSCSI traffic

### Steps

---
title: iSCSI and Hyper-V Failover Cluster Setup
author: Jeff Downs
date: January 5, 2026
---

# My Lab Setup

## Part 1 - STORAGE1 Setup

### Enable All ICMP Firewall Rules

```powershell
Get-NetFirewallRule | Where-Object DisplayName -like "*ICMP*" | Enable-NetFirewallRule
```

# Steps for SAN using a Windows Server

## Install iSCSI Target role

- On Storage1:
- Server Manager
- Add roles and features → File and Storage Services → File and iSCSI Services → iSCSI Target Server

### Powershell Alternative

```powershell
Install-WindowsFeature FS-iSCSITarget-Server -IncludeManagementTools
```

## Verify

```powershell
Get-WindowsFeature FS-iSCSITarget-Server
```

## Prep storage on SAN01

- In Disk Management:
- Initialize disks (GPT)
- Create NTFS or ReFS volumes

Example:

```text
G:\iSCSI\
```

## Create Folder to store files

```powershell
New-Item -Path "G:\iSCSI" -ItemType Directory -Force
```

**These disks stay local to SAN01. You’ll expose space via VHDX files.**

## Create iSCSI virtual disks (LUNs)

- Server Manager:
- File and Storage Services → iSCSI → Tasks → New iSCSI Virtual Disk

Create:

- Witness disk – e.g., 1–5 GB
- CSV disk(s) – e.g., 500 GB / 1 TB / whatever you need

Example:

```text
G:\iSCSI\HV-Witness.vhdx → 2 GB
G:\iSCSI\HV-CSV01.vhdx → 1.5 TB
```

### Powershell

**Note:** Creating a large fixed iSCSI virtual disk can take considerable time because the storage is allocated during creation. Do not rerun New-IscsiVirtualDisk just because the command appears to be taking a long time.

```powershell
New-IscsiVirtualDisk -Path "G:\iSCSI\HV-Witness.vhdx" -Size 2GB -UseFixed

New-IscsiVirtualDisk -Path "G:\iSCSI\HV-CSV01.vhdx" -Size 1.5TB
```

## Verify disk created

```powershell
Get-IscsiVirtualDisk |
    Format-Table Path,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -Auto
```

# STOP - Switch to HV03 and HV04

At this point, continue with the Hyper-V host preparation below. After the iSCSI Initiator service is configured on both hosts, pull the IQN from each host and return to the STORAGE1 section.


# Part 2 - HV03 and HV04 Initial Setup

**## Prep each Hyper-V host**

- Install roles/features

- On each host:

    - Hyper-V

    - Failover Clustering

    - Multipath I/O (MPIO) (strongly recommended for iSCSI)

PowerShell (run as admin):

```powershell

Install-WindowsFeature Hyper-V, Failover-Clustering, Multipath-IO -IncludeManagementTools -Restart

```

**## NIC / network best practices (quick)**

- Give iSCSI its own NIC(s) and don’t register iSCSI NICs in DNS.

- Ideally no default gateway on iSCSI NICs.

- Jumbo frames only if end-to-end supported (hosts + switches + SAN) and consistent.

**## Configure MPIO for iSCSI (each host)**

- Open MPIO control panel applet.

- On Discover Multi-Paths, check “Add support for iSCSI devices”.

- Reboot if prompted.

**### Powershell Alternative**

```powershell

Enable-WindowsOptionalFeature -Online -FeatureName MultiPathIO

mpclaim -r -i -d "MSFT2005iSCSIBusType_0x9"

Restart-Computer

```

**## Configure iSCSI Initiator service on BOTH nodes**

```powershell

Set-Service MSiSCSI -StartupType Automatic

Start-Service MSiSCSI

```

**## Confirm**

```powershell

Get-Service MSiSCSI

```

**## Pull IQN (Run on each host)**

```powershell

(Get-InitiatorPort).NodeAddress

```

# STOP - Return to STORAGE1

Record the IQN from HV03 and HV04, then return to STORAGE1 and continue with the target configuration.


# Part 3 - Return to STORAGE1

## Create an iSCSI target

- This defines who can connect.
- Server Manager → iSCSI → New iSCSI Target

Add initiators:

- By DNS name (recommended):
- HV03.domain.local
- HV04.domain.local

Or by IQN from each host’s iSCSI Initiator.

Name:

- HVClusterTarget

## Multiple IQN

```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hv03.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hv04.ad.edtechjeff.com"
```

# Other Commands

### Adding a Single IQN

```powershell
New-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds "IQN:iqn.1991-05.com.microsoft:hv03"
```

### Add and IQN to existing target

```powershell
Set-IscsiServerTarget `
  -TargetName "HVClusterTarget" `
  -InitiatorIds `
    "IQN:iqn.1991-05.com.microsoft:hv03.ad.edtechjeff.com",
    "IQN:iqn.1991-05.com.microsoft:hv04.ad.edtechjeff.com"
```

## Verify

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" | Select TargetName
```

## Map virtual disks to target

- Attach both LUNs to the target.

```powershell
Add-IscsiVirtualDiskTargetMapping `
    -TargetName "HVClusterTarget" `
    -Path "G:\iSCSI\HV-Witness.vhdx" `
    -Lun 0

Add-IscsiVirtualDiskTargetMapping `
    -TargetName "HVClusterTarget" `
    -Path "G:\iSCSI\HV-CSV01.vhdx" `
    -Lun 1
```

## Verify

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,InitiatorIds,LunMappings,Sessions,Status
```

## What it will display

```text
LUN 0 → G:\iSCSI\HV-Witness.vhdx
LUN 1 → G:\iSCSI\HV-CSV01.vhdx
```

# Verify virtual disks

```powershell
Get-IscsiVirtualDisk |
    Format-Table Path,
        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -Auto
```

# Verify target

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,TargetIqn,InitiatorIds,Status
```

# Verify LUN mappings

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Select-Object -ExpandProperty LunMappings
```

## (Optional) Enable CHAP authentication

- If you want security beyond IP/DNS

```powershell
# Create the CHAP credentials

$ChapSecret = ConvertTo-SecureString `
    -String "YourChapSecretHere" `
    -AsPlainText `
    -Force

$ChapCredential = New-Object `
    System.Management.Automation.PSCredential `
    ("hvchap", $ChapSecret)

# Enable CHAP on the iSCSI target

Set-IscsiServerTarget `
    -TargetName "HVClusterTarget" `
    -EnableChap $true `
    -Chap $ChapCredential
```

## Verify

```powershell
Get-IscsiServerTarget `
    -TargetName "HVClusterTarget" |
    Format-List TargetName,EnableChap,EnableReverseChap
```

## Firewall

```powershell
Get-NetFirewallRule | ? DisplayName -like "*iSCSI*"
```

# STOP - Return to HV03 and HV04

The target and LUN mappings are now configured. Return to the Hyper-V server instructions and continue with the Host 1 and Host 2 iSCSI connections.


# Part 4 - Return to HV03 and HV04

**## On Host 1**

**### Create Binding for iSCSI Network**

********Note:******** Target is the iSCSI SAN and Initiator is the HyperV iSCSI IP

```powershell

New-IscsiTargetPortal `

    -TargetPortalAddress "10.10.20.36" `

    -InitiatorPortalAddress "10.10.20.33"

$Target = Get-IscsiTarget |

    Where-Object NodeAddress -eq "iqn.1991-05.com.microsoft:storage1-hvclustertarget-target"

Connect-IscsiTarget `

    -NodeAddress $Target.NodeAddress `

    -IsPersistent $true `

    -InitiatorPortalAddress "10.10.20.33" `

    -TargetPortalAddress "10.10.20.36"

```

**## On Host 2**

**### Create Binding for iSCSI Network**

```powershell

New-IscsiTargetPortal `

    -TargetPortalAddress "10.10.20.36" `

    -InitiatorPortalAddress "10.10.20.34"

$Target = Get-IscsiTarget |

    Where-Object NodeAddress -eq "iqn.1991-05.com.microsoft:storage1-hvclustertarget-target"

Connect-IscsiTarget `

    -NodeAddress $Target.NodeAddress `

    -IsPersistent $true `

    -InitiatorPortalAddress "10.10.20.34" `

    -TargetPortalAddress "10.10.20.36"

```


# Optional - Return to STORAGE1 to Verify Connected Sessions

Once HV03/HV04 are connected:

```powershell
Get-IscsiServerTarget -TargetName "HVClusterTarget" |
    Format-List TargetName,InitiatorIds,LunMappings,Sessions,Status
```

# Return to the Hyper-V Host Setup

Continue with disk preparation and cluster creation on the Hyper-V hosts.

# Part 5 - Complete Hyper-V Cluster Setup

**## Only on ONE host do the following to format the disk correctly (Update your sizes based on disk created earlier)**

**## Verify**

```powershell

Get-IscsiTargetPortal

Get-IscsiTarget

Get-IscsiSession

```

1\. Identify the iSCSI Disks

Display only disks connected through iSCSI:

```powershell

Get-Disk |

    Where-Object BusType -eq 'iSCSI' |

    Format-Table Number,FriendlyName,

        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},

        PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto

```

Example:

```text

Number FriendlyName    SizeGB PartitionStyle OperationalStatus IsOffline IsReadOnly

------ ------------    ------ -------------- ----------------- --------- ----------

1      MSFT Virtual HD      2 RAW            Offline           True      True

2      MSFT Virtual HD   1536 RAW            Offline           True      True

```

In this example:

```text

Disk 1 = 2 GB Witness

Disk 2 = 1.5 TB CSV

```

Verify the disk numbers and sizes before continuing. Do not assume your disk numbers will always be 1 and 2.

Prepare the CSV Disk

For this example, the CSV is Disk 2.

2\. Make the CSV Disk Writable and Online

```powershell

Set-Disk -Number 2 -IsReadOnly $false

Set-Disk -Number 2 -IsOffline $false

```

Verify:

```powershell

Get-Disk -Number 2 |

    Format-Table Number,Size,PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto

```

For a new disk, you want:

```text

PartitionStyle : RAW

IsOffline      : False

IsReadOnly     : False

```

3\. Initialize the CSV Disk

If the disk shows RAW, initialize it as GPT:

```powershell

Initialize-Disk -Number 2 -PartitionStyle GPT

```

Verify:

```powershell

Get-Disk -Number 2 |

    Format-Table Number,PartitionStyle,OperationalStatus,IsOffline,IsReadOnly -Auto

```

The partition style should now be:

```text

GPT

```

4\. Create the CSV Partition

```powershell

$CSVPart = New-Partition `

    -DiskNumber 2 `

    -UseMaximumSize `

    -AssignDriveLetter

```

5\. Format the CSV as ReFS

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

```text

FileSystemLabel : CSV01

FileSystem      : ReFS

HealthStatus    : Healthy

```

Prepare the Witness Disk

For this example, the 2 GB witness is Disk 1.

6\. Make the Witness Disk Writable and Online

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

```text

PartitionStyle : RAW

IsOffline      : False

IsReadOnly     : False

```

7\. Initialize the Witness Disk

```powershell

Initialize-Disk -Number 1 -PartitionStyle GPT

```

8\. Create the Witness Partition

```powershell

$WitnessPart = New-Partition `

    -DiskNumber 1 `

    -UseMaximumSize `

    -AssignDriveLetter

```

9\. Format the Witness as NTFS

```powershell

Format-Volume `

    -Partition $WitnessPart `

    -FileSystem NTFS `

    -NewFileSystemLabel "Witness" `

    -Confirm:$false

```

10\. Verify Both Disks

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

```text

FileSystemLabel   FileSystem   Approximate Size

---------------   ----------   ----------------

Witness           NTFS         2 GB

CSV01             ReFS         1.5 TB

```

**## Take disk offline**

********Note******** Only use this before the disks have been added to Failover Clustering. Once a disk is cluster-managed, manage it through Failover Clustering rather than Set-Disk.

```powershell

Get-Disk |

Where-Object {

    $_.BusType -eq 'iSCSI'

} |

Set-Disk -IsOffline $true

```

**## Sanity Check**

```powershell

Get-Disk |

Where-Object BusType -eq 'iSCSI' |

Select Number, PartitionStyle, IsOffline, IsReadOnly

```

**### You want** 

```text

You want:

- GPT

- Offline

- Not Read-only

```



**## Run Cluster Validation (Resolve any Errors) (Run on one of the HyperV Host)**

```powershell

Test-Cluster -Node HV03,HV04 -Include "Inventory","Network","System Configuration","Storage"

```

**## Post Test Sanity Check**

```powershell

Test-Cluster -Node HV03,HV04

```

**## Sanity Check**

```powershell

Get-Disk |

    Where-Object BusType -eq 'iSCSI' |

    Format-Table Number,

        @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},

        IsOffline,IsReadOnly,IsClustered -Auto

```

**## Pre-Check**

```powershell

Get-ADComputer -Identity "HVCLUSTER" -ErrorAction SilentlyContinue

Resolve-DnsName HVCLUSTER -ErrorAction SilentlyContinue

Test-Connection 192.168.0.41 -Count 2 -Quiet

```

**## Create Cluster**

```powershell

New-Cluster `

    -Name "HVCLUSTER" `

    -Node HV03,HV04 `

    -StaticAddress "192.168.0.41" `

    -NoStorage

```

**## Verify**

```powershell

Get-Cluster

Get-ClusterNode |

    Format-Table Name,State -Auto

Get-ClusterNetwork |

    Format-Table Name,Address,Role,State -Auto

Get-ClusterResource |

    Format-Table Name,ResourceType,State,OwnerNode,OwnerGroup -Auto

```

**## Add the iSCSI disk to the cluster**

**# See disks available to clustering**

```powershell

Get-ClusterAvailableDisk | Format-Table -Auto

```

```powershell

# Add them

Get-ClusterAvailableDisk | Add-ClusterDisk

```

**# Verify cluster disk resources**

```powershell

Get-ClusterResource |

    Where-Object ResourceType -eq "Physical Disk" |

    Format-Table Name,State,OwnerGroup,OwnerNode -Auto

```

**## Turn the big disk into a CSV**

```powershell

Add-ClusterSharedVolume -Name "Cluster Disk 2"

```

**## verify**

```powershell

Get-ClusterSharedVolume | Format-Table -Auto

```

**## Configure Witness Disk**

```powershell

Set-ClusterQuorum -DiskWitness "Cluster Disk 1"

```

**## Final Cluster Storage Verification**

Verify that the CSV is configured and online:

```powershell

Get-ClusterSharedVolume |

    Format-Table Name,State,OwnerNode -Auto

```

**## Verify Quorum**

```powershell

Get-ClusterQuorum

```

**## Verify Disk and Current Owners**

```powershell

Get-ClusterResource |

    Where-Object ResourceType -eq "Physical Disk" |

    Format-Table Name,State,OwnerGroup,OwnerNode -Auto

```

**# Switch Setup**

**## Display current network adaptors**

```powershell

Get-NetAdapter | Sort-Object Name | Format-Table Name, Status, LinkSpeed

```

**## Create VMNetwork Switch**

```powershell

New-VMSwitch `

  -Name "vSwitch-VMNetwork" `

  -NetAdapterName "Ethernet 4" `

  -AllowManagementOS $false

```

**## Verify**

```powershell

Get-VMSwitch | Format-Table Name, SwitchType, NetAdapterInterfaceDescription

```

**## Set Default Path for Cluster Storage**

```powershell

Set-VMHost `

  -VirtualMachinePath "C:\ClusterStorage\Volume1\VMs" `

  -VirtualHardDiskPath "C:\ClusterStorage\Volume1\VHDX"

```

**## Verify**

```powershell

Get-VMHost | Select VirtualMachinePath, VirtualHardDiskPath

```

**## Verify Cluster Volume**

```powershell

Get-ClusterSharedVolume |

    Select-Object Name,@{N='Path';E={$_.SharedVolumeInfo.FriendlyVolumeName}}

```

# Disk Speed Download

https://github.com/Microsoft/diskspd/releases/latest/download/DiskSpd.zip

**## Test Speed of your storage**

.\diskspd.exe -c20G -b1M -d60 -o4 -t4 -W0 -Sh -L C:\ClusterStorage\Volume1\test.dat

## Check Link Speed of network adapter
```powershell
Get-NetAdapter |
    Format-Table Name,InterfaceDescription,Status,LinkSpeed -Auto
```


