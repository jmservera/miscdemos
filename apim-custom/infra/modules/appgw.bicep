@description('The name for your new Api Gateway instance.')
@maxLength(50)
@minLength(3)
param appgwName string = 'appgw-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param pubSubServiceName string
param gwSubnetId string
param zones array = [1, 2, 3]

param skuSize string = 'Standard_v2'
param skuTier string = 'Standard_v2'
param skuCapacity int = 1
@secure()
param keyVaultSecretId string
param pubsubHostName string
param webHostName string
param keyVaultIdentityName string
param keyVaultIdentityRG string
param webServiceName string

var ocppRuleSetName = 'ocppRuleSet'
var pubsubBackendPoolName = 'pubsubBackend'
var pubsubBackendSettingsName = 'pubsubBackendSettings'
var pubsubProbeName = 'pubsubProbe'
var pubsubListenerName = 'pubsubListener'
var webBackendPoolName = 'webBackend'
var webListenerName = 'webListener'
var webBackendSettingsName = 'webBackendSettings'

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' existing = {
  name: pubSubServiceName
}

resource webApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webServiceName
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: keyVaultIdentityName
  scope: resourceGroup(keyVaultIdentityRG)
}

module publicIpAddress './ipAddress.bicep' = {
  name: 'publicIpAddress'
  params: {
    publicIpAddressName: 'ip-${uniqueString(resourceGroup().id)}'
    domainNameLabel: 'd${uniqueString(resourceGroup().id)}' // ensure domain name starts with a letter
  }
}

resource appGw 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: appgwName
  location: location
  zones: zones
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
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
            id: gwSubnetId
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
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: pubsubBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: webPubSub.properties.hostName
            }
          ]
        }
      }
      {
        name: webBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: webApp.properties.defaultHostName
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: pubsubProbeName
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
        name: pubsubBackendSettingsName
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 80 //default KeepAliveInterval in PubSub is 40 seconds, doubling to 80 seconds to ensure it doesn't timeout
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appgwName, pubsubProbeName)
          }
        }
      }
      {
        name: webBackendSettingsName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180 //default KeepAliveInterval for websockets is 2 minutes, setting 3 minutes for app gateway
        }
      }
    ]
    sslCertificates: [
      {
        name: 'pubsubtls'
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ]
    httpListeners: [
      {
        name: pubsubListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appgwName,
              'appGwPublicFrontendIPv4'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appgwName, 'pubsubtls')
          }
          hostName: pubsubHostName
          customErrorConfigurations: []
          requireServerNameIndication: true
        }
      }
      {
        name: webListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appgwName,
              'appGwPublicFrontendIPv4'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appgwName, 'pubsubtls')
          }
          hostName: webHostName
          customErrorConfigurations: []
          requireServerNameIndication: true
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: ocppRuleSetName
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              conditions: [
                {
                  variable: 'var_uri_path'
                  pattern: '\\/ocpp\\/(.+)'
                  ignoreCase: true
                  negate: false
                }
                {
                  variable: 'var_request_query'
                  pattern: '(?:^|\\&)OCPP_TOKEN=([^&]+)'
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
                  modifiedQueryString: 'access_token={http_req_OCPP_TOKEN_1}'
                  reroute: false
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'pubsubRequestRule'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, pubsubListenerName)
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appgwName,
              pubsubBackendPoolName
            )
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appgwName,
              pubsubBackendSettingsName
            )
          }
          rewriteRuleSet: {
            id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', appgwName, ocppRuleSetName)
          }
        }
      }
      {
        name: 'webRequestRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, webListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwName, webBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appgwName,
              webBackendSettingsName
            )
          }
        }
      }
    ]
  }
}

output publicIPAddress string = publicIpAddress.outputs.publicIpAddress
output publicIPAddressId string = publicIpAddress.outputs.publicIpAddressId
