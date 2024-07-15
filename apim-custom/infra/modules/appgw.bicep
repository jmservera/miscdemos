@description('The name for your new Api Gateway instance.')
@maxLength(50)
@minLength(3)
param appgwName string = 'appgw-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param webSiteName string
param pubSubServiceName string
param zones array = [1, 2, 3]

param skuSize string = 'Standard_v2'
param skuTier string = 'Standard_v2'
param skuCapacity int = 1

resource appService 'Microsoft.Web/sites@2020-06-01' existing = {
  name: webSiteName
}

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' existing = {
  name: pubSubServiceName
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
    domainNameLabel: uniqueString(resourceGroup().id)
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
        name: 'pubsub'
        properties: {
          backendAddresses: [
            {
              fqdn: webPubSub.properties.hostName
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'pubSubClient'
        properties: {
          protocol: 'Https'
          host: webPubSub.properties.hostName
          path: '/client'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            body: 'Invalid value of \'hub\'.'
            statusCodes: [
              '400'
            ]
          }
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'pubsub'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appgwName, 'pubSubClient')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'websocket'
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
        name: 'websocketrule'
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, 'websocket')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwName, 'pubsub')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgwName, 'pubsub')
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'ocpp'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              conditions: [
                {
                  variable: 'var_uri_path'
                  pattern: '/ocpp/(.+)'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'ocpp to pubsub'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'device'
                    headerValue: '{var_uri_path_1}'
                  }
                ]
                responseHeaderConfigurations: []
                urlConfiguration: {
                  modifiedPath: '/client/hubs/hubby'
                  //TODO: This is a placeholder for the access token, retrieve it from the query headers
                  modifiedQueryString: 'access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ3c3M6Ly93ZWJwdWJzdWItbG9vNjc2eHBxajVsdS53ZWJwdWJzdWIuYXp1cmUuY29tL2NsaWVudC9odWJzL2h1YmJ5IiwiaWF0IjoxNzIxMDgwNDE0LCJleHAiOjE3MjEwODQwMTR9.P9yzWg6c_Paz2OBEfXHM-b6q4fxOtM2vo858pB9Xwl4'
                  reroute: false
                }
              }
            }
          ]
        }
      }
    ]
  }
}
