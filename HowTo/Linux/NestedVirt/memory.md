# view current memory
```bash
virsh dominfo <vm-name>
```

# Memory is specified in KiB
```bash
16 GB = 16 × 1024 × 1024 = 16777216 KiB
```

# Shutdown VM
```bash
virsh shutdown NAMEOFSERVER
```

# Set Maximum Memory
```bash
virsh setmaxmem server2025 16777216 --config
```

# Set Current Memory
```bash
virsh setmem server2025 16777216 --config
```

# Start the VM
```bash
virsh start NAMEOFVM
```

# Verify Memory
```bash
virsh dominfo server2025
```