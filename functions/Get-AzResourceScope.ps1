function Get-AzResourceScope {
    <#
    .SYNOPSIS
    Retrieves the scope of an Azure resource, resource group, or subscription.

    .DESCRIPTION
    This function retrieves the scope (resource ID) of an Azure resource, resource group, or subscription,
    depending on the specified type. It requires an established connection to Azure.

    .PARAMETER Type
    Specifies the scope type: "Resource", "ResourceGroup", or "Subscription".

    .PARAMETER Name
    The name of the Azure resource. Mandatory for "Resource" type.

    .PARAMETER ResourceGroup
    The name of the resource group. Mandatory for "Resource" and "ResourceGroup" types.

    .INPUTS
    None. You cannot pipe input into this function.

    .OUTPUTS
    System.String. The resource ID of the specified resource, resource group, or subscription.

    .EXAMPLE
    Retrieve the resource ID of a specific resource:
    PS> Get-AzResourceScope -Type "Resource" -Name "MyResource" -ResourceGroup "MyResourceGroup"

    .EXAMPLE
    Retrieve the resource ID of a specific resource group:
    PS> Get-AzResourceScope -Type "ResourceGroup" -Name "MyResourceGroup"

    .EXAMPLE
    Retrieve the subscription ID:
    PS> Get-AzResourceScope -Type "Subscription"

    .NOTES
    Author: https://github.com/Latzox
    Version: 1.0.0

    .LINK
    https://github.com/Latzox/LSEMgmtAzure

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Resource", "ResourceGroup", "Subscription")]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        #[ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName
    )

    Begin {
        Write-Verbose "Starting function execution..."
        try {
            Write-Verbose "Checking Azure connection..."
            Get-AzContext -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Azure resources not available. Please run Connect-AzAccount to establish a connection with your Azure account."
            return
        }
    }

    Process {
        try {
            Write-Verbose "Processing based on the selected type: $Type"

            switch ($Type) {
                Resource {
                    if (-not $Name -or -not $ResourceGroupName) {
                        throw "For 'Resource' type, both 'Name' and 'ResourceGroupName' parameters are required."
                    }

                    Write-Verbose "Fetching resource information..."
                    try {
                        $resource = Get-AzResource -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction Stop
                    }
                    catch {
                        Write-Error "The resource '$Name' does not exist in the resource group '$ResourceGroupName'."
                        return
                    }

                    if (-not $resource) {
                        Write-Error "The resource '$Name' was not found in the resource group '$ResourceGroupName'."
                        return
                    }

                    Write-Verbose "Creating output for the resource."
                    [PSCustomObject]@{
                        Type              = 'Resource'
                        Name              = $Name
                        ResourceGroupName = $ResourceGroupName
                        ResourceId        = $resource.ResourceId
                    }
                }
                ResourceGroup {
                    if (-not $Name) {
                        throw "For 'ResourceGroup' type, 'Name' parameter is required."
                    }

                    Write-Verbose "Fetching resource group information..."
                    try {
                        $resourceGroup = Get-AzResourceGroup -Name $Name -ErrorAction Stop
                    }
                    catch {
                        Write-Error "The resource group '$Name' does not exist."
                        return
                    }

                    if (-not $resourceGroup) {
                        Write-Error "The resource group '$Name' was not found."
                        return
                    }

                    Write-Verbose "Creating output for the resource group."
                    [PSCustomObject]@{
                        Type              = 'ResourceGroup'
                        ResourceGroupName = $Name
                        ResourceId        = $resourceGroup.ResourceId
                    }
                }
                Subscription {
                    Write-Verbose "Fetching subscription information..."
                    $subscriptionId = (Get-AzContext).Subscription.Id

                    Write-Verbose "Creating output for the subscription."
                    [PSCustomObject]@{
                        Type           = 'Subscription'
                        SubscriptionId = $subscriptionId
                        ResourceId     = "/subscriptions/$subscriptionId"
                    }
                }
            }
        }
        catch {
            Write-Error "An error occurred: $_"
        }
    }

    End {
        Write-Verbose "Function execution completed."
    }
}
