# KVM VM Performance Troubleshooting – CPU Governor

This guide documents troubleshooting sluggish Windows Server virtual machines running on an Ubuntu KVM/libvirt host.

The environment included several Windows Server VMs, including nested Hyper-V servers. Although the VMs had plenty of CPU, memory, disk, and network resources, Windows felt noticeably sluggish during normal use over RDP.

The root cause was ultimately traced to **CPU frequency scaling on the KVM host**.

---

## Environment

### KVM Host

- Ubuntu Linux
- KVM / QEMU / libvirt
- Intel Xeon Silver 4114 @ 2.20 GHz
- 1 CPU socket
- 10 physical cores
- 20 logical CPUs
- Hyper-Threading enabled
- Maximum CPU frequency: approximately 3.0 GHz

Check the host CPU:

```bash
lscpu
```

Example:

```text
CPU(s):                 20
Thread(s) per core:      2
Core(s) per socket:     10
Socket(s):               1
CPU max MHz:          3000
CPU min MHz:           800
```

### Running Virtual Machines

The host was running:

| VM | vCPUs |
|---|---:|
| Control | 4 |
| DC01 | 4 |
| DC02 | 4 |
| HV01 | 8 |
| HV02 | 8 |
| **Total** | **28** |

The physical host has 20 logical CPUs, so the environment is CPU-overcommitted.

CPU overcommit is not necessarily a problem. Virtualization hosts commonly have more assigned vCPUs than physical CPU threads as long as all VMs are not heavily utilizing their CPUs simultaneously.

---

# 1. Initial Problem

HV02 felt sluggish during normal Windows use.

Examples included:

- Opening applications
- Clicking through Server Manager
- Opening File Explorer
- Using PowerShell
- General Windows desktop responsiveness
- RDP session responsiveness

Because HV02 is a nested Hyper-V server, several possible bottlenecks were investigated.

---

# 2. Verify Guest CPU Configuration

Inside HV02, check the processor configuration:

```powershell
Get-CimInstance Win32_Processor |
    Format-Table Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed
```

Example:

```text
Name                                       NumberOfCores NumberOfLogicalProcessors MaxClockSpeed
----                                       ------------- ------------------------- -------------
Intel(R) Xeon(R) Silver 4114 CPU @ 2.20GHz             8                         8          2195
```

HV02 was correctly seeing:

```text
8 cores
8 logical processors
```

---

# 3. Check Windows Resource Usage

The next step was determining whether Windows itself was resource constrained.

Run:

```powershell
Get-Counter '\Processor(_Total)\% Processor Time',
            '\PhysicalDisk(_Total)\Avg. Disk sec/Transfer',
            '\Memory\Available MBytes' `
            -SampleInterval 1 -MaxSamples 10
```

The results showed approximately:

```text
CPU utilization:     11–22%
Disk latency:        ~0.0008 seconds
Available memory:    ~88 GB
```

## Disk Latency

The disk latency was approximately:

```text
0.0008 seconds
```

Convert seconds to milliseconds:

```text
0.0008 × 1000 = 0.8 ms
```

Approximately **0.8 ms disk latency is excellent**.

General reference:

| Disk Latency | Interpretation |
|---|---|
| < 10 ms | Excellent |
| 10–20 ms | Good |
| 20–50 ms | Noticeable |
| > 50 ms | Potential problem |

Storage was therefore ruled out as the cause.

---

# 4. Check Memory

HV02 had approximately:

```text
88 GB available memory
```

The KVM host showed HV02 configured with:

```text
Max memory:  100663296 KiB
Used memory: 100663296 KiB
```

This equals approximately:

```text
96 GB RAM
```

Memory pressure was therefore ruled out.

---

# 5. Verify Network Performance

Because some Internet downloads initially appeared slow, network performance was also investigated.

Testing with `iperf3` between HV02 and the KVM host showed approximately:

```text
933–948 Mbps
```

on the 1-Gbps network.

This demonstrated that:

- VirtIO networking was working correctly
- Linux bridges were working correctly
- The physical NIC was working correctly
- The physical switch/network path was working correctly
- HV02 was capable of nearly full gigabit throughput

Network performance was therefore ruled out as the cause of the sluggish Windows interface.

---

# 6. Verify the Problem Exists Over RDP

The KVM console itself can sometimes feel sluggish because of VNC/QXL graphics.

To eliminate the console as the cause, connect directly to the Windows server using RDP.

For example:

```text
mstsc
```

Connect to:

```text
192.168.0.32
```

HV02 still felt sluggish over RDP.

This ruled out the KVM VNC console as the primary cause.

---

# 7. Check KVM vCPU Scheduling

On the KVM host, check the VM's vCPUs:

```bash
sudo virsh vcpuinfo HV02
```

Example:

```text
VCPU:           0
CPU:            6
State:          running
CPU Affinity:   yyyyyyyyyyyyyyyyyyyy
```

The affinity line:

```text
yyyyyyyyyyyyyyyyyyyy
```

means that the vCPU is allowed to execute on any of the host's logical CPUs.

Running the command multiple times showed the HV02 vCPUs moving between physical host CPU threads.

This is normal KVM scheduling behavior.

---

# 8. Verify Nested Virtualization CPU Configuration

Because HV02 is being used as a nested Hyper-V server, the VM CPU configuration was checked.

Run:

```bash
sudo virsh dumpxml HV02 | grep -A15 "<cpu"
```

The VM was configured as:

```xml
<cpu mode='host-passthrough' check='none' migratable='on'>
  <topology sockets='1' dies='1' clusters='1' cores='8' threads='1'/>
