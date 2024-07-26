param dnszoneName string
param dnsZoneRG string
param subdomain string = 'www'
param webSiteName string
param keyVaultName string
param keyVaultRG string
param webKeyVaultCertName string
param location string = resourceGroup().location

var fqdn = '${subdomain}.${dnszoneName}'

resource site 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webSiteName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultRG)
}

resource webKeyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  name: webKeyVaultCertName
  parent: keyVault
}

// Add a TXT record to the DNS zone to verify the custom domain
module verification 'dnstxt.bicep' = {
  name: 'dnsServiceWebTxt'
  scope: resourceGroup(dnsZoneRG)
  params: {
    dnszoneName: dnszoneName
    subdomain: 'asuid.${fqdn}'
    value: site.properties.customDomainVerificationId
  }
}

// Enabling Managed certificate for a webapp requires 3 steps
// 1. Add custom domain to webapp with SSL in disabled state
// 2. Upload certificate for the domain
// 3. enable SSL
//
// The last step requires deploying again Microsoft.Web/sites/hostNameBindings - and ARM template forbids this in one deplyment, therefore we need to use modules to chain this.

resource appCustomHost 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: fqdn
  parent: site
  dependsOn: [verification]
  properties: {
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    siteName: site.name
  }
}

resource appCustomHostCertificate 'Microsoft.Web/certificates@2020-06-01' = {
  name: fqdn
  location: location
  dependsOn: [appCustomHost]
  properties: any({
    keyVaultId: keyVault.id
    keyVaultSecretName: webKeyVaultCertificate.name
    serverFarmId: site.properties.serverFarmId
  })
}

// we need to use a module to enable sni, as ARM forbids using resource with this same type-name combination twice in one deployment.
module appCustomHostEnable './sni-enable.bicep' = {
  name: '${deployment().name}-${fqdn}-sni-enable'
  params: {
    appName: site.name
    appHostname: appCustomHostCertificate.name
    certificateThumbprint: appCustomHostCertificate.properties.thumbprint
  }
}
