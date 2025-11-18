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

# Fix Docker systemd service to include iptables in PATH
if [ ! -f /etc/systemd/system/docker.service.d/override.conf ]; then
    echo "*************** Configuring Docker systemd service PATH"
    mkdir -p /etc/systemd/system/docker.service.d
    cat > /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF
    systemctl daemon-reload
    sleep 1
    echo "*************** Systemd configuration reloaded"
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
        
        # Kill any existing dockerd/containerd processes and wait for them to fully stop
        pkill -9 dockerd || true
        pkill -9 containerd || true
        pkill -9 docker || true
        sleep 3
        
        # Ensure no stale sockets
        rm -f /var/run/docker.sock /run/containerd/containerd.sock || true
        
        # Start containerd service first
        echo "*************** Starting containerd service..."
        systemctl start containerd || {
            echo "systemctl failed, starting containerd manually..."
            setsid containerd > /var/log/containerd.log 2>&1 < /dev/null &
            disown
        }
        sleep 3
        
        # Verify containerd is running
        if ! pgrep -x containerd > /dev/null; then
            echo "ERROR: containerd failed to start"
            tail -20 /var/log/containerd.log 2>/dev/null || true
            exit 1
        fi
        echo "*************** containerd is running"
        
        # Now start Docker service
        echo "*************** Starting Docker service..."
        systemctl start docker || {
            echo "ERROR: Failed to start Docker service"
            systemctl status docker || true
            exit 1
        }
        
        # Wait for Docker to be ready with timeout
        echo "*************** Waiting for Docker to be ready..."
        for i in {1..30}; do
            if timeout 5 docker info &>/dev/null; then
                echo "*************** Docker is ready!"
                break
            fi
            if [ $i -eq 30 ]; then
                echo "ERROR: Docker failed to start properly after 30 seconds"
                echo "--- containerd status ---"
                systemctl status containerd || tail -20 /var/log/containerd.log
                echo "--- docker status ---"
                systemctl status docker || tail -20 /var/log/dockerd.log
                exit 1
            fi
            sleep 1
        done
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