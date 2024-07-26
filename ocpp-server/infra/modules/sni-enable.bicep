param appName string
param appHostname string
param certificateThumbprint string

resource appCustomHostEnable 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${appName}/${appHostname}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
