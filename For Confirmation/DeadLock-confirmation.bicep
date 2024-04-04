targetScope = 'resourceGroup'

// - - - preconditions - - - 
// - - - - - - - - - - - - -
//All resources will be deployed in resource group "Bicep-fundermental-resourcegroup"
//location will be inherited from the resource group
// - - - - - - - - - - - - -
// - - - - - - - - - - - - -

// - - - Paremeters defination - - - 
@description('Parameter for location')
param location string = resourceGroup().location
// - - - Hub Virtual Network - - - 
@description('Parameters for Hub Virtual Network')
var vnetNameHub = 'poc-Hub-Vnet'
param ipAddressPrefixHub array = ['10.0.0.0/16']
param ipAddressSubnetAFW string = '10.0.255.0/26'
// - - - Peerings - - -
var hubToSpokePeeringName = 'poc-hubtospokepeering'
var spokeToHubPeeringName = 'poc-spoketohubpeering'
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
// - - - tags - - -
@description('Parameters for tags')
param tags object = {
  environment: 'poc'
  department: 'Infra'
  project: 'Bicep'
}

param SubnetName string = ''
param SubnetIPId string = ''

// - - - Log Analytics - - -
// @description('Parameters for Log Analytics')
// param logAnalyticsWorkspace string = 'poc-${uniqueString(resourceGroup().id,deployment().name,location)}'

//-------
//-------
//------- Program starts here ------
// - - - 1.Create a Hub VNet - - -
resource createHubVNet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetNameHub
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ipAddressPrefixHub
    }
    subnets: [
      {
        name:'AzureFirewallSubnet'
        properties: {
          addressPrefix: ipAddressSubnetAFW
        }
      }
    ]
  }
}

// - - - 2.Create a Spoke VNet - - -
resource createSpokeVNet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetNameSpk
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ipAddressPrefixSpk
    }
    subnets: [
      {
        name: subnetName1Spk
        properties: {
          addressPrefix: ipAddressPrefixSpk01Subnet02
        }
      }
    ]
  }
}

// - - - 3.Create an UDR - - -
resource createUDR 'Microsoft.Network/routeTables@2022-05-01' = {
  name: 'poc-UDR-01'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'poc-UDR-01'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: createAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// - - - 4.Recall the subnet of the Spoke VNet - - -
resource getSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: createSpokeVNet.properties.subnets[0].name
}
output SubnetName string = getSubnet.name
output SubnetIPId string =  getSubnet.id

// - - - 5.Rebuild subnet to attach the UDR - - -
resource rebuildSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: SubnetName
  parent: createSpokeVNet
  properties: {
    addressPrefix: getSubnet.id
    routeTable: {
      id: createUDR.id
    }
  }
}
// - - - 6.Create a Public IP for AFW - - -
resource createPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  tags: tags
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

// - - - 7.Create an Azure Firewall - - -
resource createAzureFirewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: 'poc-AFW-name' // Firewallの名前を指定します
  location: location 
  tags: tags
  dependsOn: [
    rebuildSubnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'poc-AFW-IpConfigName'
        properties: {
          subnet: {
              id:createHubVNet.properties.subnets[0].id 
            }
          publicIPAddress: {
            id:createPublicIp.id 
          }
        }
      }
    ]
  }
}
