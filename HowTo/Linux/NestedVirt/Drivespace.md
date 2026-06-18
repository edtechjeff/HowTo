## List Storage Pools
virsh pool-list --all

## Inspect It
virsh pool-info default

## Check the file system
df -h /var/lib/libvirt/images

## See whats in the folder
du -sh /var/lib/libvirt/images

## check all volumes in the storage pool
virsh vol-list default
***Note*** the storage pool name will be different, depending on config

## View Size
virsh vol-info host2.qcow2 --pool default
***Note*** the storage pool name will be different, depending on config

## View Information
virsh pool-info default

df -h /var/lib/libvirt/images

ls -lh /var/lib/libvirt/images

## Check what is consuming space
du -sh /var/lib/libvirt/images/*

## Show Information
lsblk
sudo vgs
sudo lvs

## Expand Space
sudo lvextend -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv

## Verify
df -h /

