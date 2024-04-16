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

module eventgrid 'eventgrid.bicep' = {
  name: 'clients'
  params: {
    location: location
    namespaces_name: name_base
    clients: clients
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

output namespace_mqtt_hostname string = eventgrid.outputs.namespace_mqtt_hostname

