# Maintenace Task

- MaintenanceTaskBasic.cmd - Basic task used for initial testing and setup
- MaintenanceTaskV1.cmd - Basic task, just added more funcationality to the script
- MaintenanceTaskV2.cmd - Added the process to add windows cummulative updates to the WIM
- MaintenanceTaskV3.cmd - Changed out the export process to be dynamic based on the install.wim being used
    ***Note: Path for the WIM will have to be updated in order for this process to work***
- MaintenanceTaskV4.cmd - Updated from V3 to allow the command file to run as administrator
- MaintenanceTaskV5.cmd - This one will allow you to create folders for different versions. 
- MaintenanceTaskV6.cmd - Updates on the Export. Found issues when a local admin was created on the server, the account would not work for the export.  
    ***Please review the script for folder structure***