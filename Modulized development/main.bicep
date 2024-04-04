// - - - preconditions - - - 
// - - - - - - - - - - - - -
//All resources will be deployed in resource group "Bicep-fundermental-resourcegroup"
//location will be inherited from the resource group
// - - - - - - - - - - - - -
// - - - - - - - - - - - - -
// - - - Paremeters defination - - - 
@description('Parameter for location')
param location string = resourceGroup().location

// - - - - - - - - - 
@description('Parameters for Hub Virtual Network')
var vnetNameHub = 'Private-HubVnet'
param ipAddressPrefixHub array = ['10.10.0.0/16']
param subnetGatewayPrefix string = '10.10.0.0/26'
param subnetFirewallPrefix string = '10.10.0.64/26'
param subnetBastionPrefix  string = '10.10.0.128/25'
param subnetName01  string = 'PrivateHVnet-Subnet01'
param subnetPrefix01 string = '10.10.1.0/24'
param subnetName02  string = 'PrivateHVnet-Subnet02'
param subnetPrefix02 string = '10.10.2.0/24'

// - - - Spoke Virtual Network - - - 
@description('Parameters for Spoke Virtual Network')
var vnetNameSpk = 'poc-Spk-Vnet-01'
param ipAddressPrefixSpk array = ['10.1.0.0/16']
var subnetName1Spk = 'poc-spk01-subnet01'
var subnetName2Spk = 'poc-spk01-subnet02'
param ipAddressPrefixSpk01Subnet01 string = '10.1.0.0/24'
param ipAddressPrefixSpk01Subnet02 string = '10.1.1.0/24'
// - - - Virtual Machine - - -
@description('Parameters for Virtual Machine1')
var vmName = ['poc-VM-01','poc-VM-02','poc-VM-03']
var vmSize = 'Standard_B2s'
@secure()
param adun string = 'adminuser'
@secure()
param adps string = 'P@ssw0rd1234'

var vmComputerName = ['poc-vm-01','poc-vm-02','poc-vm-03']
var vmOSVersion = 'Windows-10-N-x64'
var vmIndex = [0,1,2]
param staticIPaddress array = ['10.1.0.10', '10.1.0.11', '10.1.0.12']
// - - - SQL Server - - -
@description('Parameters for SQL Server')
var sqlServerName = 'poc${uniqueString(resourceGroup().id,deployment().name)}'
var sqlDatabaseName = 'pocbicepsqldatabase'

@secure()
param sqlLoginId string = 'adminuser'
@secure()
param sqlLoginPassword string = 'Rduaain08180422'
// - - - Public IP(Bastion) - - -
@description('Parameters for Public IP(Bastion)')
var publicIpName = 'poc-Bastion-PublicIP'
var publicIpAllocationMethod = 'Static'
var publicIpAddressVersion = 'IPv4'
var publicIpSkuName = 'Standard'
var publicIpSkuTier = 'Regional'
// - - - Bastion - - -
@description('Parameters for Bastion')
var bastionSubnetName = 'AzureBastionSubnet'
param ipAddressPrefixBastionSubnet string = '10.0.0.0/26'
var bastionName = 'poc-Bastion-Hub'
// - - - Storage Account - - -
@description('Parameters for Storage Account')
var storageAccountName = 'poc${uniqueString(resourceGroup().id,deployment().name)}'
// - - - Log Analytics - - -
// @description('Parameters for Log Analytics')
// param logAnalyticsWorkspace string = 'poc-${uniqueString(resourceGroup().id,deployment().name,location)}'
// - - - Tags - - -
@description('Parameters for tags')
param tags object = {
  environment: 'poc'
  department: 'Infra'
  project: 'HINO'
}

// - - - Boolean for engaging deployment - - -
// - - - true: engage / false; not engage - - -
@description('Booleans for engaging deployment')
param RunHubVnet bool = true
param RunSpokeVnet1 bool = true
param RunSpokeVnet2 bool = true
param RunNSG bool = false
param RunVM bool = false
param RunSQLServer bool = false
param RunBastion bool = false
//-------
//-------
//------- Program starts here -------

// 1. Create a hub virtual network
module createHubVNet './modules/1.hub-vnet.bicep' = if (RunHubVnet) {
  name: 'createHubVnet'
  params: {
    tags: tags
    location: location
    vnetName: vnetNameHub
    ipAddressPrefixes: ipAddressPrefixHub
    subnetGatewayPrefix: subnetGatewayPrefix
    subnetFirewallPrefix:subnetFirewallPrefix
    subnetBastionPrefix :subnetBastionPrefix
    subnetName01 :subnetName01
    subnetPrefix01: subnetPrefix01
    subnetName02 :subnetName02
    subnetPrefix02:subnetPrefix02
  }
}

// 2. Create the first spoke virtual network
module createSpokeVNet1 './modules/2.spoke-vnet.bicep' = if(RunSpokeVnet1) {
  name: 'createSpokeVnet1'
  params: {
    tags: tags
    location: location
    vnetName: 'hino-Spk-Vnet-01'
    ipAddressPrefix: ['10.20.0.0/16']
    subnetName1: 'hino-spk1-subnet01'
    subnetName2: 'hino-spk1-subnet02'
    subnetPrefix1: '10.20.0.0/24'
    subnetPrefix2: '10.20.1.0/24'
  }
}

