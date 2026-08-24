## List Storage Pools
```bash
virsh pool-list --all
```

## Inspect It
```bash
virsh pool-info default
```

## Check the file system
```bash
df -h /var/lib/libvirt/images
```

## See whats in the folder
```bash
du -sh /var/lib/libvirt/images
```

## check all volumes in the storage pool
```bash
virsh vol-list default
```
***Note*** the storage pool name will be different, depending on config

## View Size
```bash
virsh vol-info host2.qcow2 --pool default
```
***Note*** the storage pool name will be different, depending on config

## View Information
```bash
virsh pool-info default
```

```bash
df -h /var/lib/libvirt/images
```

```bash
ls -lh /var/lib/libvirt/images
```

## Check what is consuming space
```bash
du -sh /var/lib/libvirt/images/*
```

## Show Information
```bash
lsblk
sudo vgs
sudo lvs
```

## Expand Space
```bash
sudo lvextend -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv
```

## Verify
```bash
df -h /
```
