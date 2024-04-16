# EventGrid MQTT demo

A simple demo to show how you can use the MQTT characteristics of Azure Event Grid to create an IoT solution.

## Current scope

Using MQTTX we can simulate having three devices. Client1 acts as the service, so it can read all telemetry (data/+/telemetry) and send C2D messages to a single device or to a broadcast topic. Client2 and 3 are devices, so they can subscribe to their own inward message topic and to the devices/all/# topic to receive broadcast messages. Devices can also publish telemetry to the data/{device-id}/telemetry where device-id is the unique login name for the device.

I provide a backup of the current mqttx config and some already created privte test certificates, because I also create them when creating the Event Grid namespace.

## What will be created

* Event Grid namespace: it will enable the MQTT feature
* Event Grid Topic Spaces: 
* Event Grid bindings for establishing permissions to the different types of clients
* MQTT clients, using the thumbprint from the provided certs

## TODO

This example is for creating a full pipeline and demonstrate how to export and visualize real-time data in PowerBI. So we still need to create:

* An Event Hubs namespace
* A topic in Event Grid
* Routing rules for sending the messages to Event Hubs
* A connection between Event Hubs and PowerBI