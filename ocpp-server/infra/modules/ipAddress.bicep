param publicIpAddressName string = 'ip-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param sku string = 'Standard'
param publicIpZones array = [1, 2, 3]
param ipAddressVersion string = 'IPv4'
param allocationMethod string = 'Static'
param domainNameLabel string

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: sku
  }
  zones: publicIpZones
  properties: {
    publicIPAddressVersion: ipAddressVersion
    publicIPAllocationMethod: allocationMethod
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }
}

output publicIpAddressId string = publicIpAddress.id
output publicIpAddress string = publicIpAddress.properties.ipAddress
