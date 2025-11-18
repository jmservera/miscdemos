targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param name string
@minLength(1)
@description('Primary location for all resources')
param location string
@description('Container image name to use for the nginx <image_name>:<tag>')
param containerImageName string = 'nginx-proxy:latest'

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = { 'azd-env-name': name }

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: resourceGroup
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = subscription().tenantId
output RESOURCE_GROUP_NAME string = resourceGroup.name
output ACR_NAME string = resources.outputs.ACR_NAME
output ACR_LOGIN_SERVER string = resources.outputs.ACR_LOGIN_SERVER
output IOTHUB_NAME string = resources.outputs.IOTHUB_NAME
