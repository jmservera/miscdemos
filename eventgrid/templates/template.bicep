@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('The name of the Event Grid namespace.')
param name_base string = 'jmeventgrid'
@description('An array containing the clients that will be allowed to interact with the Event Grid namespace. Each client must have a name, a thumbprint, and a role. The role can be either "service" or "device".')
param clients array = [
  {
    name: 'name of client'
    thumbprint: 'base64 encoded thumbprint'
    role: 'service or device'
  }
]
param topic_name string = 'test'

module eventgrid 'eventgrid.bicep' = {
  name: 'eventgrid'
  params: {
    location: location
    namespaces_name: name_base
    clients: clients
    custom_topic_name: topic_name
  }
}

module eventhub 'eventhubs.bicep' = {
  name: 'eventhub'
  params: {
    location: location
    eventhub_namespace_name: name_base
    eventhub_name: '${name_base}sink'
  }
}

module eventhubintegration 'eventhubintegration.bicep' = {
  name: 'eventhubintegration'
  params: {
    eventgrid_name: name_base
    eventhub_namespace_name: name_base
    eventhub_name: '${name_base}sink'
    topic_name: topic_name
  }
  dependsOn:[
    eventgrid
    eventhub
  ]
}

output namespace_mqtt_hostname string = eventgrid.outputs.namespace_mqtt_hostname
