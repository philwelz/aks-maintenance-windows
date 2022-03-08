
// inherited from root module
param basename string
param tags object
param k8sVersion string
param location string
param nodeCount int
param vmSize string

// ################################
// ############# AKS ##############
// ################################

// Create AKS
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-10-01' = {
  name: 'aks-${basename}'
  location: location
  tags: tags

  sku: {
    name: 'Basic'
    tier: 'Free'
  }

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    nodeResourceGroup: 'rg-aks-${basename}'
    kubernetesVersion: k8sVersion
    dnsPrefix: basename

    autoUpgradeProfile: {
      upgradeChannel: 'node-image'
    }

    agentPoolProfiles: [
      {
        name: 'default'
        mode: 'System'
        count: nodeCount
        vmSize: vmSize
        tags: tags
        upgradeSettings: {
          maxSurge: '33%'
        }

      }
    ]
  }
}

// Create AKS Maintenance Configugration
resource aksMaintenance 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2022-01-02-preview' = {
  name: 'MaintenanceConfig-${basename}'
  parent: aksCluster
  properties: {
    timeInWeek: [
      {
        day: 'Thursday'
        hourSlots: [
          2
          3
        ]
      }
    ]
  }
}

