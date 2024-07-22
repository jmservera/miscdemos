param serviceName string
param hubName string
param webAppName string

resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource webPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' existing = {
  name: serviceName
}

resource hub 'Microsoft.SignalRService/WebPubSub/hubs@2024-01-01-preview' = {
  parent: webPubSub
  name: hubName
  properties: {
    eventHandlers: [
      {
        urlTemplate: 'https://${webApp.properties.defaultHostName}/eventhandler/{event}'
        userEventPattern: '*'
        systemEvents: [
          'connected'
          'connect'
          'disconnected'
        ]
      }
      {
        urlTemplate: 'tunnel:///eventhandler'
        userEventPattern: '*'
        systemEvents: [
          'connect'
          'connected'
          'disconnected'
        ]
      }
    ]
    eventListeners: []
    anonymousConnectPolicy: 'allow'
  }
}
