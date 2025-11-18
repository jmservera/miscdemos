#!/bin/sh
DEVICE_NAME=${DEVICE_NAME-"wsltestdevice"}

echo "Getting ACR credentials and deploying modules to IoT Edge device..."
ACR_PASSWORD=$(az acr credential show -n ${ACR_NAME} --query passwords[0].value -o tsv)
# remove any \r \n from the password
ACR_PASSWORD=$(echo $ACR_PASSWORD | tr -d '\r\n')

echo "Setting modules on device ${DEVICE_NAME} in IoT Hub ${IOTHUB_NAME}..."
# retrieve modules.json, replace placeholders and set it to a MODULES variable
MODULES=$(cat ./modules.json | sed "s|\${ACR_LOGIN_SERVER}|${ACR_LOGIN_SERVER}|g" | sed "s|\${ACR_NAME}|${ACR_NAME}|g" | sed "s|\${ACR_PASSWORD}|${ACR_PASSWORD}|g")

az iot edge set-modules --device-id "$DEVICE_NAME" --hub-name "$IOTHUB_NAME" \
    --content "$MODULES"

CONNECTION_STRING=$(az iot hub device-identity connection-string show -d "$DEVICE_NAME" -n "$IOTHUB_NAME" --query  connectionString -o tsv)
CONNECTION_STRING=$(echo $CONNECTION_STRING | tr -d '\r\n')

echo "Deployment complete."
echo "You can now configure your edge device with the following commands:"
echo "   sudo iotedge config mp --connection-string \"$CONNECTION_STRING\" --force"
echo "   sudo iotedge config apply"
echo "Or by running the install script again with the same device connection string."
echo "curl -LsSf https://raw.githubusercontent.com/jmservera/miscdemos/refs/heads/jmservera/iotedge/iotedge/ubuntu-24.04-install.sh | sudo bash -s -- \"${CONNECTION_STRING}\""
