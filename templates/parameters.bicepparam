using 'eventgrid.bicep'

param namespaces_name = 'jmioteventgridns'
param clients = [
  {
    name: 'client1'
    thumbprint: 'd1fb6790f762cc4c5897dc984e7f74518c1b9028b6f849f2af825b856a7e4e09'
    role: 'service'
  }
  {
    name: 'client2'
    thumbprint: '428fc41888ca3007a47d738b740e4e912ddbb7b40978eb1fa1ac003472cf1179'
    role: 'device'
  }
  {
    name: 'client3'
    thumbprint: '9307c2c5204e16e0739e0fa2efe7b5b699875bbf60d5e90ecce1f411cfe4ff68'
    role: 'device'
  }
]
