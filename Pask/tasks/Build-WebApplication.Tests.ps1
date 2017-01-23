$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Build-WebApplication" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Build-WebApplication"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Build a web application solution with default configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug" | Should Exist
        }

        It "uses the default platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "includes the content files" {
            Join-Path $TestSolutionFullPath (Join-Path (Join-Path "WebApplication" $WebApplicationOutputPath) "Index.html") | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Exist
        }
    }

    Context "Build a web application project only" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication -BuildProjectOnly $true

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "does not build other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Not Exist
        }
    }

    Context "Build a web application solution with custom configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication -Configuration Release -Platform x64

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the custom configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\x64\Release" | Should Exist
        }

        It "uses the custom platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "Amd64"
        }

        It "includes the content files" {
            Join-Path $TestSolutionFullPath (Join-Path (Join-Path "WebApplication" $WebApplicationOutputPath) "Index.html") | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Exist
        }
    }
}