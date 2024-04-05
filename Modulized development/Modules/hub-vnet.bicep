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

output opHubVnetId string = hubVnet.id
output opHubVnetName string = hubVnet.name
output opHubVnetGatawaySubnetName string = hubVnet.properties.subnets[0].name
output opHubVnetFirewallSubnetName string = hubVnet.properties.subnets[1].name
output opHubVnetBastionSubnetName string = hubVnet.properties.subnets[2].name
output opHubVnetSubnet01Name string = hubVnet.properties.subnets[3].name
output opHubVnetSubnet02Name string = hubVnet.properties.subnets[4].name
output opHubVnetGatawaySubnetId string = hubVnet.properties.subnets[0].id
output opHubVnetFirewallSubnetId string = hubVnet.properties.subnets[1].id
output opHubVnetBastionSubnetId string = hubVnet.properties.subnets[2].id
output opHubVnetSubnet01Id string = hubVnet.properties.subnets[3].id
output opHubVnetSubnet02Id string = hubVnet.properties.subnets[4].id
