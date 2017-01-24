$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Build" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Build"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Build and artifact a class library solution with default configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ClassLibrary -Task Clean, Build, New-Artifact

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "uses the default build configuration" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug" | Should Exist
        }

        It "uses the default target platform" {
            [reflection.assemblyname]::GetAssemblyName((Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }
    }

    Context "Build and artifact a class library project only with custom configuration" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ClassLibrary -Task Clean, Build, New-Artifact -BuildProjectOnly $true -BuildConfiguration Release

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll" | Should Exist
        }

        It "uses the custom build configuration" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release" | Should Exist
        }

        It "uses the default target platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "does not build other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Release\ClassLibrary.Tests.dll" | Should Not Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }
    }

    Context "Build and artifact a console application solution with custom configuration and platform" {
        # Act
        Invoke-Pask $TestSolutionFullPath -SolutionName ConsoleApplication -Task Clean, Build, New-Artifact -BuildConfiguration Release -BuildPlatform x86

        It "builds the console application executable" {
            Join-Path $TestSolutionFullPath "ConsoleApplication\bin\x86\Release\ConsoleApplication.exe" | Should Exist
        }

        It "uses the custom build configuration" {
            Join-Path $TestSolutionFullPath "ConsoleApplication\bin\x86\Release" | Should Exist
        }

        It "uses the custom target platform" {
            [System.Reflection.AssemblyName]::GetAssemblyName((Join-Path $TestSolutionFullPath "ConsoleApplication\bin\x86\Release\ConsoleApplication.exe")).ProcessorArchitecture | Should Be "x86"
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Release\ClassLibrary.dll" | Should Exist
        }

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ConsoleApplication\ConsoleApplication.exe" | Should Exist
        }
    }
}