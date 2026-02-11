# How to Pin taskbar items via Intune

## This process is pretty straight forward. The most difficult part is to figure out what apps you want deployed and what info. 

- Gather a list of applications that are installed on your device
***note:This will display all your installed applications. Needed to gather the info

```powershell
get-startapps | sort-object name | select-object name, appid
```

![alt text](./assets/powershellcommand.png)