</cpu>
```

This was a good configuration for the nested virtualization environment.

In particular:

```text
mode='host-passthrough'
```

allows the guest to receive CPU capabilities closely matching the physical host.

The topology presented HV02 with:

```text
1 socket
8 cores
1 thread per core
```

No CPU topology change was required.

---

# 9. Check Physical KVM Host CPU Utilization

Because several VMs were running simultaneously, CPU contention was investigated.

Install `sysstat` if necessary:

```bash
sudo apt install sysstat -y
```

Monitor all logical CPUs:

```bash
mpstat -P ALL 1 10
```

The host averaged approximately:

```text
%sys:     7%
%guest:   7%
%idle:   85%
%iowait:  0%
```

The important result was:

```text
~85% CPU idle
```

Therefore, despite having 28 assigned vCPUs across 20 host logical CPUs, the physical server was **not CPU saturated**.

CPU overcommit itself was not causing the problem.

---

# 10. Check the CPU Frequency Governor

The CPU frequency governor was checked next.

Run:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

The KVM host returned:

```text
schedutil
```

`schedutil` dynamically adjusts CPU frequency based on workload.

---

# 11. Check Actual CPU Frequencies

Check the current frequency of every logical CPU:

```bash
grep "cpu MHz" /proc/cpuinfo
```

The results showed many CPUs running at approximately:

```text
800 MHz
```

Example:

```text
cpu MHz : 1899.983
cpu MHz : 1901.453
cpu MHz : 800.006
cpu MHz : 799.898
cpu MHz : 800.000
cpu MHz : 2300.000
cpu MHz : 800.000
cpu MHz : 800.001
```

The Xeon Silver 4114 supports approximately:

```text
Minimum: 800 MHz
Base:    2.20 GHz
Maximum: 3.00 GHz
```

Many logical CPUs were therefore sitting near their **minimum frequency**.

This became the primary suspect for the poor interactive VM responsiveness.

---

# 12. Check Available CPU Governors

Run:

```bash
cpupower frequency-info
```

Available governors included:

```text
conservative
ondemand
userspace
powersave
performance
schedutil
```

The important option for this KVM host was:

```text
performance
```

---

# 13. Temporarily Enable Performance Mode

Switch the CPU governor:

```bash
sudo cpupower frequency-set -g performance
```

Verify:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

Expected:

```text
performance
```

---

# 14. Check CPU Frequencies Again

Run:

```bash
grep "cpu MHz" /proc/cpuinfo
```

After switching to the performance governor, frequencies increased dramatically.

Example:

```text
cpu MHz : 2499.919
cpu MHz : 2500.006
cpu MHz : 2500.022
cpu MHz : 2499.981
cpu MHz : 2499.983
cpu MHz : 3000.000
cpu MHz : 3000.000
```

Instead of frequently sitting around:

```text
800 MHz
```

the CPUs were now generally operating around:

```text
2.5 GHz
```

with some reaching:

```text
3.0 GHz
```

---

# 15. Test VM Performance

After switching to:

```text
performance
```

HV02 was tested again using RDP.

The difference was immediately noticeable.

Windows became substantially more responsive when:

- Opening applications
- Navigating Server Manager
- Opening File Explorer
- Using PowerShell
- Moving between windows
- Performing normal administrative tasks

This confirmed that **CPU frequency scaling on the KVM host was responsible for the sluggish interactive performance**.

---

# 16. Important: The Change Does Not Survive Reboot

After rebooting the KVM server, check:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

The system returned to:

```text
schedutil
```

The `cpupower frequency-set` command therefore changed the governor only for the current boot.

A persistent configuration was required.

---

# 17. Create a Persistent systemd Service

Create a new service:

```bash
sudo nano /etc/systemd/system/cpu-performance.service
```

Add:

```ini
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Save the file:

