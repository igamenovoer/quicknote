# NVIDIA Orin Complete Installation Guide

## Overview

This guide provides step-by-step instructions to configure a fresh NVIDIA Orin device with essential services and optimizations. The setup includes SSH key authentication, storage configuration, VNC remote access, hostname discovery, and Docker with GPU support.

## Configuration Placeholders

Before using this guide, replace the following placeholders with your actual values:

- `<ORIN_IP_ADDRESS>` - The IP address of your Orin device (e.g., 192.168.1.9)
- `<ORIN_USERNAME>` - The username on your Orin device (default: your actual username)
- `<ORIN_PASSWORD>` - The password for your Orin user (default: your actual password)
- `<ORIN_HOSTNAME>` - The hostname for your Orin device (e.g., yourname-orin)
- `<VNC_PASSWORD>` - The password for VNC access (can be same as <ORIN_PASSWORD>)
- `<YOUR_SSH_PUBLIC_KEY>` - Your SSH public key for password-less authentication
- `<NVME_UUID>` - The UUID of your NVMe SSD (obtained from `blkid` command)

## Prerequisites

- **Target Device**: NVIDIA Orin with Ubuntu 22.04.5 LTS (jammy)
- **Network**: Device connected to local network with DHCP
- **Default Credentials**: Username `<ORIN_USERNAME>`, Password `<ORIN_PASSWORD>`
- **Host Machine**: Linux/macOS with SSH tools installed

## Quick Setup Summary

1. **SSH Key Authentication** - Password-less SSH access
2. **Storage Configuration** - NVMe SSD auto-mounting (500GB)
3. **VNC Remote Desktop** - x11vnc server with auto-start
4. **Hostname Discovery** - Avahi mDNS for `<ORIN_HOSTNAME>.local`
5. **Docker Installation** - Docker Engine with NVIDIA GPU support + SSD storage

---

## Step 1: SSH Key Authentication

**Purpose**: This step sets up password-less SSH access to your Orin device using cryptographic keys instead of passwords. This provides better security and convenience - you won't need to type passwords every time you connect, and it's much more secure than password authentication. SSH keys use public-key cryptography where you keep a private key on your computer and place a public key on the Orin device.

**What this accomplishes**: After completing this step, you'll be able to SSH into your Orin device without entering a password, making remote access both more secure and more convenient for development work.

### 1.1 Add SSH Public Key

```bash
# Copy your public key to Orin device
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS> "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

# Add your public key (replace with your actual key)
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS> "echo '<YOUR_SSH_PUBLIC_KEY>' >> ~/.ssh/authorized_keys"

# Set proper permissions
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS> "chmod 600 ~/.ssh/authorized_keys"
```

**Important**: Always use `-o PreferredAuthentications=password -o PubkeyAuthentication=no` with sshpass to avoid passphrase conflicts.

---

## Step 2: Storage Configuration

**Purpose**: This step configures the high-speed NVMe SSD storage in your Orin device for optimal performance and data organization. The Orin typically comes with limited eMMC storage for the operating system, but includes a much larger and faster NVMe SSD that needs to be properly formatted and mounted to be usable.

**What this accomplishes**: After completing this step, you'll have a large, fast storage drive (typically 500GB) automatically mounted and accessible for storing your projects, Docker containers, and other data. The SSD will be formatted with a modern filesystem (ext4), automatically mount on boot, and have proper permissions for all users to access it. This separation keeps your system storage clean while providing ample space for development work.

**Important**: This process will completely erase any existing data on the NVMe SSD, so make sure to back up any important files first.

### 2.1 Format and Mount NVMe SSD

```bash
# Connect to Orin
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS>

# Check current storage
lsblk -f

# Backup fstab
sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

# Unmount if currently mounted
sudo umount /mnt/nvme0n1

# Format NVMe SSD (⚠️ THIS WILL ERASE ALL DATA)
sudo mkfs.ext4 -F /dev/nvme0n1

# Get new UUID
sudo blkid /dev/nvme0n1

# Create mount point
sudo mkdir -p /mnt/nvme0n1

# Add to fstab (replace UUID with actual UUID from blkid)
echo 'UUID=<NVME_UUID> /mnt/nvme0n1 ext4 defaults,nofail,user,errors=remount-ro 0 2' | sudo tee -a /etc/fstab

# Mount and set permissions
sudo mount -a
sudo chmod 777 /mnt/nvme0n1
```

