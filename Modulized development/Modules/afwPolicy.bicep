param location string
param tags object
param RunAFWPolicy bool
param RunAFWMainPart bool
// - - - AFW Policy - - -
param afwPolicyName string
param afwPolicySKU string
param afwPolicyThreatIntelMode string
param afwPolicyDNSProxyServers array
param afwPolicyEnableDNSProxy bool
// - - - Azure Public IP - - - 
param afwPublicIpName string
param afwPublicIpAllocationMethod string
param afwPublicIpAddressVersion string
param afwPublicIpSkuName string
param afwPublicIpSkuTier string

// - - - Create a public IP address for the bastion host - - -
resource createAFWPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if(RunAFWMainPart) {
  name: afwPublicIpName
  tags: tags
  location: location
  properties: {
    publicIPAllocationMethod: afwPublicIpAllocationMethod
    publicIPAddressVersion: afwPublicIpAddressVersion
  }
  sku: {
    name: afwPublicIpSkuName
    tier: afwPublicIpSkuTier
  }
}
// - - - - - - - - - 
// - - - - - - - - - 
// - - - - - - - - - 
// Create an Azure Firewall Policy
resource createAFWPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = if (RunAFWPolicy) {
  name: afwPolicyName
  tags: tags
  location: location
  properties: {
    sku: {
      tier: afwPolicySKU
    }
    threatIntelMode: afwPolicyThreatIntelMode
    // threatIntelWhitelist: {
    //   fqdns: []
    //   ipAddresses: []
    // }
    dnsSettings: {
      servers: afwPolicyDNSProxyServers
      enableProxy: afwPolicyEnableDNSProxy
    }
    snat: {}
  }
}

resource createAFW_Policy_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01'  = if (RunAFWPolicy) {
  parent: createAFWPolicy
  dependsOn: [
    createAFWPolicy
  ]
  name: 'DefaultDnatRuleCollectionGroup'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        name: 'DnatRule'
        priority: 1000
        rules: [
          {
            ruleType: 'NatRule'
            name: 'SampleDnatRule'
            translatedAddress: '172.17.254.4'
            translatedPort: '3389'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              createAFWPublicIp.properties.ipAddress
            ]
            destinationPorts: [
              '2000'
            ]
          }
        ]
      }
    ]
  }
}

resource createAFW_Policy_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01'  = if (RunAFWPolicy)  {
  parent: createAFWPolicy
  dependsOn: [
    createAFWPolicy
    createAFW_Policy_DefaultDnatRuleCollectionGroup
  ]
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'SampleNetworkRule'
            ipProtocols: [
              'Any'
              // 'TCP'
              // 'UDP'
            ]
            sourceAddresses: [
              '192.168.0.1'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '192.168.0.2'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '1000'
            ]
          }
        ]
        name: 'NetworkRule'
        priority: 1000
      }
    ]
  }
}

output opAFWPublicIPId string = createAFWPublicIp.id
output opAFWPolicyId string = createAFWPolicy.id
