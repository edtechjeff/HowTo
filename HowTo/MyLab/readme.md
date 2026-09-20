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
  - 1 NIC for VM Network Traffic
  - 1 NIC for iSCSI traffic
- San Specs
  - 1 NIC for management
  - 1 NIC for iSCSI traffic

### Steps
- Setup your san using the iSCSISetup readme
- Setup your Servers using the ServerSetup readme

