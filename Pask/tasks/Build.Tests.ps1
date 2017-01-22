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

        It "should build the default project" {
           Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "should build other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }
    }

    Context "Build a class library project only with custom configuration" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ClassLibrary -Task Clean, Build -BuildProjectOnly $true -Configuration Release

        It "should build the default project" {
           Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll" | Should Exist
        }

        It "should not build other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Release\ClassLibrary.Tests.dll" | Should Not Exist
        }
    }

    Context "Build a console application with custom configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ConsoleApplication -Task Clean, Build -Configuration Release -Platform x86

        It "should build the console application executable" {
           Join-Path $TestSolutionFullPath "ConsoleApplication\bin\x86\Release\ConsoleApplication.exe" | Should Exist
        }
    }
}