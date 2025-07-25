# Dynamic Group Memberships

## Used to pull devices with specified model Number
(device.devicePhysicalIDs -any (_ -contains "SystemSKUNumber:MODEL123"))

## Used to pull devices with specified Purchase Order Number
(device.devicePhysicalIDs -any (_ -contains "PurchaseOrderID:PO12345"))

## Used to pull devices with specified "Group Tag" for AutoPilot
(device.devicePhysicalIds -any (_ -eq "[OrderID]:Teacher"))

