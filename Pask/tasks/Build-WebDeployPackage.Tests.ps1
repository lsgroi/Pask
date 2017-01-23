$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Build-WebDeployPackage" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Build-WebDeployPackage"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Build a web deploy package with default configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebDeployPackage

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug" | Should Exist
        }

        It "uses the default platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\obj\Debug\Package\PackageTmp\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "includes the content files" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug\Package\PackageTmp\Index.html" | Should Exist
        }

        It "builds the web deploy package" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "WebApplication.zip" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\Debug\WebApplication.Tests.dll" | Should Exist
        }
    }

    Context "Build a web deploy package from project only with default configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebDeployPackage -BuildProjectOnly $true

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug" | Should Exist
        }

        It "uses the default platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\obj\Debug\Package\PackageTmp\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "includes the content files" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug\Package\PackageTmp\Index.html" | Should Exist
        }

        It "builds the web deploy package" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "WebApplication.zip" | Should Exist
        }

        It "does not build other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\Debug\WebApplication.Tests.dll" | Should Not Exist
        }
    }

    Context "Build a web deploy package with custom configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebDeployPackage -BuildConfiguration Release -BuildPlatform x64

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\x64\Release" | Should Exist
        }

        It "uses the default platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\obj\x64\Release\Package\PackageTmp\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "Amd64"
        }

        It "includes the content files" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\x64\Release\Package\PackageTmp\Index.html" | Should Exist
        }

        It "builds the web deploy package" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "WebApplication.zip" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\Release\WebApplication.Tests.dll" | Should Exist
        }
    }
}