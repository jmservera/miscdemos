// The template to create an app service

param name string = 'app-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param linuxFxVersion string
param identityType string = 'SystemAssigned'
param userAssignedIdentities object = {}
param appServicePlanId string
param appSettings array = []
param corsAllowedOrigins array = []
param tags object = {}


resource appService 'Microsoft.Web/sites@2022-09-01' = {
	name: name
	location: location
	identity: (empty(userAssignedIdentities) ? {
		type: identityType
	} : {
		type: identityType
		userAssignedIdentities: userAssignedIdentities
	})
	properties: {
		serverFarmId: appServicePlanId
		siteConfig: {
			linuxFxVersion: linuxFxVersion
			appSettings: appSettings
			cors: (empty(corsAllowedOrigins) ? null : {
				allowedOrigins: corsAllowedOrigins
			})
			healthCheckPath: '/health'
		}
		httpsOnly: true
	}
	tags: union(tags, { 'azd-service-name': 'web' })
}


output id string = appService.id
output name string = appService.name
output identityPrincipalId string = appService.identity.principalId
output outboundIps string[] = split(appService.properties.outboundIpAddresses, ',')
output requestUrl string = 'https://${appService.properties.defaultHostName}'