### 2.2 Verify Storage Configuration

**Purpose of this subsection**: These commands verify that the storage configuration completed successfully and that the SSD is properly mounted and accessible for regular use.

```bash
# Check mount status
df -h | grep nvme0n1

# Test write access
touch /mnt/nvme0n1/test-file && rm /mnt/nvme0n1/test-file && echo "Write access OK"
```

---

## Step 3: VNC Remote Desktop

**Purpose**: This step sets up remote desktop access to your Orin device, allowing you to see and control the graphical desktop environment from any computer on your network. VNC (Virtual Network Computing) creates a graphical connection so you can run desktop applications, configure system settings, and work with GUI tools remotely.

**What this accomplishes**: After completing this step, you'll be able to connect to your Orin's desktop environment from any VNC client (available on Windows, macOS, Linux, and mobile devices). The VNC server will automatically start when the system boots, providing persistent remote access. This is especially useful for headless setups where you don't have a monitor directly connected to the Orin, or when you want to access the device from another room or location.

**Benefits**: Remote desktop access eliminates the need for a dedicated monitor, keyboard, and mouse for the Orin device, while still providing full graphical access when needed for configuration or running desktop applications.

### 3.1 Install x11vnc

```bash
# Install VNC server
echo '<ORIN_PASSWORD>' | sudo -S apt update
echo '<ORIN_PASSWORD>' | sudo -S apt install -y x11vnc

# Create VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd <VNC_PASSWORD> ~/.vnc/passwd
```

### 3.2 Create systemd Service

**Purpose of this subsection**: This creates a system service that automatically starts the VNC server when your Orin boots up. Without this service, you would need to manually start VNC every time you restart the device. The systemd service ensures VNC is always available for remote connections.

```bash
# Create service file
echo '<ORIN_PASSWORD>' | sudo -S tee /etc/systemd/system/x11vnc.service > /dev/null << 'EOF'
[Unit]
Description=Start x11vnc at startup
After=graphical-session.target

[Service]
Type=simple
User=<ORIN_USERNAME>
Environment=DISPLAY=:0
ExecStart=/usr/bin/x11vnc -display :0 -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/<ORIN_USERNAME>/.vnc/passwd -rfbport 5900 -shared
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service

# Verify service
sudo systemctl status x11vnc.service
```

### 3.3 VNC Connection Details

**How to connect**: Use any VNC client software (such as RealVNC Viewer, TightVNC, or built-in VNC clients) with these connection parameters. Most VNC clients will prompt for the password when you connect.

- **Host**: <ORIN_IP_ADDRESS> (or <ORIN_HOSTNAME>.local after Step 4)
- **Port**: 5900
- **Password**: <VNC_PASSWORD>

---

## Step 4: Hostname Discovery (Avahi)

**Purpose**: This step configures your Orin device to be discoverable on the local network using a human-readable hostname instead of just an IP address. Avahi implements mDNS (multicast DNS), which allows devices to broadcast their presence and services on the local network without requiring a centralized DNS server.

**What this accomplishes**: After completing this step, you'll be able to access your Orin device using a consistent hostname like `<ORIN_HOSTNAME>.local` instead of remembering or looking up its IP address. This is especially valuable because DHCP can assign different IP addresses to your device over time, but the hostname remains constant.

**Benefits**: This makes connecting to your Orin much more convenient and reliable. Instead of running `ssh <ORIN_USERNAME>@192.168.1.9`, you can simply use `ssh <ORIN_USERNAME>@<ORIN_HOSTNAME>.local`. The same applies to VNC connections and any other network services. It's particularly useful in environments where multiple Orin devices are present, as each can have its own memorable hostname.

### 4.1 Install and Configure Avahi

