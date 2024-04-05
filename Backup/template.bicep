param azureFirewalls_self_s2s_hub_firwall_name string = 'self-s2s-hub-firwall'
param publicIPAddresses_self_hubvnet_firewall_pip_externalid string = '/subscriptions/d8df623a-79c2-47ca-8542-9fdc6d9942e2/resourceGroups/self-s2s-hub-resourcegroup/providers/Microsoft.Network/publicIPAddresses/self-hubvnet-firewall-pip'
param virtualNetworks_self_s2s_hub_vnet_externalid string = '/subscriptions/d8df623a-79c2-47ca-8542-9fdc6d9942e2/resourceGroups/self-s2s-hub-resourcegroup/providers/Microsoft.Network/virtualNetworks/self-s2s-hub-vnet'
param publicIPAddresses_self_afw_publicip_02_externalid string = '/subscriptions/d8df623a-79c2-47ca-8542-9fdc6d9942e2/resourceGroups/self-s2s-hub-resourcegroup/providers/Microsoft.Network/publicIPAddresses/self-afw-publicip-02'
param firewallPolicies_poc_hubvnet_fw_standard_policy_externalid string = '/subscriptions/d8df623a-79c2-47ca-8542-9fdc6d9942e2/resourceGroups/self-s2s-hub-resourcegroup/providers/Microsoft.Network/firewallPolicies/poc-hubvnet-fw-standard-policy'

resource azureFirewalls_self_s2s_hub_firwall_name_resource 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: azureFirewalls_self_s2s_hub_firwall_name
  location: 'japaneast'
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    additionalProperties: {}
    ipConfigurations: [
      {
        name: 'self-hubvnet-firewall-pip'
        id: '${azureFirewalls_self_s2s_hub_firwall_name_resource.id}/azureFirewallIpConfigurations/self-hubvnet-firewall-pip'
        properties: {
          publicIPAddress: {
            id: publicIPAddresses_self_hubvnet_firewall_pip_externalid
          }
          subnet: {
            id: '${virtualNetworks_self_s2s_hub_vnet_externalid}/subnets/AzureFirewallSubnet'
          }
        }
      }
      {
        name: 'self-hubvnet-firewall-pip2'
        id: '${azureFirewalls_self_s2s_hub_firwall_name_resource.id}/azureFirewallIpConfigurations/self-hubvnet-firewall-pip2'
        properties: {
          publicIPAddress: {
            id: publicIPAddresses_self_afw_publicip_02_externalid
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: firewallPolicies_poc_hubvnet_fw_standard_policy_externalid
    }
  }
}
