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

## Policies

### Default Entra Domain

Configuration Type: Settings Catalog

![alt text](Images/DefaultEntraDomain.png)

---

### Time Zone

![alt text](Images/TimeZone.png)

---

### Delivery Optimization

Configuration Type: Settings Catalog

![alt text](Images/DeliveryOptimization.png)

---

### System Resources

Configuration Type: Properties Catalog

![alt text](Images/SystemResources.png)

---


