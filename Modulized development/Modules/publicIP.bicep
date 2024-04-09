param location string
param tags object
// - - - Azure Public IP - - - 
param PublicIpName string
param PublicIpAllocationMethod string
param PublicIpAddressVersion string
param PublicIpSkuName string
param PublicIpSkuTier string

// - - - Create a public IP address for the bastion host - - -
resource createPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: PublicIpName
  tags: tags
  location: location
  properties: {
    publicIPAllocationMethod: PublicIpAllocationMethod
    publicIPAddressVersion: PublicIpAddressVersion
  }
  sku: {
    name: PublicIpSkuName
    tier: PublicIpSkuTier
  }
}

output opPublicIPId string = createPublicIp.id
output opPublicIPAddress string = createPublicIp.properties.ipAddress
