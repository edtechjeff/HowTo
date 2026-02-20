---
title: Scale Deployment Guide
author: Jeff Downs co-author Jeffrey Bergman
date: \today
toc: true
toc-depth: 3
---

# Purpose

Guide to setup a scale cluster

---

# Pre-Installation

## 1. Scale Nodes (3)
## 2. Rack and cable up machines

---

# Setup

## 1. Power on all nodes

## 2. Login to the first node
- User: admin
- Password: admin
- shift - disable console blanking
- Ctrl + Alt + F1 - Console session (switch?)

## 3. sudo scnodeinit 
- Used to setup IP info
- Password is still admin

## 4. Enter LAN Information
- IP
- Netmask
- Gateway
- Backplane IP (only used for the cluster
    - Need to be unique compared to the LAN IP)
    - Backplane IP for first node (this will be the same only for the first node)
- Enter unique Software Serial (no dashes required)

## 5. Once command prompt appears, setup is complete, move on to next node. Start back with Step 2
**Note:** The backplan IP will be different on each one

## 9. Once all nodes are setup
- Run scclusterinit (might be sudo scclusterinit)
- Wait for all nodes to appear, then press Ctrl-C. If all nodes show up, type yes to complete the cluster initilization.
- If all nodes aren't present, press Ctrl-C and type NO.
**Note:** Could take 15-20 minutes for cluster initilization.

## 10. Once the cluster is fully initialized:
- Navigate to any of the IPs for the nodes to reach AT3 UI
    - Username:	admin
	- Password:	admin
- Registration:
	- Fill out Company and Technical Contact info
- Add ISOs from Settings

## SNC - Single Node Cluster:
- Once command prompt appears, type:
- sudo singleNodeCluster=1 scclusterinit
- Press Ctrl-C > type yes

# Switch Information
On full sized Scale nodes with separate LAN and backplane connections, the VLANs are determined by the switch side connections.

Example configuration:

## 3 Nodes with separate LAN and Backplane connections
```text
    Management VLAN:	255
    Backplane VLAN (arbitrairly chosen):	422
    Node 1-3  	LAN port 0s connected to interfaces 1/1/7 thru 1/1/9
    Node 1-3	Backplane port 0s connected to interfaces 1/1/13 thru 1/1/15
```

**Note:***'s in description below stands for the Node #, 1 thru 3
```text
interface 1/1/7 AND 1/1/8 and 1/1/9
    description Scale*-L0
    no shutdown
    no routing
    vlan trunk native 255
    vlan trunk allowed 1-2,4,6,16,107,255
    exit


interface 1/1/13 AND 1/1/14 AND 1/1/15
    description Scale*-B0
    no shutdown
    no routing
    vlan access 422
    exit
```