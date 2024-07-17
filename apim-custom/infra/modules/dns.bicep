param dnszoneName string = 'jmservera.online'
param aRecordName string = 'wss'
param aRecordIpv4Address string

resource dnsZone 'Microsoft.Network/dnszones@2023-07-01-preview' existing = {
  name: dnszoneName
}

resource dnsZoneARecord 'Microsoft.Network/dnszones/A@2023-07-01-preview' = {
  parent: dnsZone
  name: aRecordName
  properties: {
    TTL: 300
    ARecords: [
      {
        ipv4Address: aRecordIpv4Address
      }
    ]
  }
}
