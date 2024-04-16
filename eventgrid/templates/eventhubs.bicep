param eventhub_namespace_name string = 'jmeventgrid'
param eventhub_name string = 'eventgridsink'
param location string = resourceGroup().location

resource eventhub_namespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventhub_namespace_name
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
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

// resource namespaces_jmevgrid_name_default 'Microsoft.EventHub/namespaces/networkrulesets@2023-01-01-preview' = {
//   parent: namespaces_jmevgrid_name_resource
//   name: 'default'
//   properties: {
//     publicNetworkAccess: 'Enabled'
//     defaultAction: 'Allow'
//     virtualNetworkRules: []
//     ipRules: []
//     trustedServiceAccessEnabled: false
//   }
// }

// resource namespaces_jmevgrid_name_evengridsink_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
//   parent: namespaces_jmevgrid_name_evengridsink
//   name: '$Default'
//   properties: {}
// }
