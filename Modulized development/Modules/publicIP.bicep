param location string
param tags object
// - - - Azure Public IP - - - 
param publicIPName string
param publicIPAllocationMethod string
param publicIPAddressVersion string
param publicIPSkuName string
param publicIPSkuTier string

// - - - Create a public IP address for the bastion host - - -
resource createPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPName
  tags: tags
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: publicIPAddressVersion
  }
  sku: {
    name: publicIPSkuName
    tier: publicIPSkuTier
  }
}

output opPublicIPId string = createPublicIP.id
output opPublicIPAddress string = createPublicIP.properties.ipAddress
