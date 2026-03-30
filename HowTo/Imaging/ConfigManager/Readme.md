---
title: "ConfigManager Imaging Documentation"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# ConfigManager Imaging Documentation

***Note*** This process is very basic. Was developed and tested to resolve an issue that I moved on and used other methods of imaging using DISM \ WDS instead of Config Manager

This repository contains resources and documentation related to imaging processes using Configuration Manager (ConfigMgr). The purpose of this repository was to use Config Manager to image devices and then provide a method to remove the Config Manager tools after imaging

## Usage

1. Setup a task sequence as part of the deployment task to run copy.cmd
2. After imaging copy.cmd would run and copy PrepareOOBE.ps1 to c:\windows\temp
3. Task then would be setup to run PrepareOOBE.ps1 and then remove Config Manager Tools






