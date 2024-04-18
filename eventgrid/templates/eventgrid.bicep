@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('The name of the Event Grid namespace.')
param namespaces_name string = 'jmeventgrid'
@minLength(3)
param custom_topic_name string = 'test'
@description('An array containing the clients that will be allowed to interact with the Event Grid namespace. Each client must have a name, a thumbprint, and a role. The role can be either "service" or "device".')
param clients array = [
  {
    name: 'name of client'
    thumbprint: 'base64 encoded thumbprint'
    role: 'service or device'
  }
]

var names = {
  topics:{
    data: 'data'
    devices: 'devices'
  }
  clientGroups:{
    publishers: 'publishers'
    datasubscribers: 'datasubscribers'
    devices: 'devices'
  }
}

// we use a module to create the basic Event Grid namespace
// because when building the integration with Event Hub and assigning the routeTopicResourceId
// we will need to call the module again
module namespace_creation 'modules/eventgridinstance.bicep' = {
  name: namespaces_name
  params: {
    location: location
    namespaces_name: namespaces_name
  }
}

resource topics 'Microsoft.EventGrid/namespaces/topics@2023-12-15-preview' = {
  name: '${namespaces_name}/${custom_topic_name}' // now with the module we cannot use the parent property, so using the names instead
  properties: {
    inputSchema: 'CloudEventSchemaV1_0'
  }
  dependsOn:[
    namespace_creation
  ]
}

// ********************************************************************************************************************
// * Create client groups
// ********************************************************************************************************************

resource namespace_group_c2d_publishers 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  name: '${namespaces_name}/${names.clientGroups.publishers}'
  properties: {
    description: 'Group for services that can send data to devices.'
    query: 'attributes.role in [\'service\']'
  }
  dependsOn:[
    namespace_creation
  ]
}

resource namespace_group_telemetry_subscribers 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  name: '${namespaces_name}/${names.clientGroups.datasubscribers}'
  properties: {
    description: 'Group for services that can subscribe to the device data feed.'
    query: 'attributes.role in [\'service\', \'device\']'
  }
  dependsOn:[
    namespace_creation
  ]
}

resource namespace_group_devices 'Microsoft.EventGrid/namespaces/clientGroups@2023-12-15-preview' = {
  name: '${namespaces_name}/${names.clientGroups.devices}'
  properties: {
    description: 'Group for the devices.'
    query: 'attributes.role in [\'device\']'
  }
  dependsOn:[
    namespace_creation
  ]
}

// ********************************************************************************************************************
// * Create permission bindings
// ********************************************************************************************************************

resource namespace_telemetrypublish 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  name: '${namespaces_name}/telemetrypublish'
  properties: {
    topicSpaceName: names.topics.data //cannot contain namespace name prefix, so we cannot use the namespace_topic_spaces_data.name variable
    permission: 'Publisher'
    clientGroupName: names.clientGroups.devices // cannot contain the namespace prefix, so we cannot use the namespace_group_devices.name variable
  }
  dependsOn:[
    namespace_creation
    namespace_group_devices
  ]
}

resource namespace_telemetryread 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  name: '${namespaces_name}/telemetryread'
  properties: {
    topicSpaceName: names.topics.data
    permission: 'Subscriber'
    clientGroupName: names.clientGroups.datasubscribers
  }
  dependsOn:[
    namespace_creation
    namespace_group_telemetry_subscribers
  ]
}

resource namespace_devicespublish 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  name: '${namespaces_name}/devicespublish'
  properties: {
    topicSpaceName: names.topics.devices
    permission: 'Publisher'
    clientGroupName: names.clientGroups.publishers
  }
  dependsOn:[
    namespace_creation
    namespace_group_c2d_publishers
  ]
}

resource namespace_devicessubscribe 'Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview' = {
  name: '${namespaces_name}/devicessubscribe'
  properties: {
    topicSpaceName: names.topics.devices
    permission: 'Subscriber'
    clientGroupName: names.clientGroups.datasubscribers
  }
  dependsOn:[
    namespace_creation
    namespace_group_telemetry_subscribers
  ]
}

// ********************************************************************************************************************
// * Create topic spaces
// ********************************************************************************************************************
resource namespace_topic_spaces_data 'Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview' = {
  name: '${namespaces_name}/${names.topics.data}'
  properties: {
    topicTemplates: [
      'data/#'
      'data/\${client.authenticationName}/telemetry'
    ]
  }
  dependsOn:[
    namespace_creation
  ]
}

resource namespace_topic_spaces_devices 'Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview' = {
  name: '${namespaces_name}/${names.topics.devices}'
  properties: {
    topicTemplates: [
      'devices/#'
    ]
  }
  dependsOn:[
    namespace_creation
  ]
}

// ********************************************************************************************************************
// * Create clients
// ********************************************************************************************************************

resource namespaces_name_clients 'Microsoft.EventGrid/namespaces/clients@2023-12-15-preview' = [
  for (config, i) in clients: {
    name: '${namespaces_name}/${config.name}'
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
    dependsOn:[
      namespace_creation
    ]
  }
]

output namespace_mqtt_hostname string = namespace_creation.outputs.namespace_resource.properties.topicSpacesConfiguration.hostname
