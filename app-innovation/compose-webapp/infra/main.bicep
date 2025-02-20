targetScope = 'subscription'

param location string = 'swedencentral'
param environmentName string = 'myenv'
@allowed([
  'development'
  'staging'
  'production'
])
param environmentType string = 'development'
param resourceGroupName string = 'rg-myenv'
param resourceToken string = toLower(uniqueString(subscription().id, location, resourceGroupName))
param projectName string = 'composeapp'

param webAppContainerImageName string = 'composeapp/web:5'
param backendAppContainerImageName string = 'composeapp/backend:5'


var appServicePlanName = 'ASP-${environmentName}-${resourceToken}'
var registryName = '${environmentName}${resourceToken}'
var uniqueWebName = '${environmentName}${resourceToken}'

param tags object = {
  environment: environmentType
  project: projectName
  'azd-env-name': environmentName
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
	name: resourceGroupName
	location: location
	tags: tags
}

module appServicePlan 'appserviceplan.bicep' = {
	name: 'app-service-plan-deployment'
	scope: resourceGroup
	params: {
		location: location
		name: appServicePlanName
	}
}
var appServicePlanId = appServicePlan.outputs.id

module containerRegistry 'containerregistry.bicep' = {
  name: 'container-registry-deployment'
  scope: resourceGroup
  params: {
    location: location
    registryName: registryName
    sku: 'Standard'
    tags: tags
  }
}

module appservice 'appservice.bicep' = {
  name: 'app-service-deployment'
  scope: resourceGroup
  params: {
    location: location
    name: uniqueWebName
    appServicePlanId: appServicePlanId
    identityType: 'SystemAssigned'
    tags: {'azd-service-name': 'web'}
    linuxFxVersion: 'sitecontainers'
  }
}


module containerRegistryPull 'containerRegistryPullRole.bicep' = {
  name: 'container-registry-pull-deployment'
  scope: resourceGroup
  params: {
    webAppName: appservice.outputs.name
    containerRegistryName: containerRegistry.outputs.name
  }
}

module apps 'appservice.apps.bicep' = {
  name: 'app-service-apps-deployment'
  scope: resourceGroup
  params: {
    appServiceName: appservice.outputs.name
    containerRegistryName: containerRegistry.outputs.name
    webAppContainerImageName: webAppContainerImageName
    backendAppContainerImageName: backendAppContainerImageName
    acrPullRoleAssignmentName: containerRegistryPull.outputs.name
  }
}

output webAppName string = appservice.outputs.name
output containerRegistryName string = containerRegistry.outputs.name
output webAppContainerImageName string = webAppContainerImageName
output backendAppContainerImageName string = backendAppContainerImageName
output resourceGroupName string = resourceGroupName
output location string = location
output serviceUrl string = appservice.outputs.requestUrl
