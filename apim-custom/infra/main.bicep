@description('This Bicep file deploys an API Management service with a custom domain and a custom certificate.')
param publisherName string
@description('The email address of the API Management service publisher.')
param publisherEmail string

// Create an API Management service from the modules/apim.bicep
module apim './modules/apim.bicep' = {
  name: 'apimService'
  params: {
    apimName: 'apim-${uniqueString(resourceGroup().id)}'
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}

module webPubSub './modules/webPubSub.bicep' = {
  name: 'webPubSubService'
  params: {
    serviceName: 'webpubsub-${uniqueString(resourceGroup().id)}'
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webAppService'
  params: {
    webAppName: 'webapp-${uniqueString(resourceGroup().id)}'
    sku: 'F1'
    linuxFxVersion: 'DOTNETCORE|8.0'
  }
}
