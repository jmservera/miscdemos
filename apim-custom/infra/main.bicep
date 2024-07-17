@secure()
@description('Secret ID for the TLS Certificate stored in Key Vault')
param keyVaultSecretId string
@description('User Assigned Managed Identity name with Get permissions fo the Key Vault Certificate')
param keyVaultIdentityName string
@description('Resource Group name where the User Assigned Managed Identity was created')
param keyVaultIdentityRG string = resourceGroup().name
@description('Custom DNS Zone Name used for publishing the Web PubSub service endpoint securely')
param customDnsZoneName string = 'jmservera.online'
@description('A Record Name for the Web PubSub service endpoint, used as prefix of the DnsZoneName')
param pubsubARecordName string = 'wss'
@description('Resource Group name where the DNS Zone was created')
param dnsZoneRG string = 'domainnames'

var pubsubHostName = '${pubsubARecordName}.${customDnsZoneName}'

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

// creates a private endpoint for the web pub sub service
// to be used by the app gateway
module webPubSubPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'webPubSubPrivateEndpoint'
  params: {
    privateLinkResource: webPubSub.outputs.serviceId
    subnetId: virtualNetwork.outputs.privateSubnetId
    vnetId: virtualNetwork.outputs.vnetId
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webAppService'
  params: {
    webAppName: 'webapp-${uniqueString(resourceGroup().id)}'
    sku: 'F1'
    linuxFxVersion: 'DOTNETCORE|8.0'
  }
}

module appGw './modules/appgw.bicep' = {
  name: 'appGwService'
  params: {
    appgwName: 'appgw-${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    pubSubServiceName: webPubSub.outputs.serviceName
    gwSubnetId: virtualNetwork.outputs.gwSubnetId
    keyVaultSecretId: keyVaultSecretId
    pubsubHostName: pubsubHostName
    keyVaultIdentityName: keyVaultIdentityName
    keyVaultIdentityRG: keyVaultIdentityRG
  }
}

// update A record with appGW public IP
module dns './modules/dns.bicep' = {
  name: 'dnsService'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: customDnsZoneName
    aRecordName: pubsubARecordName
    aRecordIpv4Address: appGw.outputs.publicIPAddress
  }
}
