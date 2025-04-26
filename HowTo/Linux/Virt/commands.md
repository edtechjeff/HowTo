# Commands

## Shutdown VM
```
virsh shutdown NAMEOFVM
```

## Dump config of VM
```
virsh dumpxml NAMEOFVM >  NAMEOFVM.xml
```

## Takes an XML configuration file (your VM definition) and registers it with libvirt. It creates the VM's configuration in /etc/libvirt/qemu/ but doesn't boot it.
```
virsh define win11.xml
```

##  That does the same as define, but also starts the VM immediately.
```
virsh create win11.xml
```

## Start up VM
```
virsh start NAMEOFVM
```

## Edit Live Machine
```
virsh edit NAMEOFVM
```
## Set VM to AutoStart
```
virsh autostart NAMEOFVM.xml
```


## Change VM from NAT to Bridge

### Original Settings using default NAT
```
<interface type='network'>
      <mac address='52:54:00:1e:a9:91'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
```
### Settings using the bridge 
```
<interface type='bridge'>
      <mac address='52:54:00:1e:a9:91'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
```



