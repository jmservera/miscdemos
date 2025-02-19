param appServiceName string
param containerRegistryName string
param webAppContainerImageName string
param backendAppContainerImageName string
param acrPullRoleAssignmentName string

resource webApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceName
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' existing ={
  name: acrPullRoleAssignmentName
}

resource sites_backend 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'backend'
  properties: {
    isMain: false
    image: '${containerRegistryName}.azurecr.io/${backendAppContainerImageName}'
    targetPort: '8080'
    authType: 'SystemIdentity'
    userManagedIdentityClientId: 'SystemIdentity'
  }
  dependsOn: [
    acrPullRoleAssignment
  ]
}

resource sites_main 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'main'
  properties: {
    image: '${containerRegistryName}.azurecr.io/${webAppContainerImageName}'
    targetPort: '80'
    isMain: true
    authType: 'SystemIdentity'
    userManagedIdentityClientId: 'SystemIdentity'
  }
  dependsOn: [
    acrPullRoleAssignment
  ]
}

resource sites_redis 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: webApp
  name: 'redis'
  properties: {
    image: 'docker.io/redis:alpine'
    targetPort: '6379'
    isMain: false
    authType: 'Anonymous'
  }
}
