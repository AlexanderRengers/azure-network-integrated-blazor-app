module appServicePlan 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: 'aspDeployment'
  params: {
    name: 'aspBlazor123'
  }
}

module webapp 'br/public:avm/res/web/site:0.14.0' = {
  name: 'webappDeployment'
  params: {
    // Required parameters
    kind: 'app'
    name: 'blazorapp123'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    appInsightResourceId: appInsights.outputs.resourceId
    vnetRouteAllEnabled: true
    virtualNetworkSubnetId: virtualNetwork.outputs.subnetResourceIds[1]
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneWeb.outputs.resourceId
            }
          ]
        }
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
       
      }
    ]
    publicNetworkAccess: 'Disabled'
  }
}

module privateDnsZoneWeb 'br/public:avm/res/network/private-dns-zone:0.7.0' = {
  name: 'privateDnsZoneWebDeployment'
  params: {
    // Required parameters
    name: 'privatelink.azurewebsites.net'
  }
}

resource privateLinkWeb 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'privatelink.azurewebsites.net/virtualNetworkLinkWeb'
  location: 'global'
  properties: {
    registrationEnabled: false
    resolutionPolicy: 'Default'
    virtualNetwork: {
      id: virtualNetwork.outputs.resourceId
    }
  }
}

module appInsights 'br/public:avm/res/insights/component:0.6.0' = {
  name: 'appInsightsDeployment'
  params: {
    // Required parameters
    name: 'appInsights123'
    workspaceResourceId: workspace.outputs.resourceId
  }
}

module workspace 'br/public:avm/res/operational-insights/workspace:0.11.0' = {
  name: 'workspaceDeployment'
  params: {
    // Required parameters
    name: 'logWS123'
  }
}

module sqlServer 'br/public:avm/res/sql/server:0.1.0' = {
  name: 'sqlServerDeployment'
  params: {
    name: 'sqlServer123321-${uniqueString(resourceGroup().id)}'
    administrators: {
      azureADOnlyAuthentication: true
      login: 'Alexander.Rengers@adac.de'
      principalType: 'User'
      sid: '<admin-principal-id>'
    }
    privateEndpoints: [
      {
        name: 'pe123'
        privateDnsZoneGroupName: 'privatelink.database.windows.net'
        privateDnsZoneResourceIds: [
          privateDnsZone.outputs.resourceId
        ]
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
      }
    ]
    databases: [
      {
        name: 'db123'
      }
    ]
  }
}

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.0' = {
  name: 'privateDnsZoneDeployment'
  params: {
    // Required parameters
    name: 'privatelink.database.windows.net'
  }
}

resource privateLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'privatelink.database.windows.net/virtualNetworkLinkDB'
  location: 'global'
  properties: {
    registrationEnabled: false
    resolutionPolicy: 'Default'
    virtualNetwork: {
      id: virtualNetwork.outputs.resourceId
    }
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.12.0' = {
  name: 'virtualMachineDeployment'
  params: {
    // Required parameters
    adminUsername: 'AzureUser'
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: 'jumpboxVM123'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
              zones: [
                1
                2
                3
              ]
            }
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
        NetworkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_D2s_v3'
    zone: 0
    // Non-required parameters
    adminPassword: '<admin-password>'
    encryptionAtHost: false
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.2' = {
  name: 'virtualNetworkDeployment'
  params: {
    // Required parameters
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: 'nvnmin001'
    subnets: [
      {
        addressPrefixes: [
          '10.0.0.0/24'
        ]
        name: 'default'
      }
      {
        addressPrefixes: [
          '10.0.1.0/24'
        ]
        name: 'webapp'
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'networkSecurityGroupDeployment'
  params: {
    // Required parameters
    name: 'nnsgmin001'
    securityRules: [
      {
        name: 'Specific'
        properties: {
          access: 'Allow'
          description: 'Tests specific IPs and ports'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          direction: 'Inbound'
          priority: 100
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}
