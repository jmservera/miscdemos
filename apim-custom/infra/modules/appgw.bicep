@description('The name for your new Api Gateway instance.')
@maxLength(50)
@minLength(3)
param appgwName string = 'appgw-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param webSiteName string
param zones array = [1, 2, 3]

param skuSize string = 'Standard_v2'
param skuTier string = 'Standard_v2'
param skuCapacity int = 1

resource appService 'Microsoft.Web/sites@2020-06-01' existing = {
  name: webSiteName
}

module virtualNetwork './virtualNetwork.bicep' = {
  name: 'vNet'
  params: {
    virtualNetworkName: 'vnet-${uniqueString(resourceGroup().id)}'
  }
}

module publicIpAddress './ipAddress.bicep' = {
  name: 'publicIpAddress'
  params: {
    publicIpAddressName: 'ip-${uniqueString(resourceGroup().id)}'
  }
}

resource appGw 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: appgwName
  location: location
  zones: zones
  properties: {
    sku: {
      name: skuSize
      tier: skuTier
      capacity: skuCapacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: virtualNetwork.outputs.subnets[0].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIPv4'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.outputs.publicIpAddressId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'wspool'
        properties: {
          backendAddresses: [
            {
              fqdn: appService.properties.defaultHostName
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'wsAffinity'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Enabled'
          requestTimeout: 20
          path: '/ws'
          affinityCookieName: 'ApplicationGatewayAffinity'
        }
      }
    ]
    httpListeners: [
      {
        name: 'ws'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appgwName,
              'appGwPublicFrontendIPv4'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, 'port_80')
          }
          protocol: 'Http'
          sslCertificate: null
          customErrorConfigurations: []
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'basicRule'
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, 'ws')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwName, 'wspool')
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appgwName,
              'wsAffinity'
            )
          }
        }
      }
    ]
  }
}
