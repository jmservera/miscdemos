param location string = resourceGroup().location
param namePrefix string = 'appDemo'
param sqlAdminLogin string = 'sqladmin'
@secure()
param sqlAdminPassword string

// Virtual network with two subnets
module vnet './modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

// Frontend web app with public access
module frontEndApp './modules/webApp.bicep' = {
  name: 'frontEndApp'
  params: {
    name: '${namePrefix}-frontend'
    location: location
    planName: '${namePrefix}-frontPlan'
    skuName: 'S1'
    skuTier: 'Standard'
    publicNetworkAccess: 'Enabled'
  }
}

// Backend web app with private access
module backEndApp './modules/webApp.bicep' = {
  name: 'backEndApp'
  params: {
    name: '${namePrefix}-backend'
    location: location
    planName: '${namePrefix}-backPlan'
    skuName: 'S1'
    skuTier: 'Standard'
    publicNetworkAccess: 'Disabled'
  }
}

// Private endpoint for backend
module backEndPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'backEndPrivateEndpoint'
  params: {
    name: '${namePrefix}-backend'
    location: location
    vnetId: vnet.outputs.vnetId
    subnetId: vnet.outputs.appSubnetId
    privateLinkServiceId: backEndApp.outputs.id
    targetSubResource: 'sites'
  }
}

// SQL Database
module sqlDb './modules/sqlDatabase.bicep' = {
  name: 'sqlDb'
  params: {
    serverName: '${namePrefix}-sqlserver'
    databaseName: '${namePrefix}-db'
    location: location
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
  }
}

// Private endpoint for SQL
module sqlPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'sqlPrivateEndpoint'
  params: {
    name: '${namePrefix}-sql'
    location: location
    subnetId: vnet.outputs.privateSubnetId
    vnetId: vnet.outputs.vnetId
    privateLinkServiceId: sqlDb.outputs.serverId
    targetSubResource: 'sqlServer'
  }
}

// Output important values
output frontendUrl string = frontEndApp.outputs.url
output frontendId string = frontEndApp.outputs.id
output backendId string = backEndApp.outputs.id
output sqlServerId string = sqlDb.outputs.serverId