```bash
# Install Avahi (usually already installed)
echo '<ORIN_PASSWORD>' | sudo -S apt update
echo '<ORIN_PASSWORD>' | sudo -S apt install -y avahi-daemon

# Check service status
sudo systemctl status avahi-daemon

# Enable if not already enabled
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
```

### 4.2 Test Hostname Resolution

**Purpose of this subsection**: These commands verify that hostname discovery is working correctly. Run these from your host computer (not on the Orin itself) to confirm that other devices on the network can find your Orin using its hostname.

```bash
# Test hostname resolution (from host machine)
ping -c 3 <ORIN_HOSTNAME>.local

# Test SSH via hostname
ssh yourname@<ORIN_HOSTNAME>.local
```

---

## Step 5: Docker Installation

**Purpose**: This step installs and configures Docker Engine with NVIDIA GPU support on your Orin device. Docker is a containerization platform that allows you to run applications in isolated, portable environments. The NVIDIA Jetson requires special configuration to enable GPU access within containers, which is crucial for AI/ML workloads and CUDA applications.

**What this accomplishes**: After completing this step, you'll have a fully functional Docker installation that can:
- Run standard Linux containers for general applications
- Access the NVIDIA GPU from within containers for AI/ML workloads
- Store all Docker data (images, containers, volumes) on the fast NVMe SSD instead of the limited system storage
- Automatically manage GPU resources and CUDA runtime within containers

**Benefits**: Docker with GPU support enables you to run AI frameworks (TensorFlow, PyTorch, etc.), CUDA applications, and other GPU-accelerated software in isolated environments. Using the SSD for Docker storage prevents filling up the system storage and provides better performance for container operations.

**Special Notes**: The installation uses a community-maintained script that handles Jetson-specific configurations and automatically downgrades to Docker 27.5.1 for compatibility with the Jetson platform (newer versions have known issues).

### 5.1 Install Docker Engine

```bash
# Clone installation repository
git clone https://github.com/jetsonhacks/install-docker.git
cd install-docker

# Install NVIDIA Docker
echo '<ORIN_PASSWORD>' | sudo -S bash ./install_nvidia_docker.sh

# Configure NVIDIA runtime
echo '<ORIN_PASSWORD>' | sudo -S bash ./configure_nvidia_docker.sh

# Add user to docker group
echo '<ORIN_PASSWORD>' | sudo -S usermod -aG docker <ORIN_USERNAME>
```

### 5.2 Configure Docker to Use SSD

**Purpose of this subsection**: By default, Docker stores all its data (container images, running containers, volumes, etc.) in `/var/lib/docker` on the system storage. On a Jetson device with limited eMMC storage, this can quickly fill up the system drive. This configuration moves Docker's data directory to the larger, faster NVMe SSD.

**Technical details**: This involves updating Docker's daemon configuration to change the data root directory and ensuring the SSD directory has proper permissions for the Docker service to access it.

```bash
# Create Docker data directory on SSD
mkdir -p /mnt/nvme0n1/docker-data

# Update daemon configuration
cat > /tmp/daemon.json << 'EOF'
{
  "runtimes": {
    "nvidia": {
      "args": [],
      "path": "nvidia-container-runtime"
    }
  },
  "default-runtime": "nvidia",
  "data-root": "/mnt/nvme0n1/docker-data"
}
EOF

# Copy configuration
echo '<ORIN_PASSWORD>' | sudo -S cp /tmp/daemon.json /etc/docker/daemon.json

# Set proper permissions
echo '<ORIN_PASSWORD>' | sudo -S chown -R root:root /mnt/nvme0n1/docker-data
echo '<ORIN_PASSWORD>' | sudo -S chmod 701 /mnt/nvme0n1/docker-data
```

### 5.3 Reboot and Test

**Purpose of this subsection**: The reboot is necessary for the user group changes to take effect (adding your user to the Docker group). After reboot, we verify that Docker is working correctly and can access the GPU.

