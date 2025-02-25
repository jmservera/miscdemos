param name string
param location string
param subnetId string
param vnetId string
@description('The resource id of the resource to link with this private link.')
param privateLinkServiceId string
param registrationEnabled bool = false
param endpointName string = 'pe${name}${uniqueString(resourceGroup().id)}'

@allowed([
  'webpubsub'
  'sites'
  'blob'
  'sqlServer'
])
param targetSubResource string

var dnsByTarget = {
  webpubsub: 'privatelink.webpubsub.azure.com'
  sites: 'privatelink.azurewebsites.net'
  blob: 'privatelink.blob.${environment().suffixes.storage}'
  sqlServer: 'privatelink${environment().suffixes.sqlServerHostname}'
}

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
          privateLinkServiceId: privateLinkServiceId
          groupIds: [targetSubResource]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsByTarget[targetSubResource]
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${endpointName}-link'
  location: 'global'
  parent: privateDnsZone
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: privateEndpoint
  name: '${endpointName}-group'
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

output id string = privateEndpoint.id
output name string = privateEndpoint.name

output zoneId string = privateDnsZone.id
output zoneName string = privateDnsZone.name
