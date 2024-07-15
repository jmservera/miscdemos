@description('The name for your new Api Gateway instance.')
@maxLength(50)
@minLength(3)
param appInsightsName string = 'appInsights-${uniqueString(resourceGroup().id)}'

resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output appInsightsName string = appInsights.name
output appInsightsId string = appInsights.id
