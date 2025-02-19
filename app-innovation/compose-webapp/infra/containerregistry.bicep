param registryName string
param location string
param sku string
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: registryName
  location: location
  sku: {
    name: sku // You can specify Basic, Standard, or Premium
  }
  properties: {
    adminUserEnabled: false
  }
  tags: tags
}

output id string = containerRegistry.id
output name string = containerRegistry.name
