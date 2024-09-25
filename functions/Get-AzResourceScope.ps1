function Get-AzResourceScope {
    <#
    .SYNOPSIS
    A brief description of what the function does.

    .DESCRIPTION
    A detailed explanation of the function’s purpose and how it works.

    .PARAMETER Param1
    Description of the first parameter.

    .PARAMETER Param2
    Description of the second parameter.

    .INPUTS
    If applicable, describe the types of objects that can be piped into this function.

    .OUTPUTS
    Describe the types of objects that the function returns.

    .EXAMPLE
    Example usage of the function with an explanation of what it does.
    PS> Get-SampleFunction -Param1 "Value1" -Param2 "Value2"

    .NOTES
    Additional information such as author, version, and any other notes.

    .LINK
    Link to documentation or related functions if applicable.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ResourceSet')]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ResourceSet')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SubscriptionSet')]
        [ValidateSet("Resource", "ResourceGroup", "Subscription")]
        [string]$Type,

        [Parameter(Mandatory = $true, ParameterSetName = 'ResourceSet')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SubscriptionSet')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ResourceSet')]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroup
    )

    Begin {
        Write-Verbose "Starting function execution..."
        try {
            Write-Verbose "Checking Azure connection..."
            Get-AzContext -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Azure resources not available. Please run Connect-CloudServices to establish a connection with your Azure account."
            return
        }
    }

    Process {
        try {
            Write-Verbose "Start processing."

            switch ($Type) {
                Resource {
                    Write-Verbose "Gather resource informations."
                    $resource = Get-AzResource -Name $Name -ResourceGroupName $ResourceGroup

                    Write-Verbose "Creating output."
                    return $resource.ResourceId
                }
                ResourceGroup {
                    Write-Verbose "Gather resourcegroup informations."
                    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroup

                    Write-Verbose "Creating outputs."
                    return $resourceGroup.ResourceId
                }
                Subscription {
                    Write-Verbose "Gatering subscription informations."
                    $subscriptionId = (Get-AzContext).Subscription.Id

                    Write-Verbose "Creating outputs."
                    return "/subscriptions/$subscriptionId"
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
