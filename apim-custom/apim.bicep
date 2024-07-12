param apimName string = 'apim-${uniqueString(resourceGroup().id)}'
param publisherName string = 'Your Publisher Name'
param publisherEmail string = 'publisher@example.com'
param skuName string = 'Developer' // Change SKU as needed: Developer, Basic, Standard, Premium
param skuCapacity int = 1

resource apimService 'Microsoft.ApiManagement/service@2021-04-01-preview' = {
  name: apimName
  location: resourceGroup().location
  sku: {
	name: skuName
	capacity: skuCapacity
  }
  properties: {
	publisherEmail: publisherEmail
	publisherName: publisherName
  }
}

output apimServiceName string = apimService.name
output apimServiceId string = apimService.id
