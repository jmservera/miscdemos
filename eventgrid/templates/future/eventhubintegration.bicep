
resource namespaces_name_test_ehsub2 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2023-12-15-preview' = {
  name: '${namespaces_name}/test/ehsub2'
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
                resourceId: evengridsink.id
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
    namespaces_name_test
    namespace_resource
  ]
}

resource namespaces_name_test_grafana 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2023-12-15-preview' = {
  name: '${namespaces_name}/test/grafana'
  properties: {
    deliveryConfiguration: {
      deliveryMode: 'Queue'
      queue: {
        receiveLockDurationInSeconds: 60
        maxDeliveryCount: 10
        eventTimeToLive: 'P7D'
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
    namespaces_name_test
    namespace_resource
  ]
}
