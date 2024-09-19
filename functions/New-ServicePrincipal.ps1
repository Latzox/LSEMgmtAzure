function New-ServicePrincipal {
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

    [CmdletBinding()] 
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Secret", "FederatedCredential")]
        [string]$Type,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Role,

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$Scope
    )

    Begin {
        Write-Verbose "Starting function execution..."
        try {
            Write-Verbose "Checking Azure connection..."
            Get-AzContext | Out-Null
        }
        catch {
            Write-Error "Azure resources not available. Try execute Connect-CloudServices to establish a connection with your Azure account."
        }
    }

    Process {
        try {
            Write-Verbose "Starting to process..."

            Write-Verbose "Creating application and service principal with the role assignment..."
            $sp = New-AzADServicePrincipal -DisplayName $DisplayName -Role $Role -Scope $Scope

            switch ($Type) {

                FederatedCredential {

                    Write-Verbose "Getting additional parameters for the federated credentials..."
                    $org = Read-Host -Prompt "Enter the GitHub org name where your workflow is running:"
                    $repo = Read-Host -Prompt "Enter the GitHub repo name where your workflow is running:"
                    $env = Read-Host -Prompt "Enter the environment name where your workflow is running (e.g. production, public):"

                    Write-Verbose "Creating federated credentials for the github workflow..."

                    $fedCreds = @{
                        ApplicationObjectId = $sp.Id
                        Audience            = "api://AzureADTokenExchange"
                        Issuer              = "https://token.actions.githubusercontent.com/"
                        Name                = "Federated Credentials for OIDC Authentication"
                        Subject             = "repo:$org/${repo}:environment:$env"
                    }
                    New-AzADAppFederatedCredential @fedCreds

                    Write-Verbose "Output secrets now..."

                    $appId = $sp.AppId
                    $subId = (Get-AzContext).Subscription.Id
                    $tenantId = (Get-AzContext).Tenant.Id

                    Write-Output "AZURE_CLIENT_ID: $appId"
                    Write-Output "AZURE_SUBSCRIPTION_ID: $subId"
                    Write-Output "AZURE_TENANT_ID: $tenantId"

                }
                Secret {
                    
                    Write-Verbose "Output secrets now..."

                    $appId = $sp.AppId
                    $subId = (Get-AzContext).Subscription.Id
                    $tenantId = (Get-AzContext).Tenant.Id
                    $secret = $sp.PasswordCredentials.SecretText

                    Write-Output "-------------------------------"
                    Write-Output "AZURE_CLIENT_ID: $appId"
                    Write-Output "AZURE_SUBSCRIPTION_ID: $subId"
                    Write-Output "AZURE_TENANT_ID: $tenantId"
                    Write-Output "AZURE_CLIENT_SECRET: $secret"
                    Write-Output "-------------------------------"

                }
            }
        }
        catch {
            Write-Error "An error occurred creating the application: $_"
        }
    }

    End {
        Write-Verbose "Function execution completed."
    }
}
