@secure()
@description('Name of the TLS Certificate stored in Key Vault for the pubsub service public endpoint')
param pubsubKeyVaultCertName string
@description('Name of the TLS Certificate stored in Key Vault for the web service public endpoint')
param webKeyVaultCertName string
@description('Name of the Key Vault where the certificates are stored')
param keyVaultName string
@description('Resource Group name where the Key Vault was created')
param keyVaultRG string
@description('User Assigned Managed Identity name with Get permissions fo the Key Vault Certificate')
param keyVaultIdentityName string
@description('Resource Group name where the User Assigned Managed Identity was created')
param keyVaultIdentityRG string = keyVaultRG
@description('Custom DNS Zone Name used for publishing the Web PubSub service endpoint securely')
param customDnsZoneName string
@description('A Record Name for the Web PubSub service endpoint, used as prefix of the DnsZoneName')
param pubsubARecordName string = 'wss'
@description('A Record Name for the Web service endpoint, used as prefix of the DnsZoneName')
param webARecordName string = 'www'
@description('Resource Group name where the DNS Zone was created')
param dnsZoneRG string
@description('The name for your new Web PubSub Hub. It should be the same name than the class implementing it in the asp.net core project')
param pubSubHubName string = 'OcppService'
@description('If you want to use a NAT Gateway for the outbound access of the vNet')
param useNATGateway bool = false

var pubsubHostName = '${pubsubARecordName}.${customDnsZoneName}'
var webHostName = '${webARecordName}.${customDnsZoneName}'

// A Nat Gateway for controlling the outbound access of the vNet
module natgw './modules/natgw.bicep' = if (useNATGateway) {
  name: '${deployment().name}-natGwService'
  params: {
    natGwName: 'natgw-${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
  }
}

// Creates a VNet with 3 subnets: default, gateway and private endpoints
// Inside the default subnet, the web app will be deployed
module virtualNetwork './modules/virtualNetwork.bicep' = {
  name: '${deployment().name}-vNet'
  params: {
    virtualNetworkName: 'vnet-${uniqueString(resourceGroup().id)}'
    natGatewayId: useNATGateway ? natgw.outputs.natGatewayId : ''
  }
}

// creates the Web PubSub service
module webPubSub './modules/webPubSub.bicep' = {
  name: '${deployment().name}-webPubSubService'
  params: {
    serviceName: 'webpubsub-${uniqueString(resourceGroup().id)}'
  }
}

// creates a private endpoint for the web pub sub service
// to be used by the app gateway
module webPubSubPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: '${deployment().name}-webPubSubPrivateEndpoint'
  params: {
    privateLinkResource: webPubSub.outputs.serviceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
    endpointName: 'wssprivate${uniqueString(resourceGroup().id)}'
    targetSubResource: 'webpubsub'
  }
}

// Creates the Web PubSub Hub, you can use the module to create more hubs
module hub './modules/webPubSubHub.bicep' = {
  name: '${deployment().name}-webPubSubHub'
  params: {
    serviceName: webPubSub.outputs.serviceName
    hubName: pubSubHubName
    webAppName: webApp.outputs.webSiteName
  }
}

// Creates the web app service
module webApp './modules/webapp.bicep' = {
  name: '${deployment().name}-webAppService'
  params: {
    webAppName: 'webapp-${uniqueString(resourceGroup().id)}'
    sku: 'B1'
    linuxFxVersion: 'DOTNETCORE|8.0'
    pubSubName: webPubSub.outputs.serviceName
    vnetName: virtualNetwork.outputs.vnetName
    subnetName: virtualNetwork.outputs.defaultSubnetName
    keyVaultIdentityName: keyVaultIdentityName
    keyVaultIdentityRG: keyVaultIdentityRG
  }
}

// Assigns the custom web domain to the web app, this ensures
// that the cookies are set with the custom domain and do not
// have any issue with the Application Gateway cookie based affinity
module customDomain 'modules/customWebName.bicep' = if (customDnsZoneName != '') {
  name: '${deployment().name}-customDomain'
  params: {
    dnszoneName: customDnsZoneName
    dnsZoneRG: dnsZoneRG
    subdomain: webARecordName
    webSiteName: webApp.outputs.webSiteName
    keyVaultName: keyVaultName
    keyVaultRG: keyVaultRG
    webKeyVaultCertName: webKeyVaultCertName
  }
}

// Creates a private endpoint for the web app, used by the App Gateway
module webPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: '${deployment().name}-webPrivateEndpoint'
  params: {
    privateLinkResource: webApp.outputs.appServiceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
    targetSubResource: 'sites'
    endpointName: 'wwwprivate${uniqueString(resourceGroup().id)}'
  }
}

// Creates a private endpoint for the storage account of the web app, used by the Web App
module storagePrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: '${deployment().name}-webStoragePrivateEndpoint'
  params: {
    privateLinkResource: webApp.outputs.storageAccountId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
    targetSubResource: 'blob'
    endpointName: 'webStoragePrivate${uniqueString(resourceGroup().id)}'
  }
}

// Creates the App Gateway to serve the web app and web pubsub service endpoints
module appGw './modules/appgw.bicep' = {
  name: '${deployment().name}-appGwService'
  params: {
    appgwName: 'appgw-${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    pubSubServiceName: webPubSub.outputs.serviceName
    gwSubnetId: virtualNetwork.outputs.gwSubnetId
    webKeyVaultCertName: webKeyVaultCertName
    pubsubKeyVaultCertName: pubsubKeyVaultCertName
    webHostName: webHostName
    pubsubHostName: pubsubHostName
    keyVaultName: keyVaultName
    keyVaultRG: keyVaultRG
    keyVaultIdentityName: keyVaultIdentityName
    keyVaultIdentityRG: keyVaultIdentityRG
    webServiceName: webApp.outputs.webSiteName
    pubsubHubName: pubSubHubName
  }
}

// Finally, we need to update the A records with appGW public IP
module wssdns './modules/dns.bicep' = if (customDnsZoneName != '') {
  name: '${deployment().name}-dnsServicePubSub'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: customDnsZoneName
    aRecordName: pubsubARecordName
    ipTargetResourceId: appGw.outputs.publicIPAddressId
  }
}

module wwwdns './modules/dns.bicep' = if (customDnsZoneName != '') {
  name: '${deployment().name}-dnsServiceWeb'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: customDnsZoneName
    aRecordName: webARecordName
    ipTargetResourceId: appGw.outputs.publicIPAddressId
  }
}
