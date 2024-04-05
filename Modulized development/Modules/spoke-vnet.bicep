param location string
param vnetName string
param ipAddressPrefix array
param subnetPrefix1 string
param subnetPrefix2 string
param subnetName1 string
param subnetName2 string
param tags object

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ipAddressPrefix
    }
    subnets: [
      {
        name: subnetName1
        properties: {
          addressPrefix: subnetPrefix1
        }
      }
      {
        name: subnetName2
        properties: {
          addressPrefix: subnetPrefix2
        }
      }
    ]
  }
}

output opSpkVnet object = spokeVnet
output opSpkVnetId string = spokeVnet.id
output opSpkVnetName string = spokeVnet.name
output opSpkVnetPrefix string = spokeVnet.properties.addressSpace.addressPrefixes[0]
output opSpkSubnetName0 string = spokeVnet.properties.subnets[0].name
output opSpkSubnetName1 string = spokeVnet.properties.subnets[1].name
output opSpkSubnetPrefix0 string = spokeVnet.properties.subnets[0].properties.addressPrefix
output opSpkSubnetPrefix1 string = spokeVnet.properties.subnets[1].properties.addressPrefix
