// The bicep template to create an app service plan

param name string = 'plan-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param kind string = 'linux'
param reserved bool = true
param sku string = 'B1'
param tags object = {}


resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
	name: name
	location: location
	kind: kind
	sku: {
		name: sku
	}
	properties: {
		reserved: reserved
	}
	tags: tags
}


output id string = appServicePlan.id
output name string = appServicePlan.name
