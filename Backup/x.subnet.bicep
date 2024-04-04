param vnetName string
param subnetName string
param ipAddressPrefix string

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

//create a bastion subnet in the Hub virtual network
resource subnetOfBastion 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetName
  dependsOn: [
    hubVnet
  ]
  parent:hubVnet
  properties: {
    addressPrefix: ipAddressPrefix
  }
}
