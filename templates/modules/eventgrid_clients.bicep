param namespaces_name string = 'jmeventgrid'
param clients array = [
  {
    name: 'name of client'
    thumbprint: 'base64 encoded thumbprint'
    role: 'service or device'
  }
]

// resource reference to an existing event grid with namespaces_name
resource namespaces_name_resource 'Microsoft.EventGrid/namespaces@2023-12-15-preview' existing = {
  name: namespaces_name
}

resource namespaces_name_clients 'Microsoft.EventGrid/namespaces/clients@2023-12-15-preview' = [
  for (config, i) in clients: {
    parent: namespaces_name_resource
    name: config.name
    properties: {
      authenticationName: '${config.name}-authn-ID'
      clientCertificateAuthentication: {
        validationScheme: 'ThumbprintMatch'
        allowedThumbprints: [
          config.thumbprint
        ]
      }
      state: 'Enabled'
      attributes: {
        role: config.role
      }
    }
  }
]
