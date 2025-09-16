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

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }

  // Test SQL Database
  resource testDatabase 'databases@2023-05-01-preview' = {
    name: sqlDatabaseName
    location: location
    sku: {
      name: 'Basic'
      tier: 'Basic'
      capacity: 5
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 2147483648
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      zoneRedundant: false
      readScale: 'Disabled'
      requestedBackupStorageRedundancy: 'Local'
      isLedgerOn: false
    }
  }
}

// SQL DB Contributor role definition
resource sqlDbContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  // This is the SQL DB Contributor role
  // Lets you manage SQL databases, but not access to them
  // See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#sql-db-contributor
  name: '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'
}

// Outputs for test usage
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabaseName
output sqlConnectionString string = 'Server=${sqlServer.properties.fullyQualifiedDomainName};Database=${sqlDatabaseName};Authentication=Active Directory Default;TrustServerCertificate=True;'


output baseName string = baseName
output location string = location
