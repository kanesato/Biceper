param firewallPolicies_poc_hubvnet_fw_standard_policy_name string = 'poc-hubvnet-fw-standard-policy'

resource firewallPolicies_poc_hubvnet_fw_standard_policy_name_resource 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: firewallPolicies_poc_hubvnet_fw_standard_policy_name
  location: 'japaneast'
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
    dnsSettings: {
      servers: [
        '168.63.129.16'
      ]
      enableProxy: true
    }
    snat: {}
  }
}

resource firewallPolicies_poc_hubvnet_fw_standard_policy_name_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicies_poc_hubvnet_fw_standard_policy_name_resource
  name: 'DefaultDnatRuleCollectionGroup'
  location: 'japaneast'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'spk1-windows-1'
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
              '20.222.5.35'
            ]
            destinationPorts: [
              '2000'
            ]
          }
        ]
        name: 'DNAT-rule'
        priority: 1000
      }
    ]
  }
}

resource firewallPolicies_poc_hubvnet_fw_standard_policy_name_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicies_poc_hubvnet_fw_standard_policy_name_resource
  name: 'DefaultNetworkRuleCollectionGroup'
  location: 'japaneast'
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
            name: 'fromSpoke01'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.17.254.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'fromRT2600'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '192.168.4.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '172.17.0.0/16'
              '10.0.0.0/8'
              '172.20.0.0/16'
              '172.18.0.0/16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'fromSpoke02'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.17.250.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'fromSpoke01-02'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.17.255.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'from migrate'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.10.0.0/16'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'from Spoke04'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.17.251.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'spk03-vmware'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.20.0.0/22'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'for - spk05'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.18.0.0/20'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'for-spk06-hpc'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.18.16.0/20'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'network-rule'
        priority: 1000
      }
    ]
  }
}
