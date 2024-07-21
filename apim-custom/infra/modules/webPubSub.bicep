// an azure webpubsub service
@description('The name for your new Web PubSub instance.')
@maxLength(63)
@minLength(3)
param serviceName string = 'webpubsub-${uniqueString(resourceGroup().id)}'
param hubName string = 'OcppService'

@description('The region in which to create the new instance, defaults to the same location as the resource group.')
param location string = resourceGroup().location

@description('Unit count')
@allowed([
  1
  2
  5
  10
  20
  50
  100
])
param unitCount int = 1

@description('SKU name')
@allowed([
  'Standard_S1'
  'Free_F1'
])
param sku string = 'Standard_S1'

@description('Pricing tier')
@allowed([
  'Free'
  'Standard'
])
param pricingTier string = 'Standard'

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: serviceName
  location: location
  sku: {
    capacity: unitCount
    name: sku
    tier: pricingTier
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource hub 'Microsoft.SignalRService/WebPubSub/hubs@2024-01-01-preview' = {
  parent: webPubSub
  name: hubName
  properties: {
    eventHandlers: []
    eventListeners: []
    anonymousConnectPolicy: 'allow'
  }
}

output serviceId string = webPubSub.id
output serviceName string = webPubSub.name
output serviceEndpoint string = webPubSub.properties.hostName
