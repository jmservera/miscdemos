param eventhub_namespace_name string = 'jmeventgrid'
param eventhub_name string = 'eventgridsink'
param location string = resourceGroup().location

resource eventhub_namespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventhub_namespace_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    privateEndpointConnections: []
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}

resource eventhubs_eventgridsink 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventhub_namespace
  name: eventhub_name
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}

output eventhub object= eventhub_namespace
