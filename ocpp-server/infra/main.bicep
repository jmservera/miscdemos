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

var pubsubHostName = '${pubsubARecordName}.${customDnsZoneName}'
var webHostName = '${webARecordName}.${customDnsZoneName}'

// Creates a VNet with 3 subnets: default, gateway and private endpoints
module virtualNetwork './modules/virtualNetwork.bicep' = {
  name: 'vNet'
  params: {
    virtualNetworkName: 'vnet-${uniqueString(resourceGroup().id)}'
  }
}

// creates a private web pub sub service
module webPubSub './modules/webPubSub.bicep' = {
  name: 'webPubSubService'
  params: {
    serviceName: 'webpubsub-${uniqueString(resourceGroup().id)}'
  }
}

module hub './modules/webPubSubHub.bicep' = {
  name: 'webPubSubHub'
  params: {
    serviceName: webPubSub.outputs.serviceName
    hubName: pubSubHubName
    webAppName: webApp.outputs.webSiteName
  }
}

// creates a private endpoint for the web pub sub service
// to be used by the app gateway
module webPubSubPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'webPubSubPrivateEndpoint'
  params: {
    privateLinkResource: webPubSub.outputs.serviceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
    endpointName: 'wssprivate${uniqueString(resourceGroup().id)}'
    targetSubResource: 'webpubsub'
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webAppService'
  params: {
    webAppName: 'webapp-${uniqueString(resourceGroup().id)}'
    sku: 'B1'
    linuxFxVersion: 'DOTNETCORE|8.0'
    pubSubName: webPubSub.outputs.serviceName
    vnetName: virtualNetwork.outputs.vnetName
    subnetName: virtualNetwork.outputs.defaultSubnetName
  }
}

module webPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'webPrivateEndpoint'
  params: {
    privateLinkResource: webApp.outputs.appServiceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
    targetSubResource: 'sites'
    endpointName: 'wwwprivate${uniqueString(resourceGroup().id)}'
  }
}

module appGw './modules/appgw.bicep' = {
  name: 'appGwService'
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

// update A record with appGW public IP
module wssdns './modules/dns.bicep' = if (customDnsZoneName != '') {
  name: 'dnsServicePubSub'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: customDnsZoneName
    aRecordName: pubsubARecordName
    ipTargetResourceId: appGw.outputs.publicIPAddressId
  }
}

module wwwdns './modules/dns.bicep' = if (customDnsZoneName != '') {
  name: 'dnsServiceWeb'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: customDnsZoneName
    aRecordName: webARecordName
    ipTargetResourceId: appGw.outputs.publicIPAddressId
  }
}

module customDomain 'modules/customWebName.bicep' = if (customDnsZoneName != '') {
  name: 'customDomain'
  params: {
    dnszoneName: customDnsZoneName
    dnsZoneRG: dnsZoneRG
    subdomain: 'www'
    customDomainVerificationId: webApp.outputs.customDomainVerificationId
    webSiteName: webApp.outputs.webSiteName
    keyVaultName: keyVaultName
    keyVaultRG: keyVaultRG
    webKeyVaultCertName: webKeyVaultCertName
  }
}
