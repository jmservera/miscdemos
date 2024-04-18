param namespaces_name string
param location string
param routeTopicResourceId string = ''


resource namespace_resource 'Microsoft.EventGrid/namespaces@2023-12-15-preview' = {
  name: namespaces_name
  location: location
  sku: {
    name: 'Standard'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    topicsConfiguration: {}
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumSessionExpiryInHours: 2
      maximumClientSessionsPerAuthenticationName: 2 // to allow for some disconnection test scenarios
      routeTopicResourceId: routeTopicResourceId // resourceId('Microsoft.EventGrid/namespaces/topics', namespaces_name, custom_topic_name)
    }
    isZoneRedundant: true
    publicNetworkAccess: 'Enabled'
  }
}

output namespace_resource object = namespace_resource
