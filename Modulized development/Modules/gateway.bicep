
param location string
param tags object
param existingHubVNetName string
param existingGatewaySubnetName string
param gatewayPublicIpName string
@secure()
param gatewayPublicIpAllocationMethod string
@secure()
param gatewayPublicIpAddressVersion string
@secure()
param gatewayPublicIpSkuName string
@secure()
param gatewayPublicIpSkuTier string
param vpnGatewayName string
param HubVNetGatewaySubnetId string


// - - - create a vpn gateway in the hub virtual network - - -
resource existingHubVNet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existingHubVNetName
}

resource existingGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: existingHubVNet
  name: existingGatewaySubnetName
}

// - - - Create a public IP address for the bastion host - - -
resource createGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: gatewayPublicIpName
  tags: tags
  location: location
  properties: {
    publicIPAllocationMethod: gatewayPublicIpAllocationMethod
    publicIPAddressVersion: gatewayPublicIpAddressVersion
  }
  sku: {
    name: gatewayPublicIpSkuName
    tier: gatewayPublicIpSkuTier
  }
}

resource createVPNGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: vpnGatewayName
  location: location
  dependsOn: [
    existingHubVNet
    existingGatewaySubnet
    createGatewayPublicIp
  ]
  properties: {
    enablePrivateIpAddress: false
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'Generation1'
    allowRemoteVnetTraffic: false
    allowVirtualWanTraffic: false
    ipConfigurations: [
      {
        name: 'default'
        // id: '${createVPNGateway.id}/ipConfigurations/default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: createGatewayPublicIp.id
          }
          subnet: {
            id: HubVNetGatewaySubnetId
          }
        }
      }
    ]
    // bgpSettings: {
    //   asn: 65515
    //   bgpPeeringAddress: '172.17.255.30'
    //   peerWeight: 0
    //   bgpPeeringAddresses: [
    //     {
    //       ipconfigurationId: '${virtualNetworkGateways_self_s2s_vpngw_name_resource.id}/ipConfigurations/default'
    //       customBgpIpAddresses: []
    //     }
    //   ]
    // }
  }
}
