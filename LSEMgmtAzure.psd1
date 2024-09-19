@{
    RootModule        = 'LSEMgmtAzure.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '0dfcbdae-7100-49b8-b935-38035fa17962'
    Author            = 'Marco Platzer'
    CompanyName       = 'SWISSPERFORM'
    Copyright         = '(c) Marco Platzer. All rights reserved.'
    Description       = 'A PowerShell module for managing and monitoring Microsoft Azure environments.'
    PowerShellVersion = '7.1'
    FunctionsToExport = 'Connect-CloudServices', 'New-ServicePrincipal'
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'
    PrivateData       = @{
        PSData = @{
            Tags = 'Azure', 'Cloud Management', 'PowerShell', 'Automation'
        }
    }
}