# Intune Setup
## ***Topics I cover during implmentation***

## Groups Naming Convention
![alt text](Images/Groups.png)

## Dynamic Groups

### AutoPilot Device
```
(device.devicePhysicalIDs -any (_ -startsWith "[ZTDid]"))
```

### Devies that are MDM,Company Owned, Hybrid Joined
```
(device.managementType -eq "MDM") and (device.deviceOwnership -eq "Company") and (device.deviceTrustType -eq "ServerAD")
```

### Devices that are MDM, Company Owned, EntraID Joined
```
(device.managementType -eq "MDM") and (device.deviceOwnership -eq "Company") and (device.deviceTrustType -eq "AzureAD")
```
---

### Devices that have a specific Group Tag
```
(device.devicePhysicalIds -any _ -eq "[OrderID]:StaffDevice") 
```

### Devices that have a PurchaseOrder
```
(device.devicePhysicalIds -any _ -eq "[PurchaseOrderId]:0123456789")
```

## Policies

### Default Entra Domain

Configuration Type: Settings Catalog

![Default Entra Domain](Images/DefaultEntraDomain.png)

---

### Time Zone

![Time Zone](Images/TimeZone.png)

---

### Delivery Optimization

Configuration Type: Settings Catalog

![Delivery Optimization](Images/DeliveryOptimization.png)

---

### System Resources

Configuration Type: Properties Catalog

![System Resources](Images/SystemResources.png)

---

### One Drive Auto Setup

---
Platform: Windows 10 or Later

Profile Type: Settings Catalog

![OneDrive](Images/OneDrive.png)