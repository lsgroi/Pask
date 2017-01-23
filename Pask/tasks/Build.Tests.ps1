$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Build" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Build"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Build a class library solution with default configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ClassLibrary -Task Clean, Build

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "uses the default platform" {
            [reflection.assemblyname]::GetAssemblyName((Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }
    }

    Context "Build a class library project only with custom configuration" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ClassLibrary -Task Clean, Build -BuildProjectOnly $true -Configuration Release

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll" | Should Exist
        }

        It "uses the default platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "does not build other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Release\ClassLibrary.Tests.dll" | Should Not Exist
        }
    }

    Context "Build a console application solution with custom configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ConsoleApplication -Task Clean, Build -Configuration Release -Platform x86

        It "builds the console application executable" {
            Join-Path $TestSolutionFullPath "ConsoleApplication\bin\x86\Release\ConsoleApplication.exe" | Should Exist
        }
    }
}