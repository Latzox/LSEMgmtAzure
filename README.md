# LSEMgmtAzure

**LSEMgmtAzure** is a PowerShell module to manage and monitor Microsoft Azure environments, providing functionality for resource management, cost analysis, and backup operations.

## Features
- `Connect-CloudServices`: Establish a connection to Azure services.
- `Get-AzureResourceSummary`: Fetch a summary of Azure resources.
- `Invoke-AzureFunction`: Trigger an Azure Function.
- `New-AzureResource`: Create an Azure resource (VM, storage account, etc.).
- `Get-AzureCostAnalysis`: Get cost details of Azure resources.
- `Backup-AzureStorage`: Backup data from Azure Storage Accounts to another location.
- `Set-AzureResourceTag`: Add or update tags for an Azure resource.
- `Get-AzureVMHealthCheck`: Perform a health check on an Azure Virtual Machine.

## Installation

To install this module from the PowerShell Gallery:

```PowerShell
Install-Module -Name LSEMgmtAzure -Repository PSGallery
```

## Usage
Here are some usage examples:

#### Connect to Azure cloud services
```PowerShell
Connect-CloudServices -Service "Azure"
```

#### Get a summary of all Azure resources
```PowerShell
Get-AzureResourceSummary -SubscriptionId "<YourSubscriptionId>"
```

#### Create an Azure resource
```PowerShell
New-AzureResource -ResourceType "VM" -Name "MyVM" -Location "EastUS" -Size "Standard_DS1_v2"
```
