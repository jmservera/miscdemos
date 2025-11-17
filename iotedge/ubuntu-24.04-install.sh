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

# Disable WSL auto generation of resolv.conf
if [ -f /etc/wsl.conf ]; then
    if grep -q "generateResolvConf" /etc/wsl.conf; then
        echo "/etc/wsl.conf already contains generateResolvConf setting"
    else
        echo "*************** Adding generateResolvConf setting to /etc/wsl.conf"
        cat << EOF >> /etc/wsl.conf
[network]
generateResolvConf = false
EOF
    fi
else
    touch /etc/wsl.conf
fi

if grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
    echo "*************** /etc/resolv.conf already configured"    
else
    echo "*************** Configuring /etc/resolv.conf"
    cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 172.28.48.1
EOF
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


if grep -q "1.1.1.1" /etc/docker/daemon.json; then
    echo "*************** Docker already configured to use custom DNS"
else
    echo "*************** /etc/docker/daemon.json not configured"
    # configure docker to use custom dns
    echo "*************** Configuring Docker to use custom DNS"
    echo '{ "log-driver": "local", "dns": ["1.1.1.1"] }' | tee /etc/docker/daemon.json
    systemctl restart docker
fi

if ! command -v iotedge &> /dev/null; then
    echo "*************** Installing IoT Edge dependencies"
    apt-get install aziot-edge -y
else
    echo "*************** IoT Edge already installed"
fi
echo "*************** Installing IoT Edge"


echo "*************** Configuring IoT Edge"
iotedge config mp --connection-string "$1"
iotedge config apply

# Check the installation
iotedge system status
iotedge check
iotedge list
iotedge system logs -- -f