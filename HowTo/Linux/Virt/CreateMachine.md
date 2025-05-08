# Commands to create a Windows 11 Virtual Machine Using NAT

```
virt-install \
  --name win11 \
  --ram 8192 \
  --vcpus 4 \
  --cpu host-passthrough \
  --os-variant win11 \
  --machine q35 \
  --boot uefi \
  --hvm \
  --cdrom /iso/windows11.iso \
  --disk path=/var/lib/libvirt/images/win11.qcow2,size=60,bus=virtio \
  --disk path=/iso/virt.iso,device=cdrom \
  --network network=default,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --video qxl
  ```


  # Commands to create a Windows 11 Virtual Machine Using br0 (Bridge)
 ```
 virt-install \
  --name win11 \
  --ram 8192 \
  --vcpus 4 \
  --cpu host-passthrough \
  --os-variant win11 \
  --machine q35 \
  --boot uefi \
  --hvm \
  --cdrom /iso/windows11.iso \
  --disk path=/var/lib/libvirt/images/win11.qcow2,size=60,bus=virtio \
  --disk path=/iso/virt.iso,device=cdrom \
  --network bridge=br0,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --video qxl
```
# Create a VM with PXE as boot source
```
virt-install \
  --name win11-1 \
  --ram 8192 \
  --vcpus 4 \
  --cpu host-passthrough \
  --os-variant win11 \
  --machine q35 \
  --boot uefi,network \
  --hvm \
  --pxe \
  --disk path=/var/lib/libvirt/images/win11-1.qcow2,size=60,bus=virtio \
  --network bridge=br0,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --video qxl
```

# Note about PXE Config
- once the VM is deployed, shut down the VM and edit the VM
```
sudo virsh edit NAMEOFVM
```
- Remove or change the following section

```
<boot dev='network'/>
```

to

```
<boot dev='hd'/>
```
