// - - - preconditions - - - 
// - - - - - - - - - - - - -
// - - - Boolean for engaging deployment - - -
// - - - true: engage / false; not engage - - -
@description('Booleans for engaging deployment')
param DeployHubVnet bool = true
param DeploySpokeVnet1 bool = true
param DeploySpokeVnet2 bool = true
param DeployGateway bool = true
param DeployAFWPolicy bool = false
param DeployAFWMainPart bool = false
param DeployBastion bool = false
param DeployDNSResolver bool = true
// - - - 
param DeployNSG bool = false
param DeployVM bool = false
param DeploySQLServer bool = false
// - - - - - - - - - - - - -
//All resources will be deployed in resource group "Bicep-fundermental-resourcegroup"
//location will be inherited from the resource group
// - - - - - - - - - - - - -
// - - - - - - - - - - - - -
// - - - - - - - - - - - - -
// - - - Paremeters defination - - - 
// - - - Tags - - -
@description('Parameters for tags')
param tags object = {
  environment: 'poc'
  department: 'Infra'
  project: 'HINO'
}
// - - - Location - - -
@description('Parameter for location')
param location string = resourceGroup().location
// - - - Hub Virtual Network - - -
@description('Parameters for Hub Virtual Network')
var vnetNameHub = 'Private-HubVnet'
param ipAddressPrefixHub array = ['10.10.0.0/16']
param subnetGatewayPrefix string = '10.10.0.0/26'
param subnetFirewallPrefix string = '10.10.0.64/26'
param subnetBastionPrefix  string = '10.10.0.128/25'
param subnetDNSResolverInboundPrefix  string = '10.10.1.0/25'
param subnetDNSResolverOutboundPrefix  string = '10.10.1.128/25'
param subnetName01  string = 'PrivateHVnet-Subnet01'
param subnetPrefix01 string = '10.10.2.0/24'
param subnetName02  string = 'PrivateHVnet-Subnet02'
param subnetPrefix02 string = '10.10.3.0/24'
// - - - Spoke Virtual Network 01 - - - 
@description('Parameters for Spoke Virtual Network 01')
param vnetNameSpk1 string = 'Private-SpokeVNet-01'
param ipAddressPrefixSpk1 array = ['10.11.0.0/16']
param subnetName1Spk1 string = 'PrivateSpk01-Subnet01'
param ipAddressPrefixSubnet01Spk1 string = '10.11.0.0/24'
param subnetName2Spk1 string = 'PrivateSpk01-Subnet02'
param ipAddressPrefixSubnet02Spk1 string = '10.11.1.0/24'
// - - - Spoke Virtual Network 02 - - - 
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
// - - - Azure Firewall - - -
@description('Parameters for AFW Gateway')
param afwMainPartName string = 'Private-AzureFirewall'
param afwTier string = 'Standard'
param afwThreatIntelMode string = 'Alert' //'deny'/'alert'/'off'
// - - - Azure Firewall Public IP - - -
param afwPublicIPName string = 'Private-AFW-PublicIP'
var afwPublicIPAllocationMethod = 'Static'
var afwPublicIPAddressVersion = 'IPv4'
var afwPublicIPSkuName = 'Standard'
var afwPublicIPSkuTier = 'Regional'
// - - - AFW Policy - - -
param afwPolicyName string = 'Private-AFW-Policy'
param afwPolicySKU string = 'Standard'
param afwPolicyThreatIntelMode string = 'Alert'
param afwPolicyEnableDNSProxy bool = true
param afwPolicyDNSProxyServers array = ['168.63.129.16']
// - - - Bastion Public IP - - -
@description('Parameters for Bastion Public IP')
param bastionPublicIPName string = 'Private-Bastion-PublicIP'
var bastionPublicIPAllocationMethod = 'Static'
var bastionPublicIPAddressVersion = 'IPv4'
var bastionPublicIPSkuName = 'Standard'
var bastionPublicIPSkuTier = 'Regional'
// - - - Bastion - - -
@description('Parameters for Bastion')
param bastionName string = 'Private-Bastion'
param bastionSKU string = 'Standard'





















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
// - - - Storage Account - - -
@description('Parameters for Storage Account')
var storageAccountName = 'poc${uniqueString(resourceGroup().id,deployment().name)}'
// - - - Log Analytics - - -
// @description('Parameters for Log Analytics')
// param logAnalyticsWorkspace string = 'poc-${uniqueString(resourceGroup().id,deployment().name,location)}'



//-------
//-------
//------- Program starts here -------
// Create a hub virtual network
module createHubVNet './modules/hub-vnet.bicep' = if (DeployHubVnet) {
  name: 'createHubVnet'
  params: {
    tags: tags
    location: location
    vnetName: vnetNameHub
    ipAddressPrefixes: ipAddressPrefixHub
    subnetGatewayPrefix: subnetGatewayPrefix
    subnetFirewallPrefix:subnetFirewallPrefix
    subnetBastionPrefix :subnetBastionPrefix
    subnetDNSResolverInboundPrefix:subnetDNSResolverInboundPrefix
    subnetDNSResolverOutboundPrefix:subnetDNSResolverOutboundPrefix
    subnetName01 :subnetName01
    subnetPrefix01: subnetPrefix01
    subnetName02 :subnetName02
    subnetPrefix02:subnetPrefix02
  }
}

