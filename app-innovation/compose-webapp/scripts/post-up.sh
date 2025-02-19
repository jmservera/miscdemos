#!/bin/sh
echo "Loading azd .env file from current environment"
# Use the `get-values` azd command to retrieve environment variables from the `.env` file
while IFS='=' read -r key value; do
    # Remove surrounding quotes and ignore trailing spaces (last value in .env seems to have one and made the whole script fail)
    value=$(echo "${value}" | sed 's/^"\(.*\)"[[:space:]]*$/\1/') 
    export "$key=${value}"
done <<EOF
$(azd env get-values) 
EOF

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
