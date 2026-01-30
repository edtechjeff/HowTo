---
title: Lab Setup
author: Jeff Downs
date: January 5, 2026
---

## The following document is intended to show you how to setup iSCSI in a lab and also setup a HyperV cluster.  
***IP Information***

| Host Name |  IP Address | Description |
| ---------|--------------|-------------|
| HyperV01 | 192.168.0.10 | Management  |
| HyperV01 | 192.168.0.11 | vmNetwork   |
| DHCP1    | 192.168.0.12 | DHCP Server |
| HyperV01 | 172.16.0.10  | iSCSI       |
| HyperV02 | 192.168.0.20 | Management  |
| HyperV02 | 192.168.0.21 | vmNetwork   |
| DHCP2    | 192.168.0.22 | DHCP Server |
| Hyperv02 | 172.16.0.20  | iSCSI       |
| DC1      | 192.168.0.30 | Management  |
| SAN      | 192.168.0.40 | Management  |
| SAN      | 172.16.0.40  | iSCSI       |
| Cluster  | 192.168.0.50 | Cluster IP  |
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

