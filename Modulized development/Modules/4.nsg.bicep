param location string
param nsgName string
param spkvnetName string
param spksubnetName string
param spksubnetipaddress string
param tags object

// 4. Create a NSG and attach it to the subnet in the spoke virtual network
// 4-1. create NSGs for network interfaces
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: nsgName
  tags: tags
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// 4-1. recall the existing spoke virtual network
resource existingspkvnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
 name: spkvnetName
}

// 4-2. recall the create a object of the subnet in the spoke virtual network
resource subnetspk01 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: spksubnetName
  parent: existingspkvnet
}

// 4-3. attach the NSG to the subnet in the spoke virtual network
resource rebuildsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: spksubnetName
  parent: existingspkvnet
  properties: {
    addressPrefix: spksubnetipaddress
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}
