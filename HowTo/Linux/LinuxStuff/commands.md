# Shows the number of available CPU processing units (cores/threads).
```bash
nproc
```

# More detailso on PROC
```bash
lscpu
```

# Quick Summary
```bash
grep -E 'processor|core id|physical id' /proc/cpuinfo
```

# See CPU Model
```bash
lscpu | grep "Model name"
```

# Memory 
```bash
free -h
```

# Installed Memory
```bash
grep MemTotal /proc/meminfo
```

# Detailed Memory
```bash
sudo dmidecode -t memory
```

## Check Memory on VM
```bash
virsh dumpxml VMNAME | grep -i memory
virsh dominfo VMNAME | grep -i memory
```

## Set Memory on Machine
```bash
sudo virsh setmaxmem VMNAME 16G --config
sudo virsh setmem VMNAME 16G --config
```



