param dnszoneName string
param subdomain string = 'www'
param value string

resource dnsZone 'Microsoft.Network/dnszones@2023-07-01-preview' existing = {
  name: dnszoneName
}

resource dnsZoneNewTXTRecord 'Microsoft.Network/dnsZones/TXT@2023-07-01-preview' = {
  parent: dnsZone
  name: subdomain
  properties: {
    TTL: 300
    TXTRecords: [
      {
        value: [value]
      }
    ]
  }
}
