Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like 'USB*' } | Select-Object Name, InstanceId


SanDisk Cruzer USB Device      USBSTOR\DISK&VEN_SANDISK&PROD_CRUZER&REV_7.01\4054921625438DD9&0