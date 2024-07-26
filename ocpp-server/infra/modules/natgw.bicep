param natGwName string
param sku string = 'Standard'
param tier string = 'Regional'
param idleTimeoutInMinutes int = 4
param location string = resourceGroup().location

resource publicIpPrefixes 'Microsoft.Network/publicIPPrefixes@2023-11-01' = {
  name: 'ipPrefixes-${natGwName}'
  location: location
  sku: {
    name: sku
    tier: tier
  }
  properties: {
    prefixLength: 28
    publicIPAddressVersion: 'IPv4'
    natGateway: {
      id: natGateway.id
    }
  }
}

resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: natGwName
  location: location
  sku: {
    name: sku
  }
  properties: {
    idleTimeoutInMinutes: idleTimeoutInMinutes
  }
}

output natGatewayId string = natGateway.id
