param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'B1' // The SKU of App Service Plan
param linuxFxVersion string = 'DOTNETCORE|8.0' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
param pubSubName string
param subnetName string
param vnetName string

var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')
var appInsightsName = 'appInsights-${uniqueString(resourceGroup().id)}'

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource pubSub 'Microsoft.SignalRService/webPubSub@2024-04-01-preview' existing = {
  name: pubSubName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    name: 'webdeploy-${uniqueString(resourceGroup().id)}'
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        // Application Insights needs these three settings to be activated
        // APPLICATIONINSIGHTS_CONNECTION_STRING, ApplicationInsightsAgent_EXTENSION_VERSION
        // with the value ~3 for Linux apps, and XDT_MicrosoftApplicationInsights_Mode with the value recommended
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'WEBPUBSUB_SERVICE_CONNECTION_STRING'
          value: pubSub.listKeys().primaryConnectionString
        }
      ]
    }
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vNet
}

resource vnetconfig 'Microsoft.Web/sites/networkConfig@2022-09-01' = {
  name: 'virtualNetwork'
  parent: appService
  properties: {
    subnetResourceId: subNet.id
    swiftSupported: true
  }
}

// enable ipSecurityRestrictions for the appService
resource ipSecurityRestrictions 'Microsoft.Web/sites/config@2023-12-01' = {
  name: 'web'
  parent: appService
  properties: {
    publicNetworkAccess: 'Enabled'
    ipSecurityRestrictions: [
      {
        ipAddress: 'AzureWebPubSub'
        action: 'Allow'
        tag: 'ServiceTag'
        priority: 100
        name: 'pubsub'
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
  }
}

output webSiteName string = appService.name
output appServiceId string = appService.id
output storageName string = storage.outputs.storageAccountName