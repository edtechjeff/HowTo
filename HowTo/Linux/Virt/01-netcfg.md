# Create config file
```
  sudo nano /etc/netplan/01-netcfg.yaml
```

# Used if you have 1 adapter
# 1. Wired (enp1s0)
# 2. Bridge (br0) on (enp1s0)

```
network:
  version: 2
  renderer: networkd

  ethernets:
    enp1s0:
      dhcp4: false
      optional: true

  bridges:
    br0:
      interfaces: [enp1s0]
      dhcp4: false
      addresses:
        - 192.168.1.230/24
      routes:
        - to: 0.0.0.0/0
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

# Apply Plan
  ```
  sudo netplan apply
  ```