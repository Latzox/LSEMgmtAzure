# File: Connect-CloudServices.Tests.ps1

Describe 'Connect-CloudServices' {

    # Mock the external commands that should not actually be called during tests
    BeforeAll {

        # Import the function you want to test
        . "$PSScriptRoot\functions\Connect-CloudServices.ps1"

        Mock -CommandName Get-InstalledModule -MockWith { return $null }
        Mock -CommandName Install-Module -MockWith {}
        Mock -CommandName Update-Module -MockWith {}
        Mock -CommandName Import-Module -MockWith {}
        Mock -CommandName Connect-AzAccount -MockWith {}
        Mock -CommandName Connect-ExchangeOnline -MockWith {}
        Mock -CommandName Connect-MgGraph -MockWith {}
        Mock -CommandName Connect-SPOService -MockWith {}
        Mock -CommandName Connect-MicrosoftTeams -MockWith {}
    }

    # Test that valid services are processed correctly
    Context 'When connecting to valid services' {
        It 'Should connect to Azure' {
            # Act
            Connect-CloudServices -Service 'Azure'

            # Assert
            Assert-MockCalled -CommandName Connect-AzAccount -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'Az' }
        }

        It 'Should connect to ExchangeOnlineManagement' {
            # Act
            Connect-CloudServices -Service 'ExchangeOnlineManagement'

            # Assert
            Assert-MockCalled -CommandName Connect-ExchangeOnline -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'ExchangeOnlineManagement' }
        }

        It 'Should connect to Microsoft.Graph' {
            # Act
            Connect-CloudServices -Service 'Microsoft.Graph'

            # Assert
            Assert-MockCalled -CommandName Connect-MgGraph -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'Microsoft.Graph' }
        }

        It 'Should connect to SharePoint Online' {
            # Arrange
            Mock -CommandName Read-Host -MockWith { "https://mock-sharepoint-admin.com" }

            # Act
            Connect-CloudServices -Service 'Microsoft.Online.SharePoint.PowerShell'

            # Assert
            Assert-MockCalled -CommandName Connect-SPOService -Exactly 1 -ParameterFilter { $_.Url -eq "https://mock-sharepoint-admin.com" }
        }

        It 'Should connect to Microsoft Teams' {
            # Act
            Connect-CloudServices -Service 'MicrosoftTeams'

            # Assert
            Assert-MockCalled -CommandName Connect-MicrosoftTeams -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'MicrosoftTeams' }
        }
    }

    # Test the Update functionality
    Context 'When updating modules' {
        It 'Should update Azure module when -Update is specified' {
            # Act
            Connect-CloudServices -Service 'Azure' -Update

            # Assert
            Assert-MockCalled -CommandName Update-Module -ParameterFilter { $_.Name -eq 'Az' } -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'Az' } -Exactly 1
        }

        It 'Should update ExchangeOnlineManagement module when -Update is specified' {
            # Act
            Connect-CloudServices -Service 'ExchangeOnlineManagement' -Update

            # Assert
            Assert-MockCalled -CommandName Update-Module -ParameterFilter { $_.Name -eq 'ExchangeOnlineManagement' } -Exactly 1
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $_.Name -eq 'ExchangeOnlineManagement' } -Exactly 1
        }
    }

    # Test error handling during connection
    Context 'When a connection error occurs' {
        It 'Should catch and report an error if Connect-AzAccount fails' {
            # Arrange
            Mock -CommandName Connect-AzAccount -MockWith { throw "Connection failed" }

            # Act
            { Connect-CloudServices -Service 'Azure' } | Should -Throw

            # Assert
            Assert-MockCalled -CommandName Connect-AzAccount -Exactly 1
        }

        It 'Should catch and report an error if Connect-ExchangeOnline fails' {
            # Arrange
            Mock -CommandName Connect-ExchangeOnline -MockWith { throw "Connection failed" }

            # Act
            { Connect-CloudServices -Service 'ExchangeOnlineManagement' } | Should -Throw

            # Assert
            Assert-MockCalled -CommandName Connect-ExchangeOnline -Exactly 1
        }
    }

    # Test when no module update is needed
    Context 'When no update is needed' {
        It 'Should not call Update-Module if -Update is not specified' {
            # Act
            Connect-CloudServices -Service 'Azure'

            # Assert
            Assert-MockNotCalled -CommandName Update-Module
        }
    }
}
