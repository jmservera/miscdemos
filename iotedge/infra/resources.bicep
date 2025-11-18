@description('prefix used in some resource names to make them unique')
param location string
@minLength(3)
@maxLength(22)
param resourceToken string
param tags object

var acrName = 'acreg${take(toLower(replace(resourceToken, '-', '')), 17)}' // Always starts with 'acreg' (5 chars)

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    // Conditional public network access for dev scenarios; see README for details.
    publicNetworkAccess: 'Enabled' // checkov:skip=CKV_AZURE_139: Conditional access for remote build
    // networkRuleBypassOptions: 'AzureServices'
    // Anonymous pull is intentionally disabled for security reasons
    anonymousPullEnabled: false
    // Enable data endpoint authentication for improved security
    // dataEndpointEnabled: true
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: 'iothub${take(toLower(replace(resourceToken, '-', '')), 20)}' // Always starts with 'iothub' (6 chars)
  location: location
  tags: tags
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    enableFileUploadNotifications: false
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    features: 'None'
  }
}

output ACR_NAME string = containerRegistry.name
output ACR_LOGIN_SERVER string = containerRegistry.properties.loginServer
output IOTHUB_NAME string = iotHub.name

