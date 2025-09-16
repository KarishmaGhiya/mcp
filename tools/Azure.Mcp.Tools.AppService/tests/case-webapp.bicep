targetScope = 'resourceGroup'

@minLength(3)
@maxLength(17)
@description('The base resource name.')
param baseName string = resourceGroup().name

@description('The location of the resource. By default, this is the same as the resource group.')
param location string = resourceGroup().location

@description('The client OID to grant access to test resources.')
param testApplicationOid string

@description('SQL Server administrator login name.')
param sqlAdminLogin string = 'mcptestadmin'

@description('SQL Server administrator password.')
@secure()
param sqlAdminPassword string = newGuid()

@description('The SKU for the App Service Plan.')
param appServicePlanSku string = 'B1'

// Variables
var webAppName = '${baseName}-webapp'
var appServicePlanName = '${baseName}-plan'
var sqlServerName = '${baseName}-sql'
var sqlDatabaseName = '${baseName}db'
var cosmosAccountName = '${baseName}-cosmos'
var cosmosDatabaseName = '${baseName}cosmosdb'
var cosmosContributorRoleId = '00000000-0000-0000-0000-000000000002' // Built-in Contributor role

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: 'Basic'
    size: appServicePlanSku
    family: 'B'
    capacity: 1
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlan.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// Role assignment for test application - Web App Contributor
resource webAppContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(webApp.id, testApplicationOid, 'de139f84-1756-47ae-9be6-808fbbe84772')
  scope: webApp
  properties: {
    principalId: testApplicationOid
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'de139f84-1756-47ae-9be6-808fbbe84772') // Website Contributor
  }
}

// Outputs for test usage
output webAppName string = webApp.name
output webAppResourceGroup string = resourceGroup().name
output baseName string = baseName
output location string = location
