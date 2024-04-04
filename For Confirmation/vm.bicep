


// 5-3. deploy virtual machines (Loop for 3 times)
resource createVM 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'poc-vm-windows-01'
  tags: 'poc'
  location: 'japaneast'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D5v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftVisualStudio'
        offer: 'Windows'
        sku: vmOSVersionad
        version: 'latest'
        diskcontrollerType: 'NVMe'
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
      computerName: 'poc-vm-windows-osprofile-name'
      adminUsername: 'adminuser'
      adminPassword: 'Rduaain08180422'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmWindowsNic[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagstorageAccount[i].properties.primaryEndpoints.blob
      }
    }
  }
}]