**What these tests accomplish**: The tests confirm that Docker can run containers normally and that GPU access is properly configured. The `hello-world` container verifies basic Docker functionality, while the `nvidia-smi` test confirms that containers can access and use the NVIDIA GPU.

```bash
# Reboot for group changes
sudo reboot

# After reboot, test Docker
docker --version
docker run hello-world

# Test GPU access
docker run --rm --gpus all ubuntu:22.04 nvidia-smi
```

---

## Final Configuration Summary

### Network Access
- **SSH**: `ssh <ORIN_USERNAME>@<ORIN_IP_ADDRESS>` or `ssh <ORIN_USERNAME>@<ORIN_HOSTNAME>.local`
- **VNC**: `<ORIN_IP_ADDRESS>:5900` or `<ORIN_HOSTNAME>.local:5900` (password: <VNC_PASSWORD>)

### Storage Layout
- **Root**: `/dev/mmcblk0p1` (57.8GB) - System files
- **NVMe SSD**: `/dev/nvme0n1` (500GB) - Auto-mounted at `/mnt/nvme0n1`
- **Docker Data**: `/mnt/nvme0n1/docker-data` - Docker images/containers

### Services Status
```bash
# Check all services
sudo systemctl status avahi-daemon
sudo systemctl status x11vnc.service
sudo systemctl status docker

# Storage check
df -h | grep nvme0n1
lsblk -f
```

### Docker Configuration
- **Version**: 27.5.1 (downgraded for Jetson compatibility)
- **Runtime**: NVIDIA (default)
- **Data Directory**: `/mnt/nvme0n1/docker-data`
- **GPU Access**: Enabled via `--gpus all`

---

## Troubleshooting

### SSH Issues
```bash
# Force password authentication
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS>
```

### Storage Issues
```bash
# Check fstab syntax
sudo mount -fav

# Remount storage
sudo umount /mnt/nvme0n1
sudo mount -a
```

### VNC Issues
```bash
# Check VNC service
sudo systemctl status x11vnc.service
journalctl -u x11vnc.service -f

# Restart VNC service
sudo systemctl restart x11vnc.service
```

### Docker Issues
```bash
# Check Docker service
sudo systemctl status docker
journalctl -u docker -f

# Verify GPU access
docker run --rm --gpus all ubuntu:22.04 nvidia-smi

# Check Docker info
docker info
```

### Hostname Discovery Issues
```bash
# Check Avahi service
sudo systemctl status avahi-daemon
journalctl -u avahi-daemon -f

# Test hostname resolution
avahi-resolve-host-name <ORIN_HOSTNAME>.local
```

---

## Command Reference

### Essential Commands
```bash
# SSH with password auth
sshpass -p '<ORIN_PASSWORD>' ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <ORIN_USERNAME>@<ORIN_IP_ADDRESS>

# Check storage
df -h
lsblk -f

# Service management
sudo systemctl status <service>
sudo systemctl restart <service>
journalctl -u <service> -f

# Docker commands
docker --version
docker run hello-world
docker run --rm --gpus all ubuntu:22.04 nvidia-smi
docker info
```

### File Locations
- **fstab**: `/etc/fstab`
- **fstab backup**: `/etc/fstab.backup.YYYYMMDD_HHMMSS`
- **VNC service**: `/etc/systemd/system/x11vnc.service`
- **VNC password**: `/home/<ORIN_USERNAME>/.vnc/passwd`
- **Docker daemon**: `/etc/docker/daemon.json`
- **Docker data**: `/mnt/nvme0n1/docker-data`
- **SSH keys**: `/home/<ORIN_USERNAME>/.ssh/authorized_keys`

---

## Notes

- **Docker Version**: Using 27.5.1 (held) due to Jetson compatibility issues with 28.x
- **Storage**: NVMe SSD formatted with ext4, all previous data erased
- **Permissions**: SSD mounted with 777 permissions for full user access
- **Boot Safety**: All mounts use `nofail` option to prevent boot hangs
- **GPU Access**: NVIDIA runtime configured as default for all containers

This guide provides a complete, reproducible setup for NVIDIA Orin devices with essential services and optimizations.
