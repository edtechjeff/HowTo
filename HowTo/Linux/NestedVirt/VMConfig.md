

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
 --disk path=/var/lib/libvirt/images/server2025.qcow2,size=60,bus=virtio \
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
 --ram 16384 \
 --vcpus 4 \
 --cpu host-passthrough \
 --os-variant win2k22 \
 --machine q35 \
 --boot uefi \
 --hvm \
 --cdrom /var/lib/libvirt/images/iso/Server2025.iso \
 --disk path=/var/lib/libvirt/images/host2.qcow2,size=60,bus=virtio \
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
 --disk path=/var/lib/libvirt/images/server2025.qcow2,size=60,bus=virtio \
 --disk path=/var/lib/libvirt/images/iso/virtio.iso,device=cdrom \
 --network bridge=br0,model=virtio \
 --network bridge=br-iscsi,model=virtio \
 --graphics vnc,listen=0.0.0.0 \
 --video qxl