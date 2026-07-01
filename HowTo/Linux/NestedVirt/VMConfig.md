

## Host1
```bash
virt-install \
 --name Host1 \
 --ram 16384 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025.iso \
 --disk path=/var/lib/libvirt/images/disk/host1.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --network bridge=br-iscsi,model=virtio \
 --network bridge=br-cluster,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl
```

## Host 2
```bash
virt-install \
 --name Host2 \
 --ram 32768 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025.iso \
 --disk path=/var/lib/libvirt/images/disk/host2.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --network bridge=br-iscsi,model=virtio \
 --network bridge=br-cluster,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl
 ```

 ## Shared Storage
```bash
virt-install \
 --name storage \
 --ram 16384 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025.iso \
 --disk path=/var/lib/libvirt/images/storage.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --network bridge=br-iscsi,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl
```

## Windows11

```bash
virt-install \
 --name Control \
 --ram 16384 \
 --vcpus 8 \
 --cpu host-passthrough \
 --os-variant win11 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Win11.iso \
 --disk path=/var/lib/libvirt/images/win11.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio-win.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl \
 --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb
 ```


 virt-install \
 --name test \
 --ram 16384 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025-Teaching.iso \
 --disk path=/var/lib/libvirt/images/test.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl \
 --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb


## VM with SATA Drive

```bash
virt-install \
 --name test \
 --ram 16384 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025-Teaching.iso \
 --disk path=/var/lib/libvirt/images/test.qcow2,size=60,bus=sata \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl \
 --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb
```