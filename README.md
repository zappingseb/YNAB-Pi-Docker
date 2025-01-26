# YNAB-Pi-Docker
A docker compose to serve my YNAB connectors

# Setup

## Download Raspberrian OS

## Install Docker

```bash
# Update system
sudo apt update
sudo apt upgrade

# Install dependencies
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group (optional)
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

## Create SMB Share

```bash
#!/bin/bash

# Install Samba
sudo apt update
sudo apt install -y samba samba-common-bin

# Create share directory
mkdir -p /home/pi/share
chmod 750 /home/pi/share

# Backup original config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Create new config
sudo tee /etc/samba/smb.conf > /dev/null << EOL
[global]
workgroup = WORKGROUP
server string = Raspberry Pi
security = user
encrypt passwords = yes
map to guest = never

[PiShare]
path = /home/pi/share
writeable = yes
guest ok = no
create mask = 0660
directory mask = 0750
public = no
valid users = pi
EOL

# Set Samba password for pi user
sudo smbpasswd -a pi

# Restart Samba
sudo systemctl restart smbd
sudo systemctl restart nmbd
```
