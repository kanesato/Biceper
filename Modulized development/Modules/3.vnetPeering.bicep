param vnetNameHub string
param vnetNameSpk string
param vnetHubVnetID string
param vnetSpkVnetID string
param hubToSpokePeeringName string
param spokeToHubPeeringName string

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetNameHub
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetNameSpk
}

// Create a virtual network peering from the spoke virtual network to the hub virtual network
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name:  hubToSpokePeeringName
  //dependsOn:[hubVnet, spokeVnet]
  parent: spokeVnet
  properties: {
    remoteVirtualNetwork: {
      id: vnetHubVnetID
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

// Create a virtual network peering from the hub virtual network to the spoke virtual network
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name:   spokeToHubPeeringName
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: vnetSpkVnetID
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}
