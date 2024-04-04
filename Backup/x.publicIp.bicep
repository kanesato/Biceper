param location string
param publicIpName string
param publicIpAllocationMethod string
param publicIpAddressVersion string
param publicIpSkuName string
param publicIpSkuTier string

// Create a public IP address for the bastion host
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    publicIPAddressVersion: publicIpAddressVersion
  }
  sku: {
    name: publicIpSkuName
    tier: publicIpSkuTier
  }
}
