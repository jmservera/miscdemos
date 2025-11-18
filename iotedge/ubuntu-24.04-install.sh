#!/bin/bash

set -e

# Helper function to wait for a service to be ready
wait_for_service() {
    local service_name="$1"
    local check_command="$2"
    local max_attempts="${3:-30}"
    
    echo "*************** Waiting for $service_name to be ready..."
    for i in $(seq 1 $max_attempts); do
        if eval "$check_command" &>/dev/null; then
            echo "*************** $service_name is ready!"
            return 0
        fi
        sleep 1
    done
    echo "ERROR: $service_name failed to start after $max_attempts seconds"
    return 1
}

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

# Configure WSL if needed
if ! grep -q "generateResolvConf" /etc/wsl.conf 2>/dev/null; then
    echo "*************** Configuring WSL settings"
    cat << EOF >> /etc/wsl.conf
[network]
generateResolvConf=false
hostname=$DEVICE_ID
EOF
fi

# Configure DNS if needed
if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf 2>/dev/null; then
    echo "*************** Configuring DNS"
    mountpoint -q /etc/resolv.conf 2>/dev/null && umount /etc/resolv.conf || true
    cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true
fi

wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update

# Install and configure Docker
if ! command -v docker &> /dev/null; then
    echo "*************** Installing Docker"
    apt-get install moby-engine -y
fi

# Configure Docker daemon if needed
if ! grep -q "1.1.1.1" /etc/docker/daemon.json 2>/dev/null; then
    echo "*************** Configuring Docker DNS"
    echo '{ "log-driver": "local", "dns": ["1.1.1.1"] }' > /etc/docker/daemon.json
fi

# Configure Docker systemd service PATH if needed
if [ ! -f /etc/systemd/system/docker.service.d/override.conf ]; then
    echo "*************** Configuring Docker systemd PATH"
    mkdir -p /etc/systemd/system/docker.service.d
    cat > /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF
    systemctl daemon-reload
    systemctl reset-failed docker.service 2>/dev/null || true
fi

# Start Docker if not running
if ! docker info &>/dev/null; then
    echo "*************** Starting Docker services"
    systemctl restart containerd docker
    wait_for_service "Docker" "docker info" || {
        echo "Docker logs:"
        journalctl -u docker --no-pager -n 50
        exit 1
    }
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


# Wait for IoT Edge services
echo "*************** Checking IoT Edge services"
wait_for_service "IoT Edge" "iotedge system status | grep -q 'aziot-keyd.*Running' && iotedge system status | grep -q 'aziot-certd.*Running'" 60 || {
    echo "IoT Edge status:"
    iotedge system status || true
    exit 1
}

echo "*************** Final IoT Edge check and listing modules"

# Wait for edgeHub docker container to be running
wait_for_service "edgeHub module" "docker ps --filter 'name=edgeHub' --filter 'status=running' | grep -q edgeHub" 120 || {
    echo "Docker containers:"
    docker ps || true
    exit 1
}


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