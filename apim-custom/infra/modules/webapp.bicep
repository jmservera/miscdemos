param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'B1' // The SKU of App Service Plan
param linuxFxVersion string = 'DOTNETCORE|8.0' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
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
      ]
    }
  }
}

output webSiteName string = appService.name
output appServiceId string = appService.id
