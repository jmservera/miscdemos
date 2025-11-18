#!/bin/sh
DEVICE_NAME="wsltestdevice"

az extension add --upgrade -n azure-iot

echo "Retrieving device identity for device ${DEVICE_NAME}"
DEVICE_KEY=$(az iot hub device-identity show -n "$IOTHUB_NAME" -d "${DEVICE_NAME}" --query authentication.symmetricKey.primaryKey > /dev/null 2>&1 ||  echo "")
if [ -z "$DEVICE_KEY" ]; then
    echo "Device not found. Creating device identity for device ${DEVICE_NAME}"
    # --ee enables edge-enabled device
    DEVICE_KEY=$(az iot hub device-identity create -n $IOTHUB_NAME -d $DEVICE_NAME --ee --query authentication.symmetricKey.primaryKey -o tsv)
    echo "Device identity created for device ${DEVICE_NAME}."
fi

azd env set DEVICE_NAME="${DEVICE_NAME}"
azd env set DEVICE_KEY="${DEVICE_KEY}"