// Create the 1st Spoke virtual network
module createSpokeVNet1 './modules/spoke-vnet.bicep' = if(DeploySpokeVnet1) {
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

// Create the 2nd Spoke virtual network
module createSpokeVNet2 './modules/spoke-vnet.bicep' = if(DeploySpokeVnet2) {
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

// Create a virtual network peering between the hub and the 1st Spoke virtual networks
module createVNetPeering1 './modules/vnetPeering.bicep' = if(DeploySpokeVnet1) {
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

// Create a virtual network peering between the hub and the 2nd Spoke virtual networks
module createVNetPeering2 './modules/vnetPeering.bicep' = if(DeploySpokeVnet2) {
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
    spokeToHubPeeringName: '${createSpokeVNet2.outputs.opSpkVnetName}-to-hub'
    hubToSpokePeeringName: 'hub-to-${createSpokeVNet2.outputs.opSpkVnetName}'
  }
}

// Create a VPN Gateway
module createGateway './Modules/gateway.bicep' = if(DeployGateway) {
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

@description('Create an Azure Firewall Public IP')
module createAFWPublicIP './modules/publicIP.bicep' = if(DeployAFWMainPart) {
  name : 'createAFWPublicIP'
  dependsOn: [
    createHubVNet
  ]
  params: {
    tags: tags
    location: location
    publicIPName:afwPublicIPName
    publicIPAllocationMethod:afwPublicIPAllocationMethod
    publicIPAddressVersion:afwPublicIPAddressVersion
    publicIPSkuName:afwPublicIPSkuName
    publicIPSkuTier:afwPublicIPSkuTier
  }
}

@description('Create a Azure Firewall Policy')
module createAFWPolicy './modules/afwPolicy.bicep' = if(DeployAFWPolicy) {
  name : 'createAFWPolicy'
  dependsOn: [
    createHubVNet
  ]
  params: {
    tags: tags
    location: location
    afwPolicyName:afwPolicyName
    afwPolicySKU:afwPolicySKU 
    afwPolicyThreatIntelMode:afwPolicyThreatIntelMode
    afwPolicyDNSProxyServers:afwPolicyDNSProxyServers
    afwPolicyEnableDNSProxy:afwPolicyEnableDNSProxy
    afwDNatdestinationAddresses:createAFWPublicIP.outputs.opPublicIPAddress
  }
}

@description('Create an Azure Firewall')
module createAFWMainPart 'Modules/afwMainPart.bicep' = if (DeployAFWMainPart) {
  name: 'createAFWMainPart'
  params: {
    tags: tags
    location: location
    afwMainPartName:afwMainPartName
    afwTier:afwTier
    afwThreatIntelMode:afwThreatIntelMode
//    afwIPConfigurationId:createAFWPolicy.outputs.opAFWPublicIPId
    afwPublicIPId:createAFWPublicIP.outputs.opPublicIPId
    afwSubnetId:createHubVNet.outputs.opHubVnetFirewallSubnetId
    afwPolicyId:createAFWPolicy.outputs.opAFWPolicyId
  }
}

@description('Create a Public IP for Bastion')
module createBastionPublicIP './modules/publicIP.bicep' = if(DeployBastion) {
  name : 'createBastionPublicIP'
  dependsOn: [
    createHubVNet
  ]
  params: {
    tags: tags
    location: location
    publicIPName: bastionPublicIPName
    publicIPAllocationMethod: bastionPublicIPAllocationMethod
    publicIPAddressVersion: bastionPublicIPAddressVersion
    publicIPSkuName: bastionPublicIPSkuName
    publicIPSkuTier: bastionPublicIPSkuTier
  }
}

@description('create a bastion subnet in the hub virtual network')
module createBastion './modules/bastion.bicep' = if(DeployBastion) {
  name: 'createBastion'
  dependsOn: [
    createHubVNet
    createVNetPeering1
    createBastionPublicIP
  ]
  params: {
    tags: tags
    location: location
    bastionName: bastionName
    bastionSubnetID: createHubVNet.outputs.opHubVnetBastionSubnetId 
    bastionPublicIPID: createBastionPublicIP.outputs.opPublicIPId
    bastionSKU: bastionSKU
  }
}

// Create a DNS Resolver
resource createDNSResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  dependsOn: [
    createHubVNet
  ]
  name: 'DNSResolverName'
  tags: tags
  location: location
  properties: {
    virtualNetwork: {
      id: createHubVNet.outputs.opHubVnetId
    }
  }
}

resource createDNSResolverInboundEndPoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: createDNSResolver
  name: 'createDNSResolverInboundEndPoint'
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Dynamic'
        subnet: {
          id: createHubVNet.outputs.opHubVnetDNSResolverinboundSubnetId
        }
      }
    ]
  }
}

resource createDNSResolverOutboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: createDNSResolver
  tags: tags
  name: 'createDNSResolverOutboundEndPoint'
  location: location
  properties: {
    subnet: {
      id: createHubVNet.outputs.opHubVnetDNSResolveroutboundSubnetId
    }
  }
}

resource createDNSForwardRuleSet 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: 'createForwardRuleSet'
  location: location
  tags: tags
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: createDNSResolverOutboundEndpoint.id
      }
    ]
  }
}

resource createDNSResolverLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: createDNSForwardRuleSet
  name: 'createDNSResolverLink'
  properties: {
    virtualNetwork: {
      id: createHubVNet.outputs.opHubVnetId
    }
  }
}

resource createDNSForwardRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  parent: createDNSForwardRuleSet
  name: 'createDNSForwardRules'
  properties: {
    domainName: 'azure.com.'
    targetDnsServers: [
      {
        ipAddress: '10.0.0.24'
        port:53
      }
      {
        ipAddress: '10.0.0.25'
        port:53
      }
    ]
  }
}
























// 4. create a NSG and attach it to the subnet in the spoke virtual network
module createNSG './modules/nsg.bicep' = if(DeployNSG) {
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
module createVM './modules/5.virtualMachine.bicep' = [for i in vmIndex: if(DeployVM) {
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
module createSQLServer './modules/6.sqlServer&Database.bicep' = if(DeploySQLServer) {
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


//---EOF----
