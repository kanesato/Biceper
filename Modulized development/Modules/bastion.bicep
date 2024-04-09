param location string
param tags object
param bastionName string
param bastionSubnetID string
param bastionPublicIPID string
param bastionSKU string


//create a bastion host in the bastion subnet
resource createBastion 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionName
  tags: tags
  location: location
  sku: {
    name: bastionSKU
  }
  properties: {
    disableCopyPaste: false
    enableFileCopy: true
    enableIpConnect: false
    enableKerberos: false
    enableShareableLink: true
    enableTunneling: false
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: bastionSubnetID
          }
          publicIPAddress: {
            id: bastionPublicIPID
          }
        }
      }
    ]
  }
}

output opBastionName string = createBastion.name
output opBastionId string = createBastion.id
