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
# Create a VM with PXE as boot source Method 1
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
# Create a VM with PXE as boot source Method 2
```
virt-install \
  --name win11-1 \
  --ram 8192 \
  --vcpus 4 \
  --cpu host-passthrough \
  --os-variant win11 \
  --machine q35 \
  --boot loader=/usr/share/OVMF/OVMF_CODE_4M.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS_4M.fd,bootmenu.enable=yes \
  --disk path=/var/lib/libvirt/images/win11-1.qcow2,size=60,bus=virtio,boot.order=1 \
  --network bridge=br0,model=virtio,boot.order=2 \
  --graphics vnc,listen=0.0.0.0 \
  --video qxl \
  --pxe

```

# Note about PXE Config
## Boot to HD after imaging
## Method 1

1. once the VM is deployed, shut down the VM and edit the VM
```
sudo virsh edit NAMEOFVM
```
2. Remove or change the following section
```
<boot dev='network'/>
```
to
```
<boot dev='hd'/>
```

## Method 2
## Use the UEFI Variables
1. Install additional packages
```
sudo apt update
sudo apt install ovmf
```
2. Verifiy that files are installed
```
find /usr/share -name 'OVMF*.fd'
```
3. Use the above creation script to use this method