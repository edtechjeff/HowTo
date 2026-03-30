---
title: "Maintenance Task"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Title: Maintenace Task

---

## Purpose: Maintenance Task Details

---

1. MaintenanceTaskBasic.cmd
    - Basic task used for initial testing and setup
2. MaintenanceTaskV1.cmd -
    - Added more funcationality to the script
3. MaintenanceTaskV2.cmd
    - Added the process to add windows cummulative updates to the WIM
4. MaintenanceTaskV3.cmd
    - Changed out the export process to be dynamic based on the install.wim being used

    ***Note: Path for the WIM will have to be updated in order for this process to work***
5. MaintenanceTaskV4.cmd
    - Updated from V3 to allow the command file to run as administrator
6. MaintenanceTaskV5.cmd
    - Allow you to create folders for different versions. 
7. MaintenanceTaskV6.cmd - 
    - Updates on the Export. Found issues when a local admin was created on the server, the account would not work for the export.  
    
    ***Please review the script for folder structure***
8. MaintenanceTaskV7.cmd 
    - Added section to disable Online Content
