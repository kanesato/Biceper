param location string
param tags object
// - - - AFW Policy - - -
param afwPolicyName string
param afwPolicySKU string
param afwPolicyThreatIntelMode string
param afwPolicyDNSProxyServers array
param afwPolicyEnableDNSProxy bool
param afwDNatdestinationAddresses string
// - - - - - - - - - 
// - - - - - - - - - 
// - - - - - - - - - 
// Create an Azure Firewall Policy
resource createAFWPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' =  {
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

// - - - create a Dnat-rule collection for Azure Firewall policy - - -
// - - - Attach the rule collection to AFW policy - - -
resource createAFW_Policy_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01'  = {
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
              afwDNatdestinationAddresses
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

// - - - Create a network-rule collection for Azure Firewall policy - - -
// - - - Attach the rule collection to AFW policy - - -
resource createAFW_Policy_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01'  = {
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
        // rules: [
        //   {
        //     ruleType: 'NetworkRule'
        //     name: 'SampleNetworkRule'
        //     ipProtocols: [
        //       'Any'
        //       // 'TCP'
        //       // 'UDP'
        //     ]
        //     sourceAddresses: [
        //       '192.168.0.1'
        //     ]
        //     sourceIpGroups: []
        //     destinationAddresses: [
        //       '192.168.0.2'
        //     ]
        //     destinationIpGroups: []
        //     destinationFqdns: []
        //     destinationPorts: [
        //       '1000'
        //     ]
        //   }
        // ]
        name: 'NetworkRule'
        priority: 1000
      }
    ]
  }
}

output opAFWPolicyId string = createAFWPolicy.id
