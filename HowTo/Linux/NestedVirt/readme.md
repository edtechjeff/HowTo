# Nested Virtual Setup
***Under Construction***

## Folder Setup

/var/lib/libvirt/
└── images/
    ├── disks/
    └── iso/

## Create Directories

```bash
sudo mkdir -p /var/lib/libvirt/images/disk
sudo mkdir -p /var/lib/libvirt/images/iso
```

## Verify


```bash
ls -ld /var/lib/libvirt/images
ls -ld /var/lib/libvirt/images/disks
ls -ld /var/lib/libvirt/images/iso
```

## Add current user to correct groups

```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

## Add perms to the directories

```bash
sudo chown -R root:libvirt /var/lib/libvirt/images
sudo chmod -R 2775 /var/lib/libvirt/images
```
***Note:***The 2 in 2775 is useful here. It sets the setgid bit on directories, which means new files/directories inherit the libvirt group.

### Result
```text
drwxrwsr-x root libvirt /var/lib/libvirt/images
```


