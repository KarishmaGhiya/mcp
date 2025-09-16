targetScope = 'resourceGroup'

param baseName string = 'mcp23746wu'
param location string = 'westus'
param sqlAdminLogin string = 'mcptestadmin'
@secure()
param sqlAdminPassword string = newGuid()

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: '${baseName}-sql'
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}
