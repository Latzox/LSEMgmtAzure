# LSEMgmtAzure

**LSEMgmtAzure** is a PowerShell module to manage and monitor Microsoft Azure environments, providing functionality for resource management, cost analysis, and backup operations.

## Features
- `Connect-CloudServices`: Establish a connection to Azure services.
- `New-ServicePrincipal`: Create service principals and assign roles and permissions.

## Installation

To install this module you have to clone the repository and import the module. The module gets publish into a private registry at the moment.

## Usage
Here are some usage examples:

#### Connect to Azure cloud services and optionally update the dependencies
```PowerShell
Connect-CloudServices -Service Az
```

#### Easily create service principals and assign roles and permissions
```PowerShell
New-ServicePrincipal -Type "Secret" -DisplayName "MyApp" -Role "Contributor" -Scope "/subscriptions/XXXX"
```
