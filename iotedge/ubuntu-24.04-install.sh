#!/bin/bash

set -e

echo "--------------------------------------------"
echo "Starting IoT Edge installation for Ubuntu 24.04 on WSL"
echo "--------------------------------------------"

# check for root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <iot-edge-device-connection-string>"
    exit 1
fi

# connection string is $1 in the format: HostName=iothubname.azure-devices.net;DeviceId=deviceid;SharedAccessKey=xxx
# extract DeviceId from connection string
DEVICE_ID=$(echo "$1" | sed -n 's/.*DeviceId=\([^;]*\).*/\1/p')
echo "*************** Device ID: $DEVICE_ID"

# Disable WSL auto generation of resolv.conf
if [ -f /etc/wsl.conf ]; then
    if grep -q "generateResolvConf" /etc/wsl.conf; then
        echo "/etc/wsl.conf already contains generateResolvConf setting"
    else
        echo "*************** Adding generateResolvConf setting to /etc/wsl.conf"
        cat << EOF >> /etc/wsl.conf
[network]
generateResolvConf=false
hostname=$DEVICE_ID
EOF
    fi
else
    touch /etc/wsl.conf
fi

if grep -q "nameserver 8.8.8.8" /etc/resolv.conf 2>/dev/null; then
    echo "*************** /etc/resolv.conf already configured"    
else
    echo "*************** Configuring /etc/resolv.conf"
    # Unmount if it's mounted (WSL auto-generation)
    if mountpoint -q /etc/resolv.conf 2>/dev/null; then
        umount /etc/resolv.conf || true
    fi
    # Remove existing resolv.conf as it may be a symlink
    rm -f /etc/resolv.conf
    # Create new resolv.conf with custom DNS
    cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    # Make it immutable to prevent WSL from overwriting it
    chattr +i /etc/resolv.conf 2>/dev/null || true
    
    # Reload networking to apply changes
    echo "*************** Reloading network configuration"
    systemctl restart systemd-resolved 2>/dev/null || true
    # Flush DNS cache
    resolvectl flush-caches 2>/dev/null || true
fi

wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update

# if docker is not installed install it
if ! command -v docker &> /dev/null; then
    echo "*************** Installing Docker"
    apt-get install moby-engine -y
fi

echo "*************** iptables version: $(iptables --version)"


# Configure Docker daemon.json
if grep -q "1.1.1.1" /etc/docker/daemon.json 2>/dev/null; then 
    echo "*************** Docker already configured to use custom DNS"
else
    echo "*************** /etc/docker/daemon.json not configured"
    # configure docker to use custom dns
    echo "*************** Configuring Docker to use custom DNS"
    echo '{ "log-driver": "local", "dns": ["1.1.1.1"] }' | tee /etc/docker/daemon.json
fi

# Ensure Docker is running (systemd or manual start)
if ! docker info &>/dev/null; then
    echo "*************** Docker is not running, attempting to start..."
    
    # Try systemctl first
    if systemctl is-system-running &>/dev/null && systemctl restart docker 2>/dev/null && systemctl restart containerd 2>/dev/null; then
        echo "*************** Docker service restarted via systemctl"
        sleep 2
    else
        echo "*************** Starting Docker manually (WSL environment)"
        
        # Kill any existing dockerd/containerd processes
        pkill -f dockerd || true
        pkill -f containerd || true
        sleep 2
        
        # Start containerd first
        echo "*************** Starting containerd..."
        nohup containerd > /var/log/containerd.log 2>&1 &
        sleep 3
        
        # Start dockerd
        echo "*************** Starting dockerd..."
        nohup dockerd > /var/log/dockerd.log 2>&1 &
        
        # Wait for Docker to be ready
        echo "*************** Waiting for Docker to be ready..."
        for i in {1..30}; do
            if docker info &>/dev/null; then
                echo "*************** Docker is ready!"
                break
            fi
            sleep 1
        done
        
        if ! docker info &>/dev/null; then
            echo "ERROR: Docker failed to start properly"
            echo "Check /var/log/dockerd.log and /var/log/containerd.log for details"
        fi
    fi
else
    echo "*************** Docker is already running"
fi

if ! command -v iotedge &> /dev/null; then
    echo "*************** Installing IoT Edge dependencies"
    apt-get install aziot-edge -y

    echo "*************** Configuring IoT Edge"
    iotedge config mp --connection-string "$1"
    iotedge config apply
else
    echo "*************** IoT Edge already installed"    
fi
echo "*************** Installing IoT Edge"

# create /home/edge/test folder
mkdir -p /home/edge/test
echo "<html><body><h1>IoT Edge is working!</h1>" > /home/edge/test/index.html
chown -R 101:101 /home/edge/test


# Check the installation
iotedge system status || true
iotedge check || true
iotedge list || true
# The following command will follow logs indefinitely.
# If you want to view live logs, uncomment the next line and interrupt with Ctrl+C when done.
# iotedge system logs -- -f
# Alternatively, to view recent logs without following, use:
# iotedge system logs || true

echo "--------------------------------------------"
echo "IoT Edge installation for Ubuntu 24.04 on WSL completed"
echo "You may need to restart WSL to apply some changes."
echo "--------------------------------------------"
echo "You can see the test web pages by navigating to http://localhost and http://localhost/hello in your web browser."
echo "To watch IoT Edge logs, use the command: sudo iotedge system logs -- -f"