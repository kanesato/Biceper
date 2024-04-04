param tag object
param location string
param vnetName string
param subnetName string
param vmName string
param vmSize string
param vmComputerName string
param vmOSVersion string
param staticIPaddress string
param storageAccountUri string
param storageAccountID string
param storageAccountName string
@secure()
param storageAccountKey string
param storageAccountEndPoint string
//---------
@secure()
param adminUsername string
@secure()
param adminPassword string
//=========
var wadlogs = '<WadCfg> <DiagnosticMonitorConfiguration overallQuotaInMB="4096" xmlns="http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter="Error"/> <WindowsEventLog scheduledTransferPeriod="PT1M" > <DataSource name="Application!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="Security!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="System!*[System[(Level = 1 or Level = 2)]]" /></WindowsEventLog>'
var wadperfcounters1 = '<PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Processor Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU utilization" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Privileged Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU privileged time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% User Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor Information(_Total)\\Processor Frequency" sampleRate="PT15S" unit="Count"><annotation displayName="CPU frequency" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\System\\Processes" sampleRate="PT15S" unit="Count"><annotation displayName="Processes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Thread Count" sampleRate="PT15S" unit="Count"><annotation displayName="Threads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Handle Count" sampleRate="PT15S" unit="Count"><annotation displayName="Handles" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\% Committed Bytes In Use" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory usage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Available Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Committed Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory committed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Commit Limit" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory commit limit" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active time" locale="en-us"/></PerformanceCounterConfiguration>'
var wadperfcounters2 = '<PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Read Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Write Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Transfers/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Reads/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk read operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Writes/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk write operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Read Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Write Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\LogicalDisk(_Total)\\% Free Space" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk free space (percentage)" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters>'
var wadcfgxstart = '${wadlogs}${wadperfcounters1}${wadperfcounters2}<Metrics resourceId="'
var wadcfgxend = '"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'

//---------
resource tmpSpokeVnet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: vnetName
}

resource tmpSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: subnetName
  parent: tmpSpokeVnet
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
        storageUri: storageAccountUri
      }
    }
  }
}

resource virtualMachines_self_spoke01_windows_02_vm_name_Microsoft_Insights_VMDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: createVM
  name: 'vmdiagnosticsSettings'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.5'
    settings: {
      StorageAccountID: storageAccountID
      xmlCfg: base64(concat(wadcfgxstart, storageAccountID, wadcfgxend))
    }
    protectedSettings: {
      storageAccountName: storageAccountName
      storageAccountKey: storageAccountKey
      storageAccountEndPoint: storageAccountEndPoint
    }
  }
}
