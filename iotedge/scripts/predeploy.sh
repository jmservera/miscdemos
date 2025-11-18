#!/bin/sh

DEVICE_NAME=${DEVICE_NAME-"wsltestdevice"}

az extension add --upgrade -n azure-iot

echo "Retrieving device identity for device ${DEVICE_NAME}"
DEVICE_KEY=$(az iot hub device-identity show -n "$IOTHUB_NAME" -d "${DEVICE_NAME}" --query authentication.symmetricKey.primaryKey -o tsv 2>/dev/null || echo "")
if [ -z "$DEVICE_KEY" ]; then
    echo "Device not found. Creating device identity for device ${DEVICE_NAME}"
    # --ee enables edge-enabled device
    DEVICE_KEY=$(az iot hub device-identity create -n "$IOTHUB_NAME" -d "$DEVICE_NAME" --ee --query authentication.symmetricKey.primaryKey -o tsv)
    echo "Device identity created for device ${DEVICE_NAME}."
fi

echo "Building Docker images and pushing to ACR..."
cd nginx
az acr build --registry "$ACR_NAME" --image nginx-proxy:latest .
if [ $? -ne 0 ]; then
    echo "Error: az acr build failed." >&2
    exit 1
fi
cd ..
echo "Pre-deployment script executed."