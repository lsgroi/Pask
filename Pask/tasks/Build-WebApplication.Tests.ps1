$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Build-WebApplication" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Build-WebApplication"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Build and artifact a web application solution with default configuration and platform" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication, New-Artifact
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default build configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug" | Should Exist
        }

        It "uses the default target platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "includes the content files" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "Index.html" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\Index.html" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\bin\WebApplication.dll" | Should Exist
        }
    }

    Context "Build and artifact a web application project only with default configuration and platform" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication, New-Artifact -BuildProjectOnly $true
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the default build configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\Debug" | Should Exist
        }

        It "uses the default target platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "includes the content files" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "Index.html" | Should Exist
        }

        It "does not build other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Not Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\Index.html" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\bin\WebApplication.dll" | Should Exist
        }
    }

    Context "Build and artifact a web application solution with custom configuration and platform" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build-WebApplication, New-Artifact -BuildConfiguration Release -BuildPlatform x64
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll" | Should Exist
        }

        It "uses the custom build configuration" {
            Join-Path $TestSolutionFullPath "WebApplication\obj\x64\Release" | Should Exist
        }

        It "uses the custom target platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "WebApplication\bin\WebApplication.dll")).ProcessorArchitecture | Should Be "Amd64"
        }

        It "includes the content files" {
            Join-Path (Join-Path (Join-Path $TestSolutionFullPath "WebApplication") $WebApplicationOutputPath) "Index.html" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "WebApplication.Tests\bin\WebApplication.Tests.dll" | Should Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\Index.html" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\WebApplication\bin\WebApplication.dll" | Should Exist
        }
    }
}