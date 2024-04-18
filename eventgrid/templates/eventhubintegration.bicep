param eventhub_namespace_name string
@minLength(3)
param topic_name string
param eventhub_name string
@description('The name of the Event Grid namespace.')
param eventgrid_name string
param location string

resource eventhub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' existing = {
  name: '${eventhub_namespace_name}/${eventhub_name}'
}

resource eventgrid_topic 'Microsoft.EventGrid/namespaces/topics@2023-12-15-preview' existing = {
  name: '${eventgrid_name}/${topic_name}'
}

// need this trick, routeTopic cannot be set during creation, so we have to "recreate" it again after
// the namespace is created to enable the topic
module eventgrid_namespace 'modules/eventgridinstance.bicep' = {
  name: '${eventgrid_name}_update'
  params: {
    location: location
    namespaces_name: eventgrid_name
    routeTopicResourceId: eventgrid_topic.id // resourceId('Microsoft.EventGrid/namespaces/topics', eventgrid_name, topic_name)
  }
}

@description('This is the built-in Azure Event Hubs Data Sender. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource eventHubsDataSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: eventhub
  name: '2b629674-e913-4c01-ae53-ef4638d8f975' // id for contributor role
}

// Event Grid needs permissions to send messages to the Event Hub, so we use a role assignment
// to grant the Event Grid namespace the built-in Azure Event Hubs Data Sender role.
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: '${eventgrid_name}_eventgrid_sender'
  scope: eventhub
  properties: {
    principalId: eventgrid_namespace.outputs.namespace_resource.identity.principalId
    roleDefinitionId: eventHubsDataSenderRoleDefinition.id
  }
} 


resource eventHubEventSubscription 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2023-12-15-preview' = {
  parent: eventgrid_topic
  name: 'ehsubscription'
  properties: {
    deliveryConfiguration: {
      deliveryMode: 'Push'
      push: {
        maxDeliveryCount: 10
        eventTimeToLive: 'P7D'
        deliveryWithResourceIdentity: {
          identity: {
            type: 'SystemAssigned'
          }
          destination: {
            properties: {
                resourceId: eventhub.id
              deliveryAttributeMappings: []
            }
            endpointType: 'EventHub'
          }
        }
      }
    }
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    filtersConfiguration: {
      includedEventTypes: []
      filters: [
        {
          values: [
            'data/'
          ]
          operatorType: 'StringBeginsWith'
          key: 'subject'
        }
      ]
    }
  }
  dependsOn: [
    eventhub
    roleAssignment
  ]
}
