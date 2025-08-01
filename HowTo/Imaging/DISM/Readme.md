# Quick Start Instructions
---

In this article we are going to cover how to setup a WDS server to PXE boot and utilize the ADK also. I found this great [article](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/system-builder-deployment?view=windows-11) that I got the original idea from and base files.  

# Files
There are files in this repo that will be used or replaced
- Apply-Image
    -  Apply-Image (File already exist but just modified to answer questions automatically)
    -  Apply-Image V2 (This file has additional modifications that will pull the Model name from the registry and inject drivers into the applied image use which ever one)
    - *Note in order for this to work correctly your drivers folders name will need to match that of the model name*
- MaintenanceTask (Used to perform extract and adding of drivers)
- MaintenanceTaskBasic (Not required, experimental)
- WinPEMenu (Main Menu System for imaging)

---

Here is a listing of items and things you need to have

 - Server Setup, can be virtual or physical
 - Create extra 100GB disk for images folder
 - Create 4GB disk for boot image creation
 - ADK downloaded on the server
 - Windows ISO

---

Once you get the server built 


- [Download Files](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/system-builder-deployment?view=windows-11#extract-imageszip)

- Extract contents from zip to the new drive just keep the name of images

- Share the images folder 

- Download the ADK's for Windows and install

- Create the following folders in images
    - Drivers
    - Source
    - Unattend
    - WinREMount

- Delete the following Files and Folder (You can keep these, but I like to clean things up)
    - Projects
    - Windows
    - WinPE
    - CreateImage
    - CreateProject
    - UpdateInboxApps

- Go into the Scripts folder and delete the following files and or folders (You can keep these, but I like to clean things up)
    - AutoPilot
    - Apply-Recovery
    - Apply-Image.bat
    - WinPEMenu.cmd

- Go back at the images folder

- In the drivers folder create the following folders
    - WinPE
    - RSTAT
    - Any other driver folders for your specific models

- In the source folder create a structure that will keep track of what version you are deploying IE

- Source
    - Windows11
        - 23H2
        - 24H2
        - NEXT Version
---


- [Download MaintenanceTask file](./MaintenanceTask/), move it to the `images` folder.

- [Download RemovePackages file](./Scripts/RemovePackages.ps1), move it to the `scripts` folder.
***Note*** Depending on what drive letter you have set as your images folder on the server you will need to edit the script to reflect that drive letter

- [Download CaptureImage file](./CaptureTask/), move it to the `scripts` folder ***(this will replace the existing file in that folder).***

- [Download Apply-Image file](./ApplyImageTask/), move it to the `scripts` folder. ***(This will replace the existing file in that folder).***
***Refer to the Readme file to choose which version. File needs to renamed to just Apply-Image.bat***

- [Download WinPEMenu file](./WinPEMenus/), move it to the `scripts` folder. ***(this will replace the existing file in that folder).***
***Refer to the Readme file to choose which version. File needs to renamed to just WinPEMenu.cmd***

- Now we have a base of what we need. You will need to download the WinPE drivers based on what manufacture you have. I am going with dell. The WinPE drivers are important part and you will need these. They will be injected into the WIM files 

- [DellDriverPack](https://www.dell.com/support/kbdoc/en-us/000211541/winpe-11-driver-pack)

- You will need to extract the files from the cab with the following command and adjusting to the name and path to where you want to extract, in our case it will be:
    - expand "WinPE11.0-Drivers-A05-TPKY4.cab" -f:* F:\Images\Drivers\WinPE 

The next driver is what is call the Intel Rapid Storage Driver. This driver is important because, from what I am seeing with Dell, the storage controller is set to RAID even though there might not be a raid setup. You can manually set it to AHCI but just by adding this driver will avoid this issue. 

- [Download this for the Intel Rapid Storage Driver](https://www.intel.com/content/www/us/en/download/19512/intel-rapid-storage-technology-driver-installation-software-with-intel-optane-memory-10th-and-11th-gen-platforms.html)

- Use the following extract the drivers and adjusting to the name and path to where you want to extract, in our case it will be:
    - SetupRST.exe -extractdrivers F:\Images\Drivers\RSTAT  

- Download ISO for Windows 11
    - Open up the ISO
    - go to sources
    - copy the Install.WIM to the correct folder and adjusting to the name and path to where you want to copy the files to, in our case it will be:
        f:\source\11\24H2  
---

## This pretty well gets you a basic setup for Imaging Windows 11 with WDS. 
## Refer to the original article with more information on the scripts and original intended purpose and how it all works, keep on learning something new. 


# Here are some options for DHCP Options. You can also use IP Helper Addresses instead of DHCP Options
## WDS Option 67

- 64-bit systems UEFI,
    - \boot\x64\wdsmgfw.efi
- 32-bit systems
    - \boot\x86\wdsmgfw.efi
- Legacy Boot
    - \boot\x86\pxeboot.com
    - Alternate: \Boot\PXEboot.n12 (skips the PXE prompt) 