param webAppName string = 'sidecardemo'

param webAppContainerImageName string = 'composeapp/web:5'
param backendAppContainerImageName string = 'composeapp/backend:5'

param location string = resourceGroup().location

var uniquestring = substring(uniqueString(resourceGroup().id),0,5)
var hostingPlanName = 'ASP-${webAppName}-${uniquestring}'
var registryName = '${webAppName}-${uniquestring}' // The name of your container registry
var uniqueWebName = '${webAppName}-${uniquestring}'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'P1v2' // Specify your SKU here
    tier: 'PremiumV2'
  }
  properties: {
    reserved: true
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard' // You can specify Basic, Standard, or Premium
  }
  properties: {
    adminUserEnabled: false
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: uniqueWebName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.name}.azurecr.io/${webAppContainerImageName}'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'          
        }        
      ]
    }
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(webApp.id, containerRegistry.id, 'acrpull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: webApp.identity.principalId
  }
}


resource sites_jmdockercomposetest_name_backend 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'backend'
  properties: {
    isMain: false
    image: '${containerRegistry.name}.azurecr.io/${backendAppContainerImageName}'
    targetPort: '8080'
    authType: 'SystemIdentity'
    userManagedIdentityClientId: 'SystemIdentity'
  }
  dependsOn: [
    acrPullRoleAssignment
  ]
}

resource sites_jmdockercomposetest_name_main 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'main'
  properties: {
    image: '${containerRegistry.name}.azurecr.io/${webAppContainerImageName}'
    targetPort: '80'
    isMain: true
    authType: 'SystemIdentity'
    userManagedIdentityClientId: 'SystemIdentity'
  }
  dependsOn: [
    acrPullRoleAssignment
  ]
}

resource sites_jmdockercomposetest_name_redis 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'redis'
  properties: {
    image: 'docker.io/redis:alpine'
    targetPort: '6379'
    isMain: false
    authType: 'Anonymous'
  }
}
