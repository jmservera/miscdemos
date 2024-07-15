// an azure webpubsub service
@description('The name for your new Web PubSub instance.')
@maxLength(63)
@minLength(3)
param serviceName string = 'webpubsub-${uniqueString(resourceGroup().id)}'

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
param sku string = 'Free_F1'

@description('Pricing tier')
@allowed([
  'Free'
  'Standard'
])
param pricingTier string = 'Free'

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: serviceName
  location: location
  sku: {
    capacity: unitCount
    name: sku
    tier: pricingTier
  }
}

output serviceId string = webPubSub.id
output serviceName string = webPubSub.name
output serviceEndpoint string = webPubSub.properties.hostName
