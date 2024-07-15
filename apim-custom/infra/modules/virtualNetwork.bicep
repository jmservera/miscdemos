param virtualNetworkName string = 'vnet-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param virtualNetworkPrefix string = '10.1.0.0/16'
param subnetName string = 'default'
param subnetPrefix string = '10.1.0.0/24'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkPrefix]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output subnets array = virtualNetwork.properties.subnets
