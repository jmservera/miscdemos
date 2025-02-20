#!/bin/sh
echo "Loading azd .env file from current environment"
# Use the `get-values` azd command to retrieve environment variables from the `.env` file
eval $(azd env get-values)

echo "Logging into Azure Container Registry"
az acr login --name "${containerRegistryName}"

echo "Building and pushing container images to Azure Container Registry"
cd src/frontend
docker build -t "${containerRegistryName}.azurecr.io/${webAppContainerImageName}" .
docker push "${containerRegistryName}.azurecr.io/${webAppContainerImageName}"
cd ../backend
docker build -t "${containerRegistryName}.azurecr.io/${backendAppContainerImageName}" .
docker push "${containerRegistryName}.azurecr.io/${backendAppContainerImageName}"

echo "Restarting Azure Web App (${webAppName})"
az webapp restart -g "${resourceGroupName}" -n "${webAppName}"

echo "Your app will be available at ${serviceUrl}"
