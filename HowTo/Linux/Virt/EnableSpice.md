# How to Enable Spice

## Shutdown VM
```
virsh shutdown NAMEOFVM
```

## Edit the VM
```
virsh edit NAMEOFVM
```

1. Look for this section
```
<graphics type='vnc' port='-1' autoport='yes' listen='127.0.0.1'/>
```
2. Replace with this
```
<graphics type='spice' port='5900' autoport='no' listen='0.0.0.0'>
  <listen type='address' address='0.0.0.0'/>
</graphics>
```
3. Add these additional devices
```
<video>
  <model type='qxl' ram='65536' vram='65536' heads='1'/>
</video>

<sound model='ich9'/>
<channel type='spicevmc'>
  <target type='virtio' name='com.redhat.spice.0'/>
</channel>
```
## Start VM
```
virsh start NAMEOFVM
```


## Open up with VirtView on Windows
```
remote-viewer spice://<host-ip>:5900
```
