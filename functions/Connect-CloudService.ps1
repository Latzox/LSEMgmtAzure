function Connect-CloudService {
    <#
    .SYNOPSIS
    Authenticates and connects to specified cloud services.

    .DESCRIPTION
    Establish a connection to Microsoft 365 and Azure services.

    .PARAMETER Service
    Selection of the cloud service.

    .PARAMETER Update
    Updates the specified service's module.

    .INPUTS
    None. You must provide values for the parameters explicitly.

    .OUTPUTS
    None. This function does not return output; it writes to a file or displays messages in the console.

    .EXAMPLE
    Connect-CloudService -Service "Azure"

    .NOTES
    Author: https://github.com/Latzox
    Version: 1.0.1

    .LINK
    https://github.com/Latzox/LSEMgmtAzure

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Az", "ExchangeOnlineManagement", "Microsoft.Graph", "Microsoft.Online.SharePoint.PowerShell", "MicrosoftTeams")]
        [string]$Service,

        [Parameter(Mandatory = $false, Position = 1)]
        [switch]$Update
    )

    Begin {
        Write-Verbose "Starting function execution..."

        function Initialize-Module {
            param (
                [string]$ModuleName,
                [switch]$Update
            )

            $module = Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue
            $loaded = Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue

            if ($Update -and $module) {
                Write-Verbose "Updating module $ModuleName..."
                Update-Module -Name $ModuleName -Confirm:$false -Force
            }
            elseif (-not $module) {
                Write-Verbose "Installing module $ModuleName..."
                Install-Module -Name $ModuleName -Confirm:$false -Force
            } else {
                Write-Verbose "Module $ModuleName is already installed."
            }

            if (-not $loaded) {
                Write-Verbose "Importing module $ModuleName..."
                Import-Module -Name $ModuleName -Force
            } else {
                Write-Verbose "Module $ModuleName is already loaded. Skipping import."
            }
        }

        if ($Update) {
            switch ($Service) {
                Az {
                    Initialize-Module -ModuleName $Service -Update:$Update
                }
                ExchangeOnlineManagement {
                    Initialize-Module -ModuleName $Service -Update:$Update
                }
                Microsoft.Graph {
                    Initialize-Module -ModuleName $Service -Update:$Update
                }
                Microsoft.Online.SharePoint.PowerShell {
                    Initialize-Module -ModuleName $Service -Update:$Update
                }
                MicrosoftTeams {
                    Initialize-Module -ModuleName $Service -Update:$Update
                }
            }
        }
    }

    Process {
        try {
            Write-Verbose "Processing the input parameters for service: $Service"

            switch ($Service) {
                Az {
                    Connect-AzAccount -ErrorAction Stop
                }
                ExchangeOnlineManagement {
                    Connect-ExchangeOnline -ErrorAction Stop
                }
                Microsoft.Graph {
                    Connect-MgGraph -ErrorAction Stop
                }
                Microsoft.Online.SharePoint.PowerShell {
                    $url = Read-Host -Prompt "Enter the URL of your SharePoint Online Service (e.g., https://org-admin.sharepoint.com):"
                    Connect-SPOService -Url $url -ErrorAction Stop
                }
                MicrosoftTeams {
                    Connect-MicrosoftTeams -ErrorAction Stop
                }
            }

        }
        catch {
            Write-Error "Failed to connect to $Service. Error details: $_"
        }
    }

    End {
        Write-Verbose "Function execution completed."
    }
}
