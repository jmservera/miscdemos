param virtualNetworkName string = 'vnet-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param virtualNetworkPrefix string = '10.1.0.0/16'
param subnetName string = 'default'
param subnetPrefix string = '10.1.0.0/24'
param privateSubnetName string = 'private-endpoints'
param privateSubnetPrefix string = '10.1.1.0/24'
param gatewaySubnetName string = 'gateway'
param gatewaySubnetPrefix string = '10.1.2.0/24'
param natGatewayId string

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
          natGateway: {
            id: natGatewayId
          }
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: privateSubnetName
        properties: {
          natGateway: {
            id: natGatewayId
          }
          addressPrefix: privateSubnetPrefix
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output subnets array = virtualNetwork.properties.subnets
output gwSubnetId string = virtualNetwork.properties.subnets[2].id
output privateSubnetId string = virtualNetwork.properties.subnets[1].id
output defaultSubnetId string = virtualNetwork.properties.subnets[0].id
output defaultSubnetName string = virtualNetwork.properties.subnets[0].name
