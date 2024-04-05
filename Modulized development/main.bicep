// - - - preconditions - - - 
// - - - - - - - - - - - - -
//All resources will be deployed in resource group "Bicep-fundermental-resourcegroup"
//location will be inherited from the resource group
// - - - - - - - - - - - - -
// - - - Boolean for engaging deployment - - -
// - - - true: engage / false; not engage - - -
@description('Booleans for engaging deployment')
param RunHubVnet bool = true
param RunSpokeVnet1 bool = true
param RunSpokeVnet2 bool = true
param RunGateway bool = true
param RunNSG bool = false
param RunVM bool = false
param RunSQLServer bool = false
param RunBastion bool = false

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
// - - - Spoke Virtual Network 01- - - 
@description('Parameters for Spoke Virtual Network 01')
param vnetNameSpk1 string = 'Private-SpokeVNet-01'
param ipAddressPrefixSpk1 array = ['10.11.0.0/16']
param subnetName1Spk1 string = 'PrivateSpk01-Subnet01'
param ipAddressPrefixSubnet01Spk1 string = '10.11.0.0/24'
param subnetName2Spk1 string = 'PrivateSpk01-Subnet02'
param ipAddressPrefixSubnet02Spk1 string = '10.11.1.0/24'
// - - - Spoke Virtual Network 02- - - 
@description('Parameters for Spoke Virtual Network 02')
param vnetNameSpk2 string = 'Private-SpokeVNet-02'
param ipAddressPrefixSpk2 array = ['10.12.0.0/16']
param subnetName1Spk2 string = 'PrivateSpk02-Subnet01'
param ipAddressPrefixSubnet01Spk2 string = '10.12.0.0/24'
param subnetName2Spk2 string = 'PrivateSpk02-Subnet02'
param ipAddressPrefixSubnet02Spk2 string = '10.12.1.0/24'
// - - - VPN Gateway - - -
@description('Parameters for VPN Gateway')
param vpnGatewayName string = 'Private-VPNGateway'
param gatewayPublicIpName string = 'Private-VPNGateway-PublicIP'
var gatewayPublicIpAllocationMethod = 'Static'
var gatewayPublicIpAddressVersion = 'IPv4'
var gatewayPublicIpSkuName = 'Standard'
var gatewayPublicIpSkuTier = 'Regional'
// - - - AFW Gateway - - -
@description('Parameters for AFW Gateway')
param afwGatewayName string = 'Private-AFWGateway'
param afwGatewayPublicIpName string = 'Private-AFWGateway-PublicIP'










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
//-------
//-------
//------- Program starts here -------
// Create a hub virtual network
module createHubVNet './modules/hub-vnet.bicep' = if (RunHubVnet) {
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

// Create the first spoke virtual network
module createSpokeVNet1 './modules/spoke-vnet.bicep' = if(RunSpokeVnet1) {
  name: 'createSpokeVnet1'
  params: {
    tags: tags
    location: location
    vnetName: vnetNameSpk1
    ipAddressPrefix: ipAddressPrefixSpk1
    subnetName1: subnetName1Spk1
    subnetName2: subnetName2Spk1
    subnetPrefix1: ipAddressPrefixSubnet01Spk1
    subnetPrefix2: ipAddressPrefixSubnet02Spk1
  }
}

// Create the second spoke virtual network
module createSpokeVNet2 './modules/spoke-vnet.bicep' = if(RunSpokeVnet2) {
  name: 'createSpokeVnet2'
  params: {
    tags: tags
    location: location
    vnetName: vnetNameSpk2
    ipAddressPrefix: ipAddressPrefixSpk2
    subnetName1: subnetName1Spk2
    subnetName2: subnetName2Spk2
    subnetPrefix1: ipAddressPrefixSubnet01Spk2  
    subnetPrefix2: ipAddressPrefixSubnet02Spk2
  }
}

// Create a virtual network peering between the hub and spoke1 virtual networks
module createVNetPeering1 './modules/vnetPeering.bicep' = if(RunSpokeVnet1) {
  name: 'createVnetPeering1'
  dependsOn: [
    createHubVNet
    createSpokeVNet1
  ]
  params: {
    vnetNameHub: createHubVNet.outputs.opHubVnetName
    vnetNameSpk: createSpokeVNet1.outputs.opSpkVnetName
    vnetHubVnetID:createHubVNet.outputs.opHubVnetId
    vnetSpkVnetID:createSpokeVNet1.outputs.opSpkVnetId
    hubToSpokePeeringName: 'hub-to-${createSpokeVNet1.outputs.opSpkVnetName}'
    spokeToHubPeeringName: '${createSpokeVNet1.outputs.opSpkVnetName}-to-hub'
  }
}

// Create a virtual network peering between the hub and spoke2 virtual networks
module createVNetPeering2 './modules/vnetPeering.bicep' = if(RunSpokeVnet2) {
  name: 'createVnetPeering2'
  dependsOn: [
    createHubVNet
    createSpokeVNet2
  ]
  params: {
    vnetNameHub: createHubVNet.outputs.opHubVnetName
    vnetNameSpk: createSpokeVNet2.outputs.opSpkVnetName
    vnetHubVnetID:createHubVNet.outputs.opHubVnetId
    vnetSpkVnetID:createSpokeVNet2.outputs.opSpkVnetId
    hubToSpokePeeringName: 'hub-to-${createSpokeVNet2.outputs.opSpkVnetName}'
    spokeToHubPeeringName: '${createSpokeVNet2.outputs.opSpkVnetName}-to-hub'
  }
}

module createGateway './Modules/gateway.bicep' = if(RunGateway) {
  name : 'createGateway'
  dependsOn: [
    createHubVNet
  ]
  params: {
    tags: tags
    location: location
    existingHubVNetName:createHubVNet.outputs.opHubVnetName
    existingGatewaySubnetName:createHubVNet.outputs.opHubVnetGatawaySubnetName
    gatewayPublicIpName:gatewayPublicIpName
    gatewayPublicIpAllocationMethod:gatewayPublicIpAllocationMethod
    gatewayPublicIpAddressVersion:gatewayPublicIpAddressVersion
    gatewayPublicIpSkuName:gatewayPublicIpSkuName
    gatewayPublicIpSkuTier:gatewayPublicIpSkuTier
    vpnGatewayName:vpnGatewayName
    HubVNetGatewaySubnetId:createHubVNet.outputs.opHubVnetGatawaySubnetId
  }
}

// 4. create a NSG and attach it to the subnet in the spoke virtual network
module createNSG './modules/nsg.bicep' = if(RunNSG) {
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
    vnetName: vnetNameSpk1
    subnetName: subnetName1Spk1
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
    vnetName: createHubVNet.outputs.opHubVnetName
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
