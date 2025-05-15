# Edit QEMU Config
```
sudo nano /etc/libvirt/qemu.conf
```

# Find and Change
```
spice_tls = 1
```
# Generate Server Certificates
```
sudo mkdir -p /etc/pki/qemu
cd /etc/pki/qemu
sudo openssl req -new -x509 -days 365 -nodes \
  -out server-cert.pem -keyout server-key.pem \
  -subj "/CN=spice-server"
```
# Set Permissions
```
sudo chown libvirt-qemu:libvirt-qemu server-*.pem
sudo chmod 600 server-*.pem
```
# Provide the CA Certificate (for Full TLS)
```
cd /etc/pki/qemu

# Create the CA key and cert
sudo openssl req -new -x509 -days 365 -nodes \
  -out ca-cert.pem -keyout ca-key.pem \
  -subj "/CN=spice-CA"

# Set permissions
sudo chown libvirt-qemu:libvirt-qemu ca-*.pem
sudo chmod 600 ca-*.pem
```

# Restart libvirtd
```
sudo systemctl restart libvirtd
```

