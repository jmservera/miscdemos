@secure()
param keyVaultSecretId string
param keyVaultIdentityName string
param pubsubHostName string
param keyVaultIdentityRG string = resourceGroup().name
module virtualNetwork './modules/virtualNetwork.bicep' = {
  name: 'vNet'
  params: {
    virtualNetworkName: 'vnet-${uniqueString(resourceGroup().id)}'
  }
}

module webPubSub './modules/webPubSub.bicep' = {
  name: 'webPubSubService'
  params: {
    serviceName: 'webpubsub-${uniqueString(resourceGroup().id)}'
  }
}

module webPubSubPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'webPubSubPrivateEndpoint'
  params: {
    privateLinkResource: webPubSub.outputs.serviceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
  }
}

module appInsights './modules/appInsights.bicep' = {
  name: 'appInsightsService'
  params: {
    appInsightsName: 'appInsights-${uniqueString(resourceGroup().id)}'
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webAppService'
  params: {
    webAppName: 'webapp-${uniqueString(resourceGroup().id)}'
    sku: 'F1'
    linuxFxVersion: 'DOTNETCORE|8.0'
    appInsightsName: appInsights.outputs.appInsightsName
  }
  dependsOn: [
    appInsights
  ]
}

module appGw './modules/appgw.bicep' = {
  name: 'appGwService'
  params: {
    appgwName: 'appgw-${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    pubSubServiceName: webPubSub.outputs.serviceName
    gwSubnetId: virtualNetwork.outputs.gwSubnetId
    keyVaultSecretId: keyVaultSecretId
    pubsubHostName: pubsubHostName
    keyVaultIdentityName: keyVaultIdentityName
    keyVaultIdentityRG: keyVaultIdentityRG
  }
}

output appGatewayPublicIp string = appGw.outputs.publicIPAddress
