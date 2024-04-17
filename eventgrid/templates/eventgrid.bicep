@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('The name of the Event Grid namespace.')
param namespaces_name string = 'jmeventgrid'
param custom_topic_name string ='test'
@description('An array containing the clients that will be allowed to interact with the Event Grid namespace. Each client must have a name, a thumbprint, and a role. The role can be either "service" or "device".')
param clients array = [
  {
    name: 'name of client'
    thumbprint: 'base64 encoded thumbprint'
    role: 'service or device'
  }
]

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
//      routeTopicResourceId: resourceId('Microsoft.EventGrid/namespaces/topics', namespaces_name, custom_topic_name)
      routingIdentityInfo: {
         type: 'SystemAssigned'
        }
      }
    isZoneRedundant: true
    publicNetworkAccess: 'Enabled'
  }

  resource topics 'topics' = {
    name: custom_topic_name
    properties: {
      publisherType: 'Custom'
      inputSchema: 'CloudEventSchemaV1_0'
      eventRetentionInDays: 7
    }
  }

}

// ********************************************************************************************************************
// * Create client groups
// ********************************************************************************************************************

resource namespace_group_c2d_publishers 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'publishers'
  properties: {
    description: 'Group for services that can send data to devices.'
    query: 'attributes.role in [\'service\']'
  }
}

resource namespace_group_telemetry_subscribers 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'datasubscribers'
  properties: {
    description: 'Group for services that can subscribe to the device data feed.'
    query: 'attributes.role in [\'service\', \'device\']'
  }
}

resource namespace_group_devices 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'devices'
  properties: {
    description: 'Group for the devices.'
    query: 'attributes.role in [\'device\']'
  }
}

// ********************************************************************************************************************
// * Create permission bindings
// ********************************************************************************************************************

resource namespace_telemetrypublish 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'telemetrypublish'
  properties: {
    topicSpaceName: namespace_topic_spaces_data.name
    permission: 'Publisher'
    clientGroupName: namespace_group_devices.name
  }
}

resource namespace_telemetryread 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'telemetryread'
  properties: {
    topicSpaceName: namespace_topic_spaces_data.name
    permission: 'Subscriber'
    clientGroupName: namespace_group_telemetry_subscribers.name
  }
}

resource namespace_devicespublish 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'devicespublish'
  properties: {
    topicSpaceName: namespace_topic_spaces_devices.name
    permission: 'Publisher'
    clientGroupName: namespace_group_c2d_publishers.name
  }
}

resource namespace_devicessubscribe 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'devicessubscribe'
  properties: {
    topicSpaceName: namespace_topic_spaces_devices.name
    permission: 'Subscriber'
    clientGroupName: namespace_group_telemetry_subscribers.name
  }
}



// ********************************************************************************************************************
// * Create topic spaces
// ********************************************************************************************************************
resource namespace_topic_spaces_data 'Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'data'
  properties: {
    topicTemplates: [
      'data/#'
      'data/\${client.authenticationName}/telemetry'
    ]
  }
}

resource namespace_topic_spaces_devices 'Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview' = {
  parent: namespace_resource
  name: 'devices'
  properties: {
    topicTemplates: [
      'devices/#'
    ]
  }
}

// ********************************************************************************************************************
// * Create clients
// ********************************************************************************************************************

resource namespaces_name_clients 'Microsoft.EventGrid/namespaces/clients@2023-12-15-preview' = [
  for (config, i) in clients: {
    parent: namespace_resource
    name: config.name
    properties: {
      authenticationName: '${config.name}-authn-ID'
      clientCertificateAuthentication: {
        validationScheme: 'ThumbprintMatch'
        allowedThumbprints: [
          config.thumbprint
        ]
      }
      state: 'Enabled'
      attributes: {
        role: config.role
      }
    }
  }
]

output namespace_mqtt_hostname string = namespace_resource.properties.topicSpacesConfiguration.hostname