// 3. Create the second spoke virtual network
module createSpokeVNet2 './modules/2.spoke-vnet.bicep' = if(RunSpokeVnet2) {
  name: 'createSpokeVnet2'
  params: {
    tags: tags
    location: location
    vnetName: 'hino-Spk-Vnet-02'
    ipAddressPrefix: ['10.21.0.0/16']
    subnetName1: 'hino-spk2-subnet01'
    subnetName2: 'hino-spk2-subnet02'
    subnetPrefix1: '10.21.0.0/24'
    subnetPrefix2: '10.21.1.0/24'
  }
}

// 4. Create a virtual network peering between the hub and spoke virtual networks
module createVNetPeering1 './modules/3.vnetPeering.bicep' = if(RunSpokeVnet1) {
  name: 'createVnetPeering1'
  dependsOn: [
    createHubVNet
    createSpokeVNet1
  ]
  params: {
    vnetNameHub: createHubVNet.outputs.ophubVnetName
    vnetNameSpk: createSpokeVNet1.outputs.opSpkVnetName
    vnetHubVnetID:createHubVNet.outputs.ophubVnetId
    vnetSpkVnetID:createSpokeVNet1.outputs.opSpkVnetId
    hubToSpokePeeringName: 'hub-to-${createSpokeVNet1.outputs.opSpkVnetName}'
    spokeToHubPeeringName: '${createSpokeVNet1.outputs.opSpkVnetName}-to-hub'
  }
}

// 5. Create a virtual network peering between the hub and spoke virtual networks
module createVNetPeering2 './modules/3.vnetPeering.bicep' = if(RunSpokeVnet2) {
  name: 'createVnetPeering2'
  dependsOn: [
    createHubVNet
    createSpokeVNet2
  ]
  params: {
    vnetNameHub: createHubVNet.outputs.ophubVnetName
    vnetNameSpk: createSpokeVNet2.outputs.opSpkVnetName
    vnetHubVnetID:createHubVNet.outputs.ophubVnetId
    vnetSpkVnetID:createSpokeVNet2.outputs.opSpkVnetId
    hubToSpokePeeringName: 'hub-to-${createSpokeVNet2.outputs.opSpkVnetName}'
    spokeToHubPeeringName: '${createSpokeVNet2.outputs.opSpkVnetName}-to-hub'
  }
}


// 4. create a NSG and attach it to the subnet in the spoke virtual network
module createNSG './modules/4.nsg.bicep' = if(RunNSG) {
  name : 'createNSG'
  dependsOn: [
    createSpokeVNet1
  ]
  params: {
    tags: tags
    location: location
    nsgName: 'poc-nsg-${createSpokeVNet1.outputs.opSpkSubnetName0}'
    spkvnetName: createSpokeVNet1.outputs.opSpkVnetName
    spksubnetName: createSpokeVNet1.outputs.opSpkSubnetName0
    spksubnetipaddress: createSpokeVNet1.outputs.opSpkSubnetPrefix0
  }
}

// 5. create a virtual machine in the spoke virtual network
module createVM './modules/5.virtualMachine.bicep' = [for i in vmIndex: if(RunVM) {
  name: 'create${vmName[i]}'
  dependsOn: [
    createSpokeVNet1
  ]
  params: {
    tag: tags
    location: location
    vnetName: vnetNameSpk
    subnetName: subnetName1Spk
    vmName: vmName[i]
    vmSize: vmSize
    adminUsername: adun
    adminPassword: adps
    vmComputerName: vmComputerName[i]
    vmOSVersion: vmOSVersion
    staticIPaddress: staticIPaddress[i]
    storageAccountName: '${storageAccountName}${i}'
  }
}]

// 6. create a SQL Server and a SQL Database
module createSQLServer './modules/6.sqlServer&Database.bicep' = if(RunSQLServer) {
name: 'createSQLServer'
params: {
  tags: tags
  location: location
  sqlServerName: sqlServerName
  sqlDatabaseName: sqlDatabaseName
  sqlLoginId: sqlLoginId
  sqlLoginPassword:sqlLoginPassword
}
}

// 7. create a bastion subnet in the hub virtual network
module createBastion './modules/7.bastion.bicep' = if(RunBastion) {
  name: 'createBastion'
  dependsOn: [
    createHubVNet
    createSpokeVNet1
    createVNetPeering1
  ]
  params: {
    tags: tags
    location: location
    vnetName: createHubVNet.outputs.ophubVnetName
    subnetName: bastionSubnetName
    ipAddressPrefix:ipAddressPrefixBastionSubnet
    publicIpAllocationMethod: publicIpAllocationMethod
    publicIpAddressVersion: publicIpAddressVersion
    publicIpSkuName: publicIpSkuName
    publicIpSkuTier: publicIpSkuTier
    publicIpName: publicIpName
    bastionName: bastionName
  }
}

//---EOF----
