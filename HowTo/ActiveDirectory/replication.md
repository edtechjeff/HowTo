# issues with replication


# get GUID of None Good AD and run on it

```powershell
repadmin /showrepl "NameOfKnownGoodDC"
```

## will look something like this
```
DSA object GUID: bdfb4d56-23ae-4d7a-bd7b-77f80b472d32
```

## run in advisory mode to see what changes will happen
## replace GUID with one that you pulled from previous command
repadmin /removelingeringobjects "NameOfKnownGoodDC" bdfb4d56-23ae-4d7a-bd7b-77f80b472d32 "DC=edtechjeff,DC=local" /advisory_mode
repadmin /removelingeringobjects "NameOfKnownGoodDC" bdfb4d56-23ae-4d7a-bd7b-77f80b472d32 "CN=Configuration,DC=edtechjeff,DC=local" /advisory_mode
repadmin /removelingeringobjects "NameOfKnownGoodDC" bdfb4d56-23ae-4d7a-bd7b-77f80b472d32 "DC=DomainDnsZones,DC=edtechjeff,DC=local" /advisory_mode
repadmin /removelingeringobjects "NameOfKnownGoodDC" bdfb4d56-23ae-4d7a-bd7b-77f80b472d32 "DC=ForestDnsZones,DC=edtechjeff,DC=local" /advisory_mode


## Full Sync Command
```powershell
repadmin /syncall "NameOfKnownGoodDC" /e /a /P /d
```
