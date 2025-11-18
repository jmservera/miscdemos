#!/bin/sh

echo "Building Docker images and pushing to ACR..."
cd nginx
az acr build --registry $ACR_NAME --image nginx-proxy:latest .
cd ..
echo "Pre-deployment script executed."