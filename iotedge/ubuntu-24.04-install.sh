#!/bin/bash

set -e

# check for root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <iot-edge-device-connection-string>"
    exit 1
fi


wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update
apt-get install moby-engine


echo '{ "log-driver": "local" }' | tee /etc/docker/daemon.json
systemctl restart docker

apt-get install aziot-edge

iotedge config mp --connection-string "$1"
iotedge config apply

# Check the installation
iotedge system status
iotedge check
iotedge list