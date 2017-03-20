$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Default" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Default"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
        Exec { Robocopy (Join-Path "$ProjectFullPath" "init\.build") (Join-Path "$TestSolutionFullPath" ".build") "build.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    }

    Context "Invoke the default task within the default solution" {
        BeforeAll {
            # Arrange
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "**\bin")

            # Act
            Invoke-Pask $TestSolutionFullPath
        }

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

    Context "Invoke the default task within a custom solution" {
        BeforeAll {
            # Arrange
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "**\bin")

            # Act
            Invoke-Pask $TestSolutionFullPath -SolutionName "ClassLibrary.Other"
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Other\bin\Debug\ClassLibrary.Other.dll" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Other.Tests\bin\Debug\ClassLibrary.Other.Tests.dll" | Should Exist
        }
    }

    Context "Invoke the default task within the default solution in a specific path" {
        BeforeAll {
            # Arrange
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "**\bin")

            # Act
            Invoke-Pask $TestSolutionFullPath -SolutionFilePath "Solutions"
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }
    }

    Context "Invoke the default task within a custom solution in a specific path" {
        BeforeAll {
            # Arrange
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "**\bin")

            # Act
            Invoke-Pask $TestSolutionFullPath -SolutionFilePath "Solutions" -SolutionName "ClassLibrary.Other.Solution"
        }

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Other\bin\Debug\ClassLibrary.Other.dll" | Should Exist
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Other.Tests\bin\Debug\ClassLibrary.Other.Tests.dll" | Should Exist
        }
    }
}