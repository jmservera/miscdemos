module webPubSub './modules/webPubSub.bicep' = {
  name: 'webPubSubService'
  params: {
    serviceName: 'webpubsub-${uniqueString(resourceGroup().id)}'
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
    webSiteName: webApp.outputs.webSiteName
    pubSubServiceName: webPubSub.outputs.serviceName
  }
}
