param dnszoneName string
param aRecordName string = 'wss'
param ipTargetResourceId string

resource dnsZone 'Microsoft.Network/dnszones@2023-07-01-preview' existing = {
  name: dnszoneName
}

resource dnsZoneARecord 'Microsoft.Network/dnszones/A@2023-07-01-preview' = {
  parent: dnsZone
  name: aRecordName
  properties: {
    TTL: 300
    targetResource: {
      id: ipTargetResourceId
    }
  }
}
