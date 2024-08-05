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
param pubsubHostName string
param webHostName string
param keyVaultName string
param keyVaultRG string
param keyVaultIdentityName string
param keyVaultIdentityRG string
param webServiceName string
param pubsubHubName string
param webKeyVaultCertName string
param pubsubKeyVaultCertName string

var ocppRuleSetName = 'ocppRuleSet'
var pubsubBackendPoolName = 'pubsubBackend'
var pubsubBackendSettingsName = 'pubsubBackendSettings'
var pubsubProbeName = 'pubsubProbe'
var webProbeName = 'webProbe'
var port80ListenerName = 'port80Listener'
var pubsubListenerName = 'pubsubListener'
var webBackendPoolName = 'webBackend'
var webListenerName = 'webListener'
var webBackendSettingsName = 'webBackendSettings'
var webtls = 'webtls'
var pubsubtls = 'pubsubtls'
var port80 = 'port_80'
var port443 = 'port_443'
var redirectConfigName = 'redirect80to443'

var isWildcard = (webKeyVaultCertName == pubsubKeyVaultCertName)
var isSecure = (webKeyVaultCertName != '' && pubsubKeyVaultCertName != '')

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (isSecure) {
  name: keyVaultName
  scope: resourceGroup(keyVaultRG)
}

resource pubsubKeyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = if (isSecure) {
  name: pubsubKeyVaultCertName
  parent: keyVault
}

resource webKeyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = if (isSecure) {
  name: webKeyVaultCertName
  parent: keyVault
}

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' existing = {
  name: pubSubServiceName
}

resource webApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webServiceName
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (isSecure) {
  name: keyVaultIdentityName
  scope: resourceGroup(keyVaultIdentityRG)
}

module publicIpAddress './ipAddress.bicep' = {
  name: '${deployment().name}-appgw-publicIpAddress'
  params: {
    publicIpAddressName: 'ip-${uniqueString(resourceGroup().id)}'
    domainNameLabel: 'd${uniqueString(resourceGroup().id)}' // ensure domain name starts with a letter
  }
}

resource appGw 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: appgwName
  location: location
  zones: zones
  identity: isSecure
    ? {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${identity.id}': {}
        }
      }
    : {
        type: 'None'
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
        name: port80
        properties: {
          port: 80
        }
      }
      {
        name: port443
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
      {
        name: webProbeName
        properties: {
          protocol: 'Https'
          host: webHostName
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
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
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appgwName, webProbeName)
          }
        }
      }
    ]
    sslCertificates: isSecure
      ? isWildcard
          ? [
              {
                name: pubsubtls
                properties: {
                  keyVaultSecretId: pubsubKeyVaultCertificate.properties.secretUri
                }
              }
            ]
          : [
              {
                name: pubsubtls
                properties: {
                  keyVaultSecretId: pubsubKeyVaultCertificate.properties.secretUri
                }
              }
              {
                name: webtls
                properties: {
                  keyVaultSecretId: webKeyVaultCertificate.properties.secretUri
                }
              }
            ]
      : []
    httpListeners: isSecure
      ? [
          {
            name: port80ListenerName
            properties: {
              frontendIPConfiguration: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/frontendIPConfigurations',
                  appgwName,
                  'appGwPublicFrontendIPv4'
                )
              }
              frontendPort: {
                id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, port80)
              }
              protocol: 'Http'
              hostName: webHostName
            }
          }
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
                id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, port443)
              }
              protocol: 'Https'
              sslCertificate: {
                id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appgwName, pubsubtls)
              }
              hostName: pubsubHostName
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
                id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, port443)
              }
              protocol: 'Https'
              sslCertificate: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/sslCertificates',
                  appgwName,
                  isWildcard ? pubsubtls : webtls
                )
              }
              hostName: webHostName
              requireServerNameIndication: true
            }
          }
        ]
      : [
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
                id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, port80)
              }
              protocol: 'Http'
              hostName: pubsubHostName
              requireServerNameIndication: false
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
                  variable: 'http_req_Authorization'
                  pattern: 'BASIC (.*)'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'ocpp to pubsub with token'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'device'
                    headerValue: '{var_uri_path_1}'
                  }
                  {
                    headerName: 'Authorization'
                  }
                ]
                responseHeaderConfigurations: []
                urlConfiguration: {
                  modifiedPath: '/client/hubs/OcppService'
                  modifiedQueryString: 'auth={http_req_Authorization_1}&id={var_uri_path_1}'
                  reroute: false
                }
              }
            }
            {
              ruleSequence: 200
              conditions: [
                {
                  variable: 'var_uri_path'
                  pattern: '\\/ocpp\\/(.+)'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'ocpp to pubsub unauthenticated'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'device'
                    headerValue: '{var_uri_path_1}'
                  }
                ]
                responseHeaderConfigurations: []
                urlConfiguration: {
                  modifiedPath: '/client/hubs/${pubsubHubName}'
                  modifiedQueryString: 'id={var_uri_path_1}'
                  reroute: false
                }
              }
            }
          ]
        }
      }
    ]
    redirectConfigurations: isSecure
      ? [
          {
            name: redirectConfigName
            properties: {
              redirectType: 'Permanent'
              targetListener: {
                id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, webListenerName)
              }
              includePath: true
              includeQueryString: true
            }
          }
        ]
      : []
    requestRoutingRules: isSecure
      ? [
          {
            name: 'port80RequestRule'
            properties: {
              ruleType: 'Basic'
              priority: 50
              httpListener: {
                id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, port80ListenerName)
              }
              redirectConfiguration: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/redirectConfigurations',
                  appgwName,
                  redirectConfigName
                )
              }
            }
          }
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
                id: resourceId(
                  'Microsoft.Network/applicationGateways/backendAddressPools',
                  appgwName,
                  webBackendPoolName
                )
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
      : [
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
        ]
  }
}

output publicIPAddress string = publicIpAddress.outputs.publicIpAddress
output publicIPAddressId string = publicIpAddress.outputs.publicIpAddressId
