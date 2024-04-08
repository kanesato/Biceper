param location string
param tags object
param afwMainPartName string
param afwTier string
param afwThreatIntelMode string
param afwIPConfigurationId string
param afwPublicIPId string
param afwSubnetId string
param afwPolicyId string



// - - - Create an Azure Firewall - - - 
resource createAzureFirewalls 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: afwMainPartName
  location: location
  tags:tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: afwTier
    }
    threatIntelMode: afwThreatIntelMode
    additionalProperties: {}
    ipConfigurations: [
      {
        name: 'self-hubvnet-firewall-pip'
        id: 'dddddddd-dddd-dddd-dddd'
        properties: {
          publicIPAddress: {
            id: afwPublicIPId
          }
          subnet: {
            id: afwSubnetId
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: afwPolicyId
    }
  }
}
