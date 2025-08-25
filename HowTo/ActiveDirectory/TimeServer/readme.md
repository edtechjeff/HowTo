# Active Directory Time Server

## Set the time servers on the PDC emulator server
```
w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync
```

## Checks the status of NTP servers configured
```
w32tm /query /status
```

## Force Sync
```
w32tm /resync /rediscover
```

## Command to run on all other DC's
```
w32tm /config /syncfromflags:domhier /update
net stop w32time && net start w32time
w32tm /resync /rediscover
```

## Command to show configuration
```
w32tm /query /configuration
```

## Command to show source of NTP server
```
w32tm /query /source
```

# Entra Joined or server not joined to domain at all

## Start and Stop Time Services
```
net stop w32time
net start w32time
```

## Set time to external Time Servers
```
w32tm /config /manualpeerlist:"0.pool.ntp.org,0x9 1.pool.ntp.org,0x9" /syncfromflags:manual /reliable:yes /update
```

## Force Sync
```
w32tm /resync
```

## Verify Configuration
```
w32tm /query /source
```

## Check detail configuration
```
w32tm /query /configuration
```

## Check Sync Status
```
w32tm /query /status
```

## check Source
```
w32tm /query /source
```

## List Peers
```
w32tm /query /peers
```

## Check the time on the NTP server
```
w32tm /stripchart /computer:0.pool.ntp.org /dataonly /samples:5
```

## Fource rediscovery and resync
```
w32tm /config /update
w32tm /resync /rediscover
```

## Force an immmediate hard resync
```
w32tm /resync /force
```

## Reset Config
```
net stop w32time
w32tm /unregister
w32tm /register
net start w32time
```
