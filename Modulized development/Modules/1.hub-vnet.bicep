param location string
param vnetName string
param ipAddressPrefixes array
param subnetGatewayPrefix string
param subnetFirewallPrefix string
param subnetBastionPrefix string
param subnetName01 string
param subnetPrefix01 string
param subnetName02 string
param subnetPrefix02 string
param tags object

// Create a hub virtual network
resource hubVnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ipAddressPrefixes
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: subnetGatewayPrefix
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: subnetFirewallPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: subnetBastionPrefix
        
        }
      }
      {
        name: subnetName01
        properties: {
          addressPrefix: subnetPrefix01
        }
      }
      {
        name: subnetName02
        properties: {
          addressPrefix: subnetPrefix02
        }
      }
    ]
  }
}

output ophubVnetId string = hubVnet.id
output ophubVnetName string = hubVnet.name
