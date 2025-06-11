# These steps are just to rip out VMware tools if it has been migrated to another Non-vmware host and the tools will not remove
# There might be other places to remove items but this is what I have found that takes it off the system

```
sc stop vmtools
sc delete vmtools
sc delete VMVSS
sc delete VM3DService
sc delete VGAuthService
```

- Manually delete VMware Tools installation files under these locations. 
    ***Note: Select the appropriate user and username in the machine in the path.***
```
C:\Program Files\VMware
C:\Program Files\Common Files\VMware
C:\ProgramData\VMware
```
- Delete VMware.Inc from Regedit > HKEY_LOCAL_MACHINE\SOFTWARE\VMware.Inc

- Delete VMware.Inc from Regedit > HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\VMware.Inc


- Browse to HKLM \Software\Microsoft\Windows\CurrentVersion\uninstall.
	***Note: There you'll have to search for the branch with a key named DisplayName and has a value of VMware Tools***

- Browse to HKLM\Software\Classes\Installer\Products
	***Note: Search for the branch with the key named ProductName and has a value of VMware Tools . Delete the branch associated with that entry.***