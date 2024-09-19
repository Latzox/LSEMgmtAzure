function New-ServicePrincipal {
    <#
    .SYNOPSIS
    Creates a new Azure AD Service Principal and assigns the specified role.

    .DESCRIPTION
    This function creates a new Azure AD Service Principal with a specified role and scope.
    It can also handle creating federated credentials for GitHub workflows or generating secrets.

    .PARAMETER Type
    Specifies whether the service principal will use a secret or federated credentials.

    .PARAMETER DisplayName
    The display name for the service principal.

    .PARAMETER Role
    The role to be assigned to the service principal.

    .PARAMETER Scope
    The scope of the role assignment for the service principal.

    .INPUTS
    None. Parameters must be passed directly.

    .OUTPUTS
    Outputs a hashtable with client ID, subscription ID, tenant ID, and optionally client secret.

    .EXAMPLE
    PS> New-ServicePrincipal -Type "Secret" -DisplayName "MyApp" -Role "Contributor" -Scope "/subscriptions/XXXX"

    .NOTES
    Author: Marco Platzer
    Version: 1.0.0

    .LINK
    https://github.com/Latzox/LSEMgmtAzure

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Secret", "FederatedCredential")]
        [string]$Type,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Role,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$Scope
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
        Write-Verbose "Starting to process..."
        try {
            Write-Verbose "Creating the Azure AD Service Principal..."
            $servicePrincipal = New-AzADServicePrincipal -DisplayName $DisplayName -Role $Role -Scope $Scope -ErrorAction Stop
            $application = Get-AzADApplication -ApplicationId $servicePrincipal.AppId -ErrorAction Stop

            switch ($Type) {
                'FederatedCredential' {
                    Write-Verbose "Creating federated credentials for GitHub workflows..."
                    $org = Read-Host -Prompt "Enter the GitHub org name"
                    $repo = Read-Host -Prompt "Enter the GitHub repo name"
                    $env = Read-Host -Prompt "Enter the environment name (e.g. production, public)"

                    $federatedCredentialParams = @{
                        ApplicationObjectId = $application.Id
                        Audience            = "api://AzureADTokenExchange"
                        Issuer              = "https://token.actions.githubusercontent.com/"
                        Name                = "OIDC"
                        Subject             = "repo:$org/${repo}:environment:$env"
                    }

                    New-AzADAppFederatedCredential @federatedCredentialParams -ErrorAction Stop | Out-Null

                    Write-Verbose "Outputting secrets..."
                    $secrets = [PSCustomObject]@{
                        AZURE_CLIENT_ID        = $application.AppId
                        AZURE_SUBSCRIPTION_ID  = (Get-AzContext).Subscription.Id
                        AZURE_TENANT_ID        = (Get-AzContext).Tenant.Id
                    }
                }

                'Secret' {
                    Write-Verbose "Retrieving and outputting secrets..."
                    $secrets = [PSCustomObject]@{
                        AZURE_CLIENT_ID        = $application.AppId
                        AZURE_SUBSCRIPTION_ID  = (Get-AzContext).Subscription.Id
                        AZURE_TENANT_ID        = (Get-AzContext).Tenant.Id
                        AZURE_CLIENT_SECRET    = $servicePrincipal.PasswordCredentials.SecretText
                    }
                }
            }

            return $secrets
        }
        catch {
            Write-Error "An error occurred during the process: $_"
            return
        }
    }

    End {
        Write-Verbose "Function execution completed."
    }
}