```text
Ctrl+O
Enter
Ctrl+X
```

---

# 18. Enable the CPU Performance Service

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable and immediately start the service:

```bash
sudo systemctl enable --now cpu-performance.service
```

Check the service:

```bash
systemctl status cpu-performance.service
```

---

# 19. Verify Performance Mode

Check CPU0:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

Expected:

```text
performance
```

Check every logical CPU:

```bash
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

Every CPU should report:

```text
performance
```

---

# 20. Verify After Reboot

Reboot the KVM host:

```bash
sudo reboot
```

After the host returns, check again:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

Expected:

```text
performance
```

In this environment, the system successfully returned with:

```text
performance
```

after reboot.

The configuration was therefore persistent.

---

# 21. Useful Verification Commands

## CPU Model and Topology

```bash
lscpu
```

## Current Governor

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

## All CPU Governors

```bash
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Current CPU Frequencies

```bash
grep "cpu MHz" /proc/cpuinfo
```

## Sort CPU Frequencies

```bash
grep "cpu MHz" /proc/cpuinfo | sort -n -k4
```

## CPU Utilization

```bash
mpstat -P ALL 1 10
```

## VM CPU Information

```bash
sudo virsh vcpuinfo HV02
```

## VM CPU Configuration

```bash
sudo virsh dumpxml HV02 | grep -A15 "<cpu"
```

## VM Resource Information

```bash
sudo virsh dominfo HV02
```

---

# 22. Check Resources for All Running VMs

The following command provides a quick overview of CPU and memory assigned to every running VM:

```bash
for vm in $(sudo virsh list --name); do
    echo "===== $vm ====="
    sudo virsh dominfo "$vm" |
        grep -E "Name:|CPU\(s\):|Max memory:|Used memory:"
done
```

Example:

```text
===== Control =====
CPU(s):         4

===== DC01 =====
CPU(s):         4

===== DC02 =====
CPU(s):         4

===== HV02 =====
CPU(s):         8

===== HV01 =====
CPU(s):         8
```

This is useful when troubleshooting CPU overcommit.

---

# 23. Revert to schedutil

To temporarily switch back:

```bash
sudo cpupower frequency-set -g schedutil
```

To remove the persistent performance configuration:

```bash
sudo systemctl disable --now cpu-performance.service
```

Delete the service:

```bash
sudo rm /etc/systemd/system/cpu-performance.service
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Then reboot:

```bash
sudo reboot
```

Verify:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

---

# Troubleshooting Summary

The troubleshooting process eliminated several possible causes.

| Component | Result |
|---|---|
| Guest CPU utilization | Normal |
| Guest memory | Plenty available |
| Disk latency | Excellent (~0.8 ms) |
| Network throughput | Excellent (~935+ Mbps) |
| VNC console | Ruled out by testing RDP |
| KVM CPU topology | Correct |
| `host-passthrough` | Correct |
| Host CPU utilization | ~85% idle |
| CPU overcommit | Not causing saturation |
| CPU governor | `schedutil` |
| CPU frequency | Many CPUs around 800 MHz |
| Performance governor | ~2.5–3.0 GHz |
| VM responsiveness after change | Significantly improved |

---

# Final Configuration

The KVM host now uses:

```text
CPU Governor: performance
```

with a systemd service to reapply the configuration automatically during startup.

For this virtualization environment, particularly with nested Hyper-V workloads, changing the KVM host from `schedutil` to `performance` provided a substantial improvement in interactive VM responsiveness.

> **Note:** The `performance` governor can increase power consumption and heat because the processor operates at higher frequencies more aggressively. Monitor system temperature and cooling when using this configuration continuously.