function Connect-CloudServices {
    <#
    .SYNOPSIS
    Authenticates and connects to specified cloud services.

    .DESCRIPTION
    Establish a connection to Microsoft 365 and Azure services.

    .PARAMETER Service
    Selection of the cloud service.

    .INPUTS
    None. You must provide values for the parameters explicitly.

    .OUTPUTS
    None. This function does not return output; it writes to a file or displays messages in the console.

    .EXAMPLE
    Example usage of the function.
    PS> Connect-CloudServices -Service "Azure"

    .NOTES
    Author: Marco Platzer
    Version: 1.0.0
    Date: 18-09-2024

    .LINK
    https://github.com/Latzox/LSEMgmtAzure

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Azure", "ExchangeOnlineManagement", "Microsoft.Graph", "Microsoft.Online.SharePoint.PowerShell", "MicrosoftTeams")]
        [string]$Service,

        [Parameter(Mandatory = $false, Position = 1)]
        [switch]$Initialize
    )

    Begin {
        Write-Verbose "Starting function execution..."

        if ($Initialize) {
            switch ($Service) {
                Azure { 
                    Write-Verbose "Azure selected."
                    Write-Verbose "Checking module existance."
    
                    $module = Get-InstalledModule -Name "Az"
    
                    if ($module) {
                        Write-Verbose "Module already installed. Checking version..."
                        $latest = (Find-Module -Name Az).version
    
                        if ($module.version -lt $latest) {
                            Write-Verbose "Updating module..."
                            Update-Module -Name Az -Confirm:$false -Force
                            Import-Module -Name Az
                        }
                        else {
                            Write-Verbose "Module alredy up to date."
                            Import-Module -Name Az
                        }
    
                    }
                    else {
                        Write-Verbose "Module not installed. Installing..."
                        Install-Module -Name Az -Confirm:$false -Force
                    }
                }
                MS365 {
                    Write-Verbose "MS365 selected."
                    Write-Verbose "Checking module existance."
    
                    $module = Get-InstalledModule -Name ""
    
                    if ($module) {
                        Write-Verbose "Module already installed. Trying to update."
                        Update-Module -Name Az -Confirm:$false -Force
                    }
                    else {
                        Write-Verbose "Module not installed. Installing..."
                        Install-Module -Name Az -Confirm:$false -Force
                    }
                }
            }
        }

    }

    Process {
        try {
            Write-Verbose "Processing the input parameters."

            switch ($Service) {
                Azure { 
                    Connect-AzAccount
                }
                ExchangeOnlineManagement {
                    Connect-ExchangeOnline
                }
                Microsoft.Graph {
                    Connect-MgGraph 
                }
                Microsoft.Online.SharePoint.PowerShell {
                    $url = Read-Host -Prompt "Enter the URL of your SharePoint Online Service (z.B. https://org-admin.sharepoint.com):"
                    Connect-SPOService -Url $url
                }
                MicrosoftTeams {
                    Connect-MicrosoftTeams
                }
            }

        }
        catch {
            # Catch block for error handling
            Write-Error "An error occurred connecting to ${Service}: $_"
        }
    }

    End {
        # Any cleanup code or final processing
        Write-Verbose "Function execution completed."
    }
}
