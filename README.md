# LSEMgmtAzure

**LSEMgmtAzure** is a PowerShell module to manage and monitor Microsoft Azure environments, providing functionality for resource management, cost analysis, and backup operations.

## Features
- `Connect-CloudService`: Establish a connection to Azure services.
- `New-ServicePrincipal`: Create service principals and assign roles and permissions.
- `Get-AzResourceScope`: Get the resource scope of any resource, resource group or subscription.

## Installation

To install this module you have to clone the repository and import the module. The module gets publish into a private registry at the moment.

## Usage
Here are some usage examples:

#### Connect to cloud services and optionally update the dependencies
```PowerShell
Connect-CloudService -Service Az
Connect-CloudService -Service ExchangeOnlineManagement -Update
```

#### Easily create service principals and assign roles and permissions
```PowerShell
New-ServicePrincipal -Type "Secret" -DisplayName "MyApp" -Role "Contributor" -Scope "/subscriptions/XXXX"
New-ServicePrincipal -Type "FederatedCredential" -DisplayName "MyApp" -Role "Contributor" -Scope "/subscriptions/XXXX"
```

#### Quickly get the scope of any resource
```PowerShell
Get-AzResourceScope -Type "Resource" -Name "MyResource" -ResourceGroup "MyResourceGroup"
Get-AzResourceScope -Type "ResourceGroup" -Name "MyResourceGroup"
Get-AzResourceScope -Type "Subscription"
```
