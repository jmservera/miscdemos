#!/bin/sh

echo "Building Docker images and pushing to ACR..."
cd nginx
az acr build --registry "$ACR_NAME" --image nginx-proxy:latest .
if [ $? -ne 0 ]; then
    echo "Error: az acr build failed." >&2
    exit 1
fi
cd ..
echo "Pre-deployment script executed."