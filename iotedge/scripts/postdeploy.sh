#!/bin/sh

echo "Getting ACR credentials and deploying modules to IoT Edge device..."
ACR_PASSWORD=$(az acr credential show -n ${ACR_NAME} --query passwords[0].value -o tsv)
# remove any \r \n from the password
ACR_PASSWORD=$(echo $ACR_PASSWORD | tr -d '\r\n')

echo "Setting modules on device ${DEVICE_NAME} in IoT Hub ${IOTHUB_NAME}..."
# retrieve modules.json, replace placeholders and set it to a MODULES variable
MODULES=$(cat ./modules.json | sed "s|\${ACR_LOGIN_SERVER}|${ACR_LOGIN_SERVER}|g" | sed "s|\${ACR_NAME}|${ACR_NAME}|g" | sed "s|\${ACR_PASSWORD}|${ACR_PASSWORD}|g")

az iot edge set-modules --device-id "$DEVICE_NAME" --hub-name "$IOTHUB_NAME" \
    --content "$MODULES"

echo "Deployment complete."