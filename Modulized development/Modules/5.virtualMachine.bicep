param location string
param vnetName string
param subnetName string
param vmName string
param vmSize string
param vmComputerName string
param vmOSVersion string
param staticIPaddress string
param storageAccountName string
param tag object
//---------
@secure()
param adminUsername string
@secure()
param adminPassword string

resource tmpSpokeVnet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: vnetName
}

resource tmpSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: subnetName
  parent: tmpSpokeVnet
}

// Create a storage account
resource diagstorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  tags: tag
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Create a network interface in the subnet
resource VmWindowsNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'poc-NIC-${vmName}'
  tags: tag
  location: location
  //dependsOn: [
  //  tmpSubnet
  //]
  properties: {
    ipConfigurations: [
      {
        name: 'poc-NIC-${vmComputerName}'
        properties: {
          subnet: {
            id: tmpSubnet.id
          }
          privateIPAllocationMethod: 'static'
          privateIPAddress: staticIPaddress
        }
      }
    ]
  }
}

// create a virtual machine in the spoke virtual network
resource createVM 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  tags: tag
  location: location
  dependsOn: [
    VmWindowsNic
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftVisualStudio'
        offer: 'Windows'
        sku: vmOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: VmWindowsNic.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagstorageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}


