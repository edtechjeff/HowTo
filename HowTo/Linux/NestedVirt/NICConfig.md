

## Netplan
```bash
network:
  version: 2
  renderer: networkd

  ethernets:
    eno1:
      dhcp4: false
      addresses:
        - 192.168.0.9/24
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses: [192.168.0.1, 8.8.8.8]

    eno2:
      dhcp4: false
      optional: true

  bridges:
    br0:
      interfaces:
        - eno2
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0

    br-iscsi:
      interfaces: []
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0

    br-cluster:
      interfaces: []
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```

## Apply Netplan
```bash
sudo netplan apply
```

## List Machines
```bash
virsh list --all
```

## Commands to add to existing machines

### Add iSCSI NIC
```bash
virsh attach-interface \
  --domain HyperV01 \
  --type bridge \
  --source br-iscsi \
  --model virtio \
  --config
```

### Add Cluster NIC
```bash
virsh attach-interface \
  --domain HyperV01 \
  --type bridge \
  --source br-cluster \
  --model virtio \
  --config
```

### Add iSCSI NIC if Live and Running
```bash
virsh attach-interface \
  --domain HyperV01 \
  --type bridge \
  --source br-iscsi \
  --model virtio \
  --live \
  --config
```
### Add Cluster NIC if Live and Running
```bash
virsh attach-interface \
  --domain HyperV01 \
  --type bridge \
  --source br-cluster \
  --model virtio \
  --live \
  --config
```

# Note
***--live = now***
***--config = survive reboot***

## After Adding verify
```bash
ip link show br-iscsi
ip link show br-cluster
```

## Check VM if NIC is Attached
```bash
virsh domiflist HyperV01
```

