---
title: "Unattended Files"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Title: Unattended.xml Files

## Purpose: Unattend Files used as part of the imaging process. 

## Whats in the directory: Different examples of what you can do to with an unattend.xml file

## How to use them: These fill need to be copied to C:\Windows\Panther Directory. If that directory is not there then create it and copy the .XML to it. Windows will use this file if its located in the directory

## How to edit: You can manually edit the file vi text editor, or you can use the Windows Admin kit tool Windows System Image Manager

- Unattend-Enables-Administrator.xml - Enables local admin and sets the password
- Unattend-EnablesAdmnistrator.xml -Creates-Additional-Admin-User - Enables local admin and also creates another local admin
- EnableBuiltInAdminBiosUpdate.xml - Enables local admin and sets the password, does BIOS Update ***Note will need to have the files copied to the image and also rename files to match***
- EnableBuiltInAdminCreateCustomAdminAccountBiosUpdate.xml - Creates-Additional-Admin-User - Enables local admin and also creates another local admin, does BIOS Update ***Note will need to have the files copied to the image and also rename files to match***
- Creates2AdminUsers.xml - Creates to local admin users and sets local admin account password but does not enable account