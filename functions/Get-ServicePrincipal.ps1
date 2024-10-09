function Get-ServicePrincipal {
    <#
    .SYNOPSIS
    Retrieves all Azure service principals with configured secrets, certificates, or federated credentials.

    .DESCRIPTION
    This function retrieves all Azure service principals with configured secrets, certificates, or federated credentials, and allows filtering by DisplayName or Id.

    .INPUTS
    None. You cannot pipe input into this function.

    .OUTPUTS
    System.Object. The service principals with the following properties: DisplayName, Id, HasSecret, HasCertificate, HasFederatedCredentials.

    .EXAMPLE
    PS> Get-ServicePrincipal -DisplayName 'App1'

    .NOTES
    Author: https://github.com/Latzox
    Version: 1.0.0

    .LINK
    https://github.com/Latzox/LSEMgmtAzure

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [string]$Id
    )

    Begin {
        Write-Verbose "Starting the function execution."

        # Global settings
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'
    }

    Process {
        try {
            Write-Verbose "Starting to process the function."

            # Get all service principals
            Write-Verbose "Retrieving all service principals."
            $servicePrincipals = Get-AzADApplication

            $filteredPrincipals = @()

            # Loop through each service principal
            Write-Verbose "Looping through each service principal and checking for secrets, certificates, and federated credentials."
            foreach ($sp in $servicePrincipals) {
                $hasSecret = $sp.PasswordCredentials.Count -gt 0
                $hasCertificate = $sp.KeyCredentials.Count -gt 0
                $hasFederatedCredentials = @(Get-AzADAppFederatedCredential -ApplicationObjectId $sp.Id).Count -gt 0

                if ($hasSecret -or $hasCertificate -or $hasFederatedCredentials) {
                    $sp | Add-Member -MemberType NoteProperty -Name "HasSecret" -Value $hasSecret
                    $sp | Add-Member -MemberType NoteProperty -Name "HasCertificate" -Value $hasCertificate
                    $sp | Add-Member -MemberType NoteProperty -Name "HasFederatedCredentials" -Value $hasFederatedCredentials
                    $filteredPrincipals += $sp
                }
            }

            # Apply filters if specified
            if ($DisplayName) {
                Write-Verbose "Applying the DisplayName filter."
                $filteredPrincipals = $filteredPrincipals | Where-Object { $_.DisplayName -like "*$DisplayName*" }
            }
            if ($Id) {
                Write-Verbose "Applying the Id filter."
                $filteredPrincipals = $filteredPrincipals | Where-Object { $_.Id -eq $Id }
            }

            # Output the filtered service principals
            Write-Verbose "Outputting the filtered service principals."
            $filteredPrincipals | Select-Object -Property DisplayName, Id, HasSecret, HasCertificate, HasFederatedCredentials | Format-Table -AutoSize

        }
        catch {
            Write-Error "An error occurred: $_"
        }
    }

    End {
        Write-Verbose "Function execution completed."
    }
}
