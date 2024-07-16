@description('The region in which to create the new instance, defaults to the same location as the resource group.')
param location string = resourceGroup().location
param endpointName string = 'privateep${uniqueString(resourceGroup().id)}'
param vnetId string
param subnetId string
@description('The resource id of the resource to link with this private link.')
param privateLinkResource string
param targetSubResource array = ['webpubsub']

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: endpointName
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: '${endpointName}-nic'
    privateLinkServiceConnections: [
      {
        name: endpointName
        properties: {
          privateLinkServiceId: privateLinkResource
          groupIds: targetSubResource
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  // it is important to set the right location
  // https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
  name: 'privatelink.webpubsub.azure.com'
  location: 'global'
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${endpointName}-link'
  location: 'global'
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${endpointName}-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-${endpointName}'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
