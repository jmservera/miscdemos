param name string = 'storage${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param sku string = 'Standard_LRS'
param kind string = 'StorageV2'
param accessTier string = 'Hot'

var storageAccountName = replace(toLower(name), '-', '')
var storageAccountName24 = substring(storageAccountName, 0, min(24, length(storageAccountName)))

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName24
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accessTier
  }
}

// add a blob services
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default' // needs to be named default
  parent: storageAccount
}

// add a blob container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: 'deployments'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output blobContaineId string = blobContainer.id